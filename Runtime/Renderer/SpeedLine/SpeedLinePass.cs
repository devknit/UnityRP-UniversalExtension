#define ENABLE_ALPHA_BLEND

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Knit.Rendering.Universal
{
	internal sealed class SpeedLinePass : ScriptableRenderPass
	{
		public SpeedLinePass( Material material)
		{
			m_Material = material;
		#if ENABLE_ALPHA_BLEND
			if( m_Material != null)
			{
				m_Material.SetFloat( kShaderPropertyColorSrcFactor, (float)BlendMode.SrcAlpha);
				m_Material.SetFloat( kShaderPropertyColorDstFactor, (float)BlendMode.OneMinusSrcAlpha);
				CoreUtils.SetKeyword( m_Material, kKeywordAlphaBlendOn, true);
			}
		#endif
		}
		public void Dispose()
		{
		#if !ENABLE_ALPHA_BLEND
			m_CopiedColorTarget?.Release();
		#endif
		}
	#if !ENABLE_ALPHA_BLEND
		public override void Configure( CommandBuffer commandBuffer, RenderTextureDescriptor cameraTextureDescriptor)
        {
			RenderTextureDescriptor descriptor = cameraTextureDescriptor;
			descriptor.msaaSamples = 1;
			descriptor.depthBufferBits = (int)DepthBits.None;
			RenderingUtils.ReAllocateIfNeeded( ref m_CopiedColorTarget, descriptor, name: kTempColorTarget);
		}
	#endif
		public override void Execute( ScriptableRenderContext context, ref RenderingData renderingData)
		{
			ref var cameraData = ref renderingData.cameraData;
			
			if( m_Material == null || (cameraData.cameraType & kInvalidCameraType) != 0)
			{
				return;
			}
			var volume = VolumeManager.instance.stack.GetComponent( typeof( Volume.SpeedLine)) as Volume.SpeedLine;
			
			if( (volume?.ApplyProperties( m_Material) ?? false) == false)
			{
				return;
			}
			CommandBuffer commandBuffer = CommandBufferPool.Get( kProfilerTag);
		#if ENABLE_ALPHA_BLEND
			Blitter.BlitTexture( commandBuffer, Vector2.one, m_Material, 0);
		#else
			RTHandle cameraColorTarget = cameraData.renderer.cameraColorTargetHandle;
			StoreBlitter.BlitCameraTexture( commandBuffer, cameraColorTarget, m_CopiedColorTarget, 0, false);
			StoreBlitter.BlitCameraTexture( commandBuffer, m_CopiedColorTarget, cameraColorTarget, m_Material, 0);
		#endif
			context.ExecuteCommandBuffer( commandBuffer);
			CommandBufferPool.Release( commandBuffer);
		}
		const CameraType kInvalidCameraType = CameraType.SceneView | CameraType.Preview;
		const string kProfilerTag = nameof( SpeedLinePass);
		const string kTempColorTarget = "_SpeedLineTarget";
	#if ENABLE_ALPHA_BLEND
		const string kKeywordAlphaBlendOn = "_ALPHA_BLEND_ON";
		static readonly int kShaderPropertyColorSrcFactor = Shader.PropertyToID( "_ColorSrcFactor");
		static readonly int kShaderPropertyColorDstFactor = Shader.PropertyToID( "_ColorDstFactor");
	#else
		RTHandle m_CopiedColorTarget;
	#endif
        readonly Material m_Material;
	}
}