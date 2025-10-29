
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_6000_0_OR_NEWER || UNITY_2023_3_OR_NEWER
using UnityEngine.Rendering.RenderGraphModule;
#endif

namespace Knit.Rendering.Universal
{
	internal sealed class TransparentDepthPass : ScriptableRenderPass
	{
		public TransparentDepthPass()
		{
		}
	#if UNITY_6000_0_OR_NEWER || UNITY_2023_3_OR_NEWER
		public override void RecordRenderGraph( RenderGraph renderGraph, ContextContainer frameData)
		{
			UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();
			UniversalRenderingData renderingData = frameData.Get<UniversalRenderingData>();
			UniversalLightData lightData = frameData.Get<UniversalLightData>();
			UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
			
			using( IRasterRenderGraphBuilder builder = renderGraph.AddRasterRenderPass<PassData>( kProfilerTag, out var passData))
			{
				builder.UseAllGlobalTextures( true);
				
				passData.colorHandle = resourceData.activeColorTexture;
                builder.SetRenderAttachment( passData.colorHandle, 0);
				passData.depthHandle = resourceData.activeDepthTexture;
                builder.SetRenderAttachmentDepth( passData.depthHandle);
				
				DrawingSettings drawSettings = RenderingUtils.CreateDrawingSettings( 
					kShaderTagId, renderingData, cameraData, lightData, SortingCriteria.CommonTransparent);
				var filteringSettings = new FilteringSettings( RenderQueueRange.transparent, kLayerMask);
				var rendererListParams = new RendererListParams( renderingData.cullResults, drawSettings, filteringSettings);
				passData.rendererList = renderGraph.CreateRendererList( rendererListParams);
				
				builder.UseRendererList( passData.rendererList);
				builder.SetRenderFunc( (PassData data, RasterGraphContext context) =>
				{
					using( new ProfilingScope( context.cmd, profilingSampler))
					{
						context.cmd.DrawRendererList( data.rendererList);
					}
				});
			}
		}
		internal class PassData
		{
			internal TextureHandle colorHandle;
			internal TextureHandle depthHandle;
			internal RendererListHandle rendererList;
		}
	#else
		public override void Execute( ScriptableRenderContext context, ref RenderingData renderingData)
		{
			DrawingSettings  drawingSettings  = CreateDrawingSettings( kShaderTagId, ref renderingData, SortingCriteria.CommonTransparent);
			RenderStateBlock renderStateBlock = new RenderStateBlock( RenderStateMask.Nothing);
			
			var filteringSettings = new FilteringSettings( RenderQueueRange.transparent, kLayerMask);
			var cmd = CommandBufferPool.Get( kProfilerTag);
			
			using( new ProfilingScope( cmd, profilingSampler))
			{
				context.DrawRenderers( renderingData.cullResults, ref drawingSettings, ref filteringSettings, ref renderStateBlock);
				cmd.Clear();
				context.ExecuteCommandBuffer( cmd);
			}
			CommandBufferPool.Release( cmd);
		}
	#endif
		static readonly LayerMask kLayerMask = (LayerMask)(-1);
		const string kProfilerTag = "TransparentDepthPrepass";
		const string kShaderTagName = "TransparentDepthOnly";
		static readonly ShaderTagId kShaderTagId = new( kShaderTagName);
	}
}