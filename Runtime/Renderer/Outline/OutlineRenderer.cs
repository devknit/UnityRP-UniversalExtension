
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.Universal.Internal;

namespace Knit.URP.PostProcessing
{
	[DisallowMultipleRendererFeature( "Outline")]
	internal sealed class OutlineRenderer : ScriptableRendererFeature
	{
		public override void Create()
		{
			// Depth Priming Mode を Disabled 以外にした場合、不透明でアウトラインが表示されません
			//
			// 対処方その１ ※不完全版
			// RendererFeatures に RenderObjects を追加して対応できます。
			// ただし、RenderObjects だと不透明と半透明で同じ LightMode を指定した場合、半透明のみが描画されてしまいます。
			//
			// 対処方その２
			// URP パッケージ内のソースを直接編集します
			// DrawObjectsPass.cs の InitRendererLists() で depthState に Equal を代入している箇所を抑制するメンバを用意してコンストラクタで設定できるようにする
			// UniversalRenderer.cs にアウトライン用の DrawObjectsPass を不透明、半透明の２つを用意して追加（不透明版は↑で用意した値を指定して depthState に Equal が入らないようにする）
			m_RenderOpaqueOutlinePass ??= new DrawObjectsPass(
				kOpaqueProfilerTag, 
				new []{ new ShaderTagId( kkShaderTagName) },
				true,
				RenderPassEvent.AfterRenderingOpaques, 
				RenderQueueRange.opaque,
				(LayerMask)(-1),
				kDefaultStencilState,
				kDefaultStencilReference);
			m_RenderTransparentOutlinePass ??= new DrawObjectsPass(
				kTransparentProfilerTag, 
				new []{ new ShaderTagId( kkShaderTagName) },
				true,
				RenderPassEvent.AfterRenderingTransparents, 
				RenderQueueRange.transparent,
				(LayerMask)(-1),
				kDefaultStencilState,
				kDefaultStencilReference);
		}
		public override void AddRenderPasses( ScriptableRenderer renderer, ref RenderingData renderingData)
		{
			renderer.EnqueuePass( m_RenderTransparentOutlinePass);
			renderer.EnqueuePass( m_RenderOpaqueOutlinePass);
		}
		const string kOpaqueProfilerTag = "DrawOpaqueObjectsOutline";
		const string kTransparentProfilerTag = "DrawTransparentObjectsOutline";
		const string kkShaderTagName = "OutlineOnly";
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
		
		DrawObjectsPass m_RenderOpaqueOutlinePass;
		DrawObjectsPass m_RenderTransparentOutlinePass;
	}
}