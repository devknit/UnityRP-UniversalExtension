
using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace Knit.Rendering.Universal.Volume
{
	[Serializable, VolumeComponentMenu( "Post-processing extensions/Speed Line")]
	internal sealed class SpeedLine : VolumeComponent, IPostProcessComponent
	{
		public bool IsActive()
		{
			return m_Color.value.a > 0.0f;
		}
		internal bool ApplyProperties( Material material)
		{
			if( active != false && IsActive() != false)
			{
				Vector2 center = m_Center.value;
				Vector2 axisMask = m_AxisMask.value;
				float radian = m_Rotate.value * Mathf.Deg2Rad;
				
				material.SetColor( kShaderPropertyColor, m_Color.value);
				material.SetVector( kShaderPropertyParam1, 
					new Vector4( 
						center.x, center.y, 
						axisMask.x, axisMask.y));
				material.SetVector( kShaderPropertyParam2, 
					new Vector4( 
						m_Sparse.value, 
						m_Remap.value, 
						m_SmoothBorder.value, 
						m_SmoothWidth.value));
				material.SetVector( kShaderPropertyParam3, 
					new Vector4( 
						m_Tiling.value, 
						m_RadialScale.value, 
						m_TimeScale.value, 
						(float)m_Pattern.value));
				material.SetVector( kShaderPropertyParam4, 
					new Vector4( 
						Mathf.Cos( radian), 
						Mathf.Sin( radian), 
						0, 
						0));
				return true;
			}
			return false;
		}
		internal enum Pattern
		{
			Radial,
			Horizontal,
			Vertical,
			Wave,
		}
		static readonly int kShaderPropertyColor = Shader.PropertyToID( "_Color");
		static readonly int kShaderPropertyParam1 = Shader.PropertyToID( "_Param1");
		static readonly int kShaderPropertyParam2 = Shader.PropertyToID( "_Param2");
		static readonly int kShaderPropertyParam3 = Shader.PropertyToID( "_Param3");
		static readonly int kShaderPropertyParam4 = Shader.PropertyToID( "_Param4");
		
		[SerializeField]
		internal EnumParameter<Pattern> m_Pattern = new( Pattern.Radial);
		[SerializeField]
		internal ColorParameter  m_Color = new( new Color( 1.0f, 1.0f, 1.0f, 0.0f), true, true, true, true);
		[SerializeField]
		internal Vector2Parameter m_Center = new( new Vector2( 0.5f, 0.5f));
		[SerializeField]
		internal Vector2Parameter m_AxisMask = new( new Vector2( 1.0f, 1.0f));
		[SerializeField]
		internal FloatParameter m_Rotate = new( 0.0f);
		[SerializeField]
		internal FloatParameter m_Tiling = new( 200.0f);
		[SerializeField]
		internal FloatParameter m_Sparse = new( 3.0f);
		[SerializeField]
		internal ClampedFloatParameter m_Remap = new( 0.5f, 0.0f, 1.0f);
		[SerializeField]
		internal ClampedFloatParameter m_RadialScale = new( 0.5f, 0.0f, 10.0f);
		[SerializeField]
		internal FloatParameter m_SmoothWidth = new( 0.45f);
		[SerializeField]
		internal FloatParameter m_SmoothBorder = new( 0.3f);
		[SerializeField]
		internal FloatParameter m_TimeScale = new( 3.0f);
	}
}