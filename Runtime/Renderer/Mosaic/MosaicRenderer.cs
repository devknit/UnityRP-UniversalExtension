
using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Knit.Rendering.Universal
{
	[DisallowMultipleRendererFeature( "Mosaic")]
	public sealed class MosaicRenderer : ScriptableRendererFeature
	{
		public override void Create()
		{
			if( m_CopyStencilMaterial == null)
			{
				m_CopyStencilMaterial = CoreUtils.CreateEngineMaterial( m_CopyStencilShader);
			}
			if( m_CopyStencilMaterial != null)
			{
				m_CopyStencilPass ??= new CopyStencilPass( m_CopyStencilMaterial)
				{
					renderPassEvent = m_CopyStencilPassEvent
				};
			}
			if( m_MosaicMaterial == null)
			{
				m_MosaicMaterial = CoreUtils.CreateEngineMaterial( m_MosaicShader);
			}
			if( m_MosaicMaterial != null)
			{
				m_MosaicPass ??= new MosaicPass( m_MosaicMaterial, m_CopyStencilPass)
				{
					renderPassEvent = m_MosaicPassEvent
				};
			}
		}
		protected override void Dispose( bool disposing)
		{
			if( m_MosaicPass != null)
			{
				m_MosaicPass.Dispose();
				m_MosaicPass = null;
			}
			if( m_MosaicMaterial != null)
			{
				CoreUtils.Destroy( m_MosaicMaterial);
				m_MosaicMaterial = null;
			}
			if( m_CopyStencilPass != null)
			{
				m_CopyStencilPass.Dispose();
				m_CopyStencilPass = null;
			}
			if( m_CopyStencilMaterial != null)
			{
				CoreUtils.Destroy( m_CopyStencilMaterial);
				m_CopyStencilMaterial = null;
			}
		}
		public override void AddRenderPasses( ScriptableRenderer renderer, ref RenderingData renderingData)
		{
			renderer.EnqueuePass( m_CopyStencilPass);
			renderer.EnqueuePass( m_MosaicPass);
		}
		[SerializeField]
		Shader m_MosaicShader;
		[SerializeField]
		RenderPassEvent m_MosaicPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
		[NonSerialized]
		MosaicPass m_MosaicPass;
		[NonSerialized]
		Material m_MosaicMaterial;
		
		[SerializeField]
		Shader m_CopyStencilShader;
		[SerializeField]
		RenderPassEvent m_CopyStencilPassEvent = RenderPassEvent.AfterRenderingTransparents;
		[NonSerialized]
		CopyStencilPass m_CopyStencilPass;
		[NonSerialized]
		Material m_CopyStencilMaterial;
	}
}