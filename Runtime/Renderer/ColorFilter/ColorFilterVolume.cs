
using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace Knit.Rendering.Universal.Volume
{
	[Serializable, VolumeComponentMenu( "Post-processing extensions/Color Filter")]
	public sealed class ColorFilter : VolumeComponent, IPostProcessComponent
	{
		public Color DotColor
		{
			get{ return m_DotColor.value; }
			set{ m_DotColor.value = value; }
		}
		public Color MultiplyColor
		{
			get{ return m_MultiplyColor.value; }
			set{ m_MultiplyColor.value = value; }
		}
		public Color AddColor
		{
			get{ return m_AddColor.value; }
			set{ m_AddColor.value = value; }
		}
		public float Contrast
		{
			get{ return m_Contrast.value; }
			set{ m_Contrast.value = value; }
		}
		public float FlipX
		{
			get{ return m_FlipX.value; }
			set{ m_FlipX.value = value; }
		}
		public float FlipY
		{
			get{ return m_FlipY.value; }
			set{ m_FlipY.value = value; }
		}
		public bool IsActive()
		{
			return (m_DotColor.value.a + m_MultiplyColor.value.a + m_AddColor.value.a) > 0
				|| m_Contrast.value != 1.0f || (m_Contrast.value + m_FlipX.value) > 0;
		}
		internal bool ApplyProperties( Material material)
		{
			if( active != false && IsActive() != false)
			{
				material.SetColor( kShaderPropertyDotColor, m_DotColor.value);
				material.SetColor( kShaderPropertyMultiplyColor, m_MultiplyColor.value);
				material.SetColor( kShaderPropertyAddColor, m_AddColor.value);
				material.SetVector( kShaderPropertyParam, 
					new Vector4( m_Contrast.value, m_FlipX.value, m_FlipY.value, 0));
				return true;
			}
			return false;
		}
		internal static readonly Color kMonochromeDot = new( 0.298912f, 0.586611f, 0.114478f, 0.0f);
		internal static readonly Color kSepiaMultiply = new( 1.07f, 0.74f, 0.43f, 0.0f);
		static readonly int kShaderPropertyDotColor = Shader.PropertyToID( "_DotColor");
		static readonly int kShaderPropertyMultiplyColor = Shader.PropertyToID( "_MultiplyColor");
		static readonly int kShaderPropertyAddColor = Shader.PropertyToID( "_AddColor");
		static readonly int kShaderPropertyParam = Shader.PropertyToID( "_Param");
		
		[SerializeField]
		internal ColorParameter  m_DotColor = new( kMonochromeDot, true, true, true);
		[SerializeField]
		internal ColorParameter  m_MultiplyColor = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		internal ColorParameter  m_AddColor = new( Color.clear, true, true, true);
		[SerializeField]
		internal ClampedFloatParameter m_Contrast = new( 1.0f, -5.0f, 5.0f);
		[SerializeField]
		internal ClampedFloatParameter m_FlipX = new( 0.0f, 0.0f, 1.0f);
		[SerializeField]
		internal ClampedFloatParameter m_FlipY = new( 0.0f, 0.0f, 1.0f);
	}
}