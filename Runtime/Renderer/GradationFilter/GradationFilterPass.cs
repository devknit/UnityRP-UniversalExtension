
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Knit.Rendering.Universal
{
	internal sealed class GradationFilterPass : ScriptableRenderPass
	{
		public GradationFilterPass( Material material)
		{
			m_Material = material;
		}
		public void Dispose()
		{
			m_CopiedColorTarget?.Release();
		}
		public override void Configure( CommandBuffer commandBuffer, RenderTextureDescriptor cameraTextureDescriptor)
        {
			m_Descriptor = cameraTextureDescriptor;
			m_Descriptor.msaaSamples = 1;
			m_Descriptor.depthBufferBits = (int)DepthBits.None;
			RenderingUtils.ReAllocateIfNeeded( ref m_CopiedColorTarget, m_Descriptor, name: kTempColorTarget);
		}
		public override void Execute( ScriptableRenderContext context, ref RenderingData renderingData)
		{
			ref var cameraData = ref renderingData.cameraData;
			
			if( m_Material == null || (cameraData.cameraType & kInvalidCameraType) != 0)
			{
				return;
			}
			var volume = VolumeManager.instance.stack.GetComponent( typeof( Volume.GradationFilter)) as Volume.GradationFilter;
			
			if( (volume?.ApplyProperties( m_Material, m_Descriptor.width, m_Descriptor.height) ?? false) == false)
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
		const string kProfilerTag = nameof( GradationFilterPass);
		const string kTempColorTarget = "_GradationFilterTarget";
        readonly Material m_Material;
		RTHandle m_CopiedColorTarget;
		RenderTextureDescriptor m_Descriptor;
	}
}