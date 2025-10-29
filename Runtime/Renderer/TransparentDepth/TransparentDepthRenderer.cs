
using UnityEngine.Rendering.Universal;

namespace Knit.Rendering.Universal
{
	[DisallowMultipleRendererFeature( "Transparent Depth")]
	internal sealed class TransparentDepthRenderer : ScriptableRendererFeature
	{
		public override void Create()
		{
			m_Pass = new TransparentDepthPass();
		}
		public override void AddRenderPasses( ScriptableRenderer renderer, ref RenderingData renderingData)
		{
			renderer.EnqueuePass( m_Pass);
		}
		TransparentDepthPass m_Pass;
	}
}