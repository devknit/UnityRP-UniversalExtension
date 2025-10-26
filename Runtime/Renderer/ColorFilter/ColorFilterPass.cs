
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Knit.Rendering.Universal
{
	internal sealed class ColorFilterPass : ScriptableRenderPass
	{
		public ColorFilterPass( Material material)
		{
			m_Material = material;
		}
		public void Dispose()
		{
			m_CopiedColorTarget?.Release();
		}
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
		const CameraType kInvalidCameraType = CameraType.SceneView | CameraType.Preview;
		const string kProfilerTag = nameof( ColorFilterPass);
		const string kTempColorTarget = "_ColorFilterTarget";
        readonly Material m_Material;
		RTHandle m_CopiedColorTarget;
	}
}