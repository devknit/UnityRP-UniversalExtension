
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_6000_0_OR_NEWER || UNITY_2023_3_OR_NEWER
using UnityEngine.Rendering.RenderGraphModule;
#endif

namespace Knit.Rendering.Universal
{
	internal sealed class ColorFilterPass : ScriptableRenderPass
	{
		public ColorFilterPass( Material material)
		{
			m_Material = material;
			renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
		}
	#if UNITY_6000_0_OR_NEWER || UNITY_2023_3_OR_NEWER
		public override void RecordRenderGraph( RenderGraph renderGraph, ContextContainer frameData)
		{
			var cameraData = frameData.Get<UniversalCameraData>();
			
			if( m_Material == null || (cameraData.camera.cameraType & kInvalidCameraType) != 0)
			{
				return;
			}
			var volume = VolumeManager.instance.stack.GetComponent( typeof( Volume.ColorFilter)) as Volume.ColorFilter;
			
			if( (volume?.ApplyProperties( m_Material) ?? false) == false)
			{
				return;
			}
			UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
			TextureHandle cameraTexture = resourceData.activeColorTexture;
			
			TextureDesc tempDesc = renderGraph.GetTextureDesc( cameraTexture);
			tempDesc.name = kTempColorTarget;
			TextureHandle tempTexture = renderGraph.CreateTexture( tempDesc);
			
			using( IRasterRenderGraphBuilder builder = renderGraph.AddRasterRenderPass( kProfilerTag, out PassData passData))
			{
				passData.CameraTexture = cameraTexture;
				passData.Material = m_Material;
				builder.UseTexture( cameraTexture, AccessFlags.Read);
				builder.SetRenderAttachment( tempTexture, 0, AccessFlags.Write);
				builder.SetRenderFunc<PassData>( static (passData, context) =>
				{
					Blitter.BlitTexture( context.cmd, passData.CameraTexture, Vector2.one, passData.Material, 0);
				});
			}
			resourceData.cameraColor = tempTexture;
		}
		public void Dispose()
		{
		}
		class PassData
		{
			public TextureHandle CameraTexture;
			public Material Material;
		}
	#else
		public override void Configure( CommandBuffer commandBuffer, RenderTextureDescriptor cameraTextureDescriptor)
        {
			RenderTextureDescriptor descriptor = cameraTextureDescriptor;
			descriptor.msaaSamples = 1;
			descriptor.depthBufferBits = (int)DepthBits.None;
			RenderingUtils.ReAllocateIfNeeded( ref m_CopiedColorTarget, descriptor, name: kTempColorTarget);
		}
		public override void Execute( ScriptableRenderContext context, ref RenderingData renderingData)
		{
			ref var cameraData = ref renderingData.cameraData;
			
			if( m_Material == null || (cameraData.cameraType & kInvalidCameraType) != 0)
			{
				return;
			}
			var volume = VolumeManager.instance.stack.GetComponent( typeof( Volume.ColorFilter)) as Volume.ColorFilter;
			
			if( (volume?.ApplyProperties( m_Material) ?? false) == false)
			{
				return;
			}
			CommandBuffer commandBuffer = CommandBufferPool.Get( kProfilerTag);
			RTHandle cameraColorTarget = cameraData.renderer.cameraColorTargetHandle;
			BlitUtility.BlitCameraTexture( commandBuffer, cameraColorTarget, m_CopiedColorTarget, 0, false);
			BlitUtility.BlitCameraTexture( commandBuffer, m_CopiedColorTarget, cameraColorTarget, m_Material, 0);
			context.ExecuteCommandBuffer( commandBuffer);
			CommandBufferPool.Release( commandBuffer);
		}
		public void Dispose()
		{
			m_CopiedColorTarget?.Release();
		}
		RTHandle m_CopiedColorTarget;
	#endif
		const CameraType kInvalidCameraType = CameraType.SceneView | CameraType.Preview;
		const string kProfilerTag = nameof( ColorFilterPass);
		const string kTempColorTarget = "_ColorFilterTarget";
        readonly Material m_Material;
	}
}