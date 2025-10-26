
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.Universal.Internal;

namespace Knit.Rendering.Universal
{
	[DisallowMultipleRendererFeature( "Transparent Depth")]
	internal sealed class TransparentDepthRenderer : ScriptableRendererFeature
	{
		public override void Create()
		{
			m_RenderTransparentDepthPass ??= new DrawObjectsPass(
				kTransparentDepthProfilerTag, 
				new []{ new ShaderTagId( kShaderTagName) },
				true,
				RenderPassEvent.BeforeRenderingTransparents, 
				RenderQueueRange.transparent,
				(LayerMask)(-1),
				kDefaultStencilState,
				kDefaultStencilReference);
		}
		public override void AddRenderPasses( ScriptableRenderer renderer, ref RenderingData renderingData)
		{
			renderer.EnqueuePass( m_RenderTransparentDepthPass);
		}
		const string kTransparentDepthProfilerTag = "TransparentDepthPrepass";
		const string kShaderTagName = "TransparentDepthOnly";
		DrawObjectsPass m_RenderTransparentDepthPass;
		
		static readonly StencilState kDefaultStencilState = new(
			false, 255, 255,
			CompareFunction.Always,
			StencilOp.Keep,
			StencilOp.Keep,
			StencilOp.Keep,
			CompareFunction.Always,
			StencilOp.Keep,
			StencilOp.Keep,
			StencilOp.Keep);
		const int kDefaultStencilReference = 0;
	}
}