
using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Knit.Rendering.Universal
{
	[DisallowMultipleRendererFeature( "Color Filter")]
	internal sealed class ColorFilter : ScriptableRendererFeature
	{
		public override void Create()
		{
			if( m_Material == null)
			{
				m_Material = CoreUtils.CreateEngineMaterial( m_Shader);
			}
			if( m_Pass == null && m_Material != null)
			{
                m_Pass = new ColorFilterPass( m_Material)
                {
                    renderPassEvent = m_RenderPassEvent
                };
            }
		}
		protected override void Dispose( bool disposing)
		{
			if( m_Pass != null)
			{
				m_Pass.Dispose();
				m_Pass = null;
			}
			if( m_Material != null)
			{
				CoreUtils.Destroy( m_Material);
				m_Material = null;
			}
		}
		public override void AddRenderPasses( ScriptableRenderer renderer, ref RenderingData renderingData)
		{
			renderer.EnqueuePass( m_Pass);
		}
		[SerializeField]
		Shader m_Shader;
		[SerializeField]
		RenderPassEvent m_RenderPassEvent = RenderPassEvent.AfterRenderingTransparents;
		[NonSerialized]
		Material m_Material;
		[NonSerialized]
		ColorFilterPass m_Pass;
	}
}