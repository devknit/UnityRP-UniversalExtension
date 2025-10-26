
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Knit.Rendering.Universal
{
	internal sealed class CopyStencilPass : ScriptableRenderPass
	{
		public CopyStencilPass( Material material)
		{
			m_Material = material;
		}
		public void Dispose()
		{
			m_StencilMaskTarget?.Release();
		}
		public override void Execute( ScriptableRenderContext context, ref RenderingData renderingData)
		{
			ref var cameraData = ref renderingData.cameraData;
			
			if( m_Material == null || (cameraData.cameraType & kInvalidCameraType) != 0)
			{
				return;
			}
			var volume = VolumeManager.instance.stack.GetComponent( typeof( Volume.Mosaic)) as Volume.Mosaic;
			
			if( (volume?.IsActive() ?? false) != false && volume.m_StencilCompare.value != CompareFunction.Always)
			{
				RenderTextureDescriptor stencilMaskTargetDescriptor = renderingData.cameraData.cameraTargetDescriptor;
				CommandBuffer commandBuffer = CommandBufferPool.Get( kProfilerTag);
				
				stencilMaskTargetDescriptor.colorFormat = RenderTextureFormat.R8;
				
				if( SystemInfo.SupportsRenderTextureFormat( stencilMaskTargetDescriptor.colorFormat) == false)
				{
					stencilMaskTargetDescriptor.colorFormat = RenderTextureFormat.Default;
				}
				stencilMaskTargetDescriptor.msaaSamples = 1;
				stencilMaskTargetDescriptor.depthBufferBits = (int)DepthBits.None;
				stencilMaskTargetDescriptor.autoGenerateMips = true;
				stencilMaskTargetDescriptor.useMipMap = true;
				RenderingUtils.ReAllocateIfNeeded( 
					ref m_StencilMaskTarget, stencilMaskTargetDescriptor, 
					volume.m_StencilFilterMode.value, TextureWrapMode.Clamp, false, 1, 0, kStencilMaskTarget);
				
				commandBuffer.SetRenderTarget( 
					m_StencilMaskTarget,
					RenderBufferLoadAction.DontCare, 
					RenderBufferStoreAction.Store,
					cameraData.renderer.cameraDepthTargetHandle,
					RenderBufferLoadAction.Load,
					RenderBufferStoreAction.Resolve);
				commandBuffer.ClearRenderTarget( RTClearFlags.Color, Color.clear);
				
				m_Material.SetInt( kShaderPropertyStencilRef, Mathf.Clamp( volume.m_StencilReference.value, 0, 255));
				m_Material.SetInt( kShaderPropertyStencilReadMask, Mathf.Clamp( volume.m_StencilReadMask.value, 0, 255));
				m_Material.SetInt( kShaderPropertyStencilComp, (int)volume.m_StencilCompare.value);
				Blitter.BlitTexture( commandBuffer, Vector2.one, m_Material, 0);
				
				commandBuffer.SetRenderTarget( 
					cameraData.renderer.cameraColorTargetHandle,
					RenderBufferLoadAction.DontCare, 
					RenderBufferStoreAction.Store,
					cameraData.renderer.cameraDepthTargetHandle,
					RenderBufferLoadAction.Load,
					RenderBufferStoreAction.Resolve);
				context.ExecuteCommandBuffer( commandBuffer);
				CommandBufferPool.Release( commandBuffer);
			}
		}
		internal RTHandle CameraStencilTexture
		{
			get{ return m_StencilMaskTarget; }
		}
		const CameraType kInvalidCameraType = CameraType.SceneView | CameraType.Preview;
		const string kProfilerTag = nameof( CopyStencilPass);
		const string kStencilMaskTarget = "_CameraStencilTexture";
		
		static readonly int kShaderPropertyStencilRef = Shader.PropertyToID( "_StencilRef");
		static readonly int kShaderPropertyStencilReadMask = Shader.PropertyToID( "_StencilReadMask");
		static readonly int kShaderPropertyStencilComp = Shader.PropertyToID( "_StencilComp");
		
		RTHandle m_StencilMaskTarget;
		readonly Material m_Material;
	}
}