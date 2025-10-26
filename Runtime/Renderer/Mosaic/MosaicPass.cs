
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
	internal sealed class MosaicPass : ScriptableRenderPass
	{
		public MosaicPass( Material material, CopyStencilPass copyStencilPass)
		{
			m_Material = material;
			m_CopyStencilPass = copyStencilPass;
		}
		public void Dispose()
		{
			m_CopiedColorTarget?.Release();
		}
		float Remap( float val, float inMin, float inMax, float outMin, float outMax)
		{
			return Mathf.Clamp( outMin + (val - inMin) * (outMax - outMin) / (inMax - inMin), outMin, outMax);
		}
		public override void Execute( ScriptableRenderContext context, ref RenderingData renderingData)
		{
			ref var cameraData = ref renderingData.cameraData;
			
			if( m_Material == null || (cameraData.cameraType & kInvalidCameraType) != 0)
			{
				return;
			}
			var volume = VolumeManager.instance.stack.GetComponent( typeof( Volume.Mosaic)) as Volume.Mosaic;
			
			if( (volume?.IsActive() ?? false) == false)
			{
				return;
			}
			RenderTextureDescriptor copiedColorTargetDescriptor = renderingData.cameraData.cameraTargetDescriptor;
			CommandBuffer commandBuffer = CommandBufferPool.Get( kProfilerTag);
			RTHandle cameraColorTarget = cameraData.renderer.cameraColorTargetHandle;
			Vector2Int downSample = volume.m_DownSample.value;
			bool dynamicDownSample = volume.m_DynamicDownSample.value;
			int width = copiedColorTargetDescriptor.width;
			int height = copiedColorTargetDescriptor.height;
			
			if( dynamicDownSample != false)
			{
				float screenHeightPixel = Screen.height;
				
				if( screenHeightPixel >= 4096)
				{
					++downSample.x;
					++downSample.y;
				}
				if( screenHeightPixel >= 2048)
				{
					++downSample.x;
					++downSample.y;
				}
				if( screenHeightPixel >= 1440)
				{
					++downSample.x;
					++downSample.y;
				}
			}
			copiedColorTargetDescriptor.msaaSamples = 1;
			copiedColorTargetDescriptor.depthBufferBits = (int)DepthBits.None;
			copiedColorTargetDescriptor.width = width >> downSample.y;
			copiedColorTargetDescriptor.height = height >> downSample.y;
			
			if( copiedColorTargetDescriptor.width < 1)
			{
				copiedColorTargetDescriptor.width = 1;
			}
			if( copiedColorTargetDescriptor.height < 1)
			{
				copiedColorTargetDescriptor.height = 1;
			}
			RenderingUtils.ReAllocateIfNeeded( 
				ref m_CopiedColorTarget, copiedColorTargetDescriptor, 
				FilterMode.Point, TextureWrapMode.Clamp, false, 1, 0, kCopiedColorTarget);
			
			if( volume.m_StencilCompare.value != CompareFunction.Always && m_CopyStencilPass != null)
			{
				float mipMapBias = downSample.y;
				float marginBias = downSample.x;
				
				m_Material.SetVector( kShaderPropertyMarginParam, new Vector4(  
					(float)(1.0f / (width >> downSample.x)), (float)(1.0f / (width >> downSample.x)), 0, 0));
					
				if( mipMapBias > 1.0f)
				{
					mipMapBias -= 0.5f;
				}
				if( marginBias > 1.0f)
				{
					marginBias -= 0.5f;
				}
				m_Material.SetVector( kShaderPropertyMipmapLevel, new Vector4( mipMapBias, marginBias, 0, 0));
				Blitter.BlitCameraTexture( commandBuffer, cameraColorTarget, m_CopiedColorTarget, 0, false);
				
				commandBuffer.SetRenderTarget( 
					cameraColorTarget,
					RenderBufferLoadAction.Load, 
					RenderBufferStoreAction.Store,
					RenderBufferLoadAction.DontCare,
					RenderBufferStoreAction.DontCare);
				commandBuffer.SetGlobalTexture( kShaderPropertyMaskTexture, m_CopyStencilPass.CameraStencilTexture);
				Blitter.BlitTexture( commandBuffer, m_CopiedColorTarget, Vector2.one, m_Material, (downSample.x == downSample.y)? 0 : 1);
			}
			else
			{
				BlitUtility.BlitCameraTexture( commandBuffer, cameraColorTarget, m_CopiedColorTarget, 0, false);
				BlitUtility.BlitCameraTexture( commandBuffer, m_CopiedColorTarget, cameraColorTarget, 0, false);
			}
			context.ExecuteCommandBuffer( commandBuffer);
			CommandBufferPool.Release( commandBuffer);
		}
		const CameraType kInvalidCameraType = CameraType.SceneView | CameraType.Preview;
		const string kProfilerTag = nameof( MosaicPass);
		const string kCopiedColorTarget = "_Mosaic::CopiedColorTarget";
		
		static readonly int kShaderPropertyMaskTexture = Shader.PropertyToID( "_MaskTexture");
		static readonly int kShaderPropertyMipmapLevel = Shader.PropertyToID( "_MipmapLevel");
		static readonly int kShaderPropertyMarginParam = Shader.PropertyToID( "_MarginParam");
		
		RTHandle m_CopiedColorTarget;
		readonly Material m_Material;
		readonly CopyStencilPass m_CopyStencilPass;
	}
}