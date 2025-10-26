
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

#if UNITY_EDITOR
using System;
using System.Reflection;
using UnityEditor;
#endif

namespace Knit.Rendering.Universal
{
	internal sealed class EdgeDetectionPass : ScriptableRenderPass
	{
		public EdgeDetectionPass( Material material)
		{
			m_Material = material;
		}
		public void Dispose()
		{
			m_CopiedColorTarget?.Release();
		}
		public override void Execute( ScriptableRenderContext context, ref RenderingData renderingData)
		{
			ref var cameraData = ref renderingData.cameraData;
			
			if( m_Material == null || (cameraData.cameraType & kInvalidCameraType) != 0)
			{
				return;
			}
			var volume = VolumeManager.instance.stack.GetComponent( typeof( Volume.EdgeDetection)) as Volume.EdgeDetection;
			
			if( (volume?.ApplyProperties( m_Material) ?? false) == false)
			{
				return;
			}
			RenderTextureDescriptor copiedColorTargetDescriptor = renderingData.cameraData.cameraTargetDescriptor;
			copiedColorTargetDescriptor.msaaSamples = 1;
			copiedColorTargetDescriptor.depthBufferBits = (int)DepthBits.None;
			RenderingUtils.ReAllocateIfNeeded( ref m_CopiedColorTarget, copiedColorTargetDescriptor, name: kCopiedColorTarget);
			RTHandle cameraColorTarget = cameraData.renderer.cameraColorTargetHandle;
			CommandBuffer commandBuffer = CommandBufferPool.Get( kProfilerTag);
			
			BlitUtility.BlitCameraTexture( commandBuffer, cameraColorTarget, m_CopiedColorTarget, 0, false);
			
			if( volume.m_StencilCompare.value != CompareFunction.Always)
			{
				commandBuffer.SetRenderTarget( cameraColorTarget, 
					RenderBufferLoadAction.DontCare,  RenderBufferStoreAction.Store, 
					cameraData.renderer.cameraDepthTargetHandle,
					RenderBufferLoadAction.Load, RenderBufferStoreAction.DontCare);
			}
			else
			{
				commandBuffer.SetRenderTarget( cameraColorTarget, 
					RenderBufferLoadAction.DontCare,  RenderBufferStoreAction.Store, 
					RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
			}
			Blitter.BlitTexture( commandBuffer, m_CopiedColorTarget, BlitUtility.GetScaleBias( m_CopiedColorTarget), m_Material, (int)volume.EdgeType);
			context.ExecuteCommandBuffer( commandBuffer);
			CommandBufferPool.Release( commandBuffer);
		}
		const CameraType kInvalidCameraType = CameraType.SceneView | CameraType.Preview;
		const string kProfilerTag = nameof( EdgeDetectionPass);
		const string kCopiedColorTarget = "EdgeDetection::CopiedColorTarget";
		
		RTHandle m_CopiedColorTarget;
		readonly Material m_Material;
	}
}