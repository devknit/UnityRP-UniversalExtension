
using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace Knit.Rendering.Universal.Volume
{
	[Serializable, VolumeComponentMenu( "Post-processing extensions/Gradation Filter")]
	public sealed class GradationFilter : VolumeComponent, IPostProcessComponent
	{
		public enum AspectRatio
		{
			AsIs,
			Expand,
			Shrink,
		}
		public Vector2 MultiplyOffset
		{
			get{ return m_MultiplyOffset.value; }
			set{ m_MultiplyOffset.value = value; }
		}
		public Vector2 MultiplyScale
		{
			get{ return m_MultiplyScale.value; }
			set{ m_MultiplyScale.value = value; }
		}
		public float MultiplyRotate
		{
			get{ return m_MultiplyRotate.value; }
			set{ m_MultiplyRotate.value = value; }
		}
		public AspectRatio MultiplyAspect
		{
			get{ return m_MultiplyAspect.value; }
			set{ m_MultiplyAspect.value = value; }
		}
		public Color MultiplyColorLT
		{
			get{ return m_MultiplyColorLT.value; }
			set{ m_MultiplyColorLT.value = value; }
		}
		public Color MultiplyColorLB
		{
			get{ return m_MultiplyColorLB.value; }
			set{ m_MultiplyColorLB.value = value; }
		}
		public Color MultiplyColorRT
		{
			get{ return m_MultiplyColorRT.value; }
			set{ m_MultiplyColorRT.value = value; }
		}
		public Color MultiplyColorRB
		{
			get{ return m_MultiplyColorLB.value; }
			set{ m_MultiplyColorLB.value = value; }
		}
		public Vector2 AddOffset
		{
			get{ return m_AddOffset.value; }
			set{ m_AddOffset.value = value; }
		}
		public Vector2 AddScale
		{
			get{ return m_AddScale.value; }
			set{ m_AddScale.value = value; }
		}
		public float AddRotate
		{
			get{ return m_AddRotate.value; }
			set{ m_AddRotate.value = value; }
		}
		public AspectRatio AddAspect
		{
			get{ return m_AddAspect.value; }
			set{ m_AddAspect.value = value; }
		}
		public Color AddColorLT
		{
			get{ return m_AddColorLT.value; }
			set{ m_AddColorLT.value = value; }
		}
		public Color AddColorLB
		{
			get{ return m_AddColorLB.value; }
			set{ m_AddColorLB.value = value; }
		}
		public Color AddColorRT
		{
			get{ return m_AddColorRT.value; }
			set{ m_AddColorRT.value = value; }
		}
		public Color AddColorRB
		{
			get{ return m_AddColorLB.value; }
			set{ m_AddColorLB.value = value; }
		}
		public bool IsActive()
		{
			return (
				m_MultiplyColorLT.value.a + m_MultiplyColorRT.value.a +
				m_MultiplyColorLB.value.a + m_MultiplyColorRB.value.a +
				m_AddColorLT.value.a + m_AddColorRT.value.a +
				m_AddColorLB.value.a + m_AddColorRB.value.a) > 0;
		}
		internal bool ApplyProperties( Material material, float width, float height)
		{
			if( active != false && IsActive() != false)
			{
				float multiplyRadian = m_MultiplyRotate.value * Mathf.Deg2Rad;
				float multiplyScaleX = m_MultiplyScale.value.x;
				float multiplyScaleY = m_MultiplyScale.value.y;
				
				if( multiplyScaleX != 0)
				{
					multiplyScaleX = 1.0f / multiplyScaleX;
				}
				if( multiplyScaleY != 0)
				{
					multiplyScaleY = 1.0f / multiplyScaleY;
				}
				material.SetColor( kShaderPropertyMultiplyColorLB, m_MultiplyColorLB.value);
				material.SetColor( kShaderPropertyMultiplyColorRB, m_MultiplyColorRB.value);
				material.SetColor( kShaderPropertyMultiplyColorLT, m_MultiplyColorLT.value);
				material.SetColor( kShaderPropertyMultiplyColorRT, m_MultiplyColorRT.value);
				material.SetVector( kShaderPropertyMultiplyParam, new Vector4( 
					m_MultiplyOffset.value.x, m_MultiplyOffset.value.y, multiplyScaleX, multiplyScaleY));
				
				float addRadian = m_AddRotate.value * Mathf.Deg2Rad;
				float addScaleX = m_AddScale.value.x;
				float addScaleY = m_AddScale.value.y;
				
				if( addScaleX != 0)
				{
					addScaleX = 1.0f / addScaleX;
				}
				if( addScaleY != 0)
				{
					addScaleY = 1.0f / addScaleY;
				}
				material.SetColor( kShaderPropertyAddColorLB, m_AddColorLB.value);
				material.SetColor( kShaderPropertyAddColorRB, m_AddColorRB.value);
				material.SetColor( kShaderPropertyAddColorLT, m_AddColorLT.value);
				material.SetColor( kShaderPropertyAddColorRT, m_AddColorRT.value);
				material.SetVector( kShaderPropertyAddParam, new Vector4( 
					m_AddOffset.value.x, m_AddOffset.value.y, addScaleX, addScaleY));
				
				Vector2 multiplyAspect = m_MultiplyAspect.value switch
				{
					AspectRatio.Expand => (width >= height)? new Vector2( width / height, 1.0f) : new Vector2( 1.0f, height / width),
					AspectRatio.Shrink => (width >= height)? new Vector2( 1.0f, height / width) : new Vector2( width / height, 1.0f),
					_ => Vector2.one
				};
				Vector2 addAspect = m_AddAspect.value switch
				{
					AspectRatio.Expand => (width >= height)? new Vector2( width / height, 1.0f) : new Vector2( 1.0f, height / width),
					AspectRatio.Shrink => (width >= height)? new Vector2( 1.0f, height / width) : new Vector2( width / height, 1.0f),
					_ => Vector2.one
				};
				material.SetVector( kShaderPropertyAspectParam, new Vector4( 
					multiplyAspect.x, multiplyAspect.y, addAspect.x, addAspect.y));
				material.SetVector( kShaderPropertyRotateParam, new Vector4( 
					Mathf.Cos( multiplyRadian), Mathf.Sin( multiplyRadian),
					Mathf.Cos( addRadian), Mathf.Sin( addRadian)));
				return true;
			}
			return false;
		}
		internal static readonly Color kMonochromeDot = new( 0.298912f, 0.586611f, 0.114478f, 0.0f);
		internal static readonly Color kSepiaMultiply = new( 1.07f, 0.74f, 0.43f, 0.0f);
		static readonly int kShaderPropertyMultiplyColorLB = Shader.PropertyToID( "_MultiplyColorLB");
		static readonly int kShaderPropertyMultiplyColorLT = Shader.PropertyToID( "_MultiplyColorLT");
		static readonly int kShaderPropertyMultiplyColorRB = Shader.PropertyToID( "_MultiplyColorRB");
		static readonly int kShaderPropertyMultiplyColorRT = Shader.PropertyToID( "_MultiplyColorRT");
		static readonly int kShaderPropertyMultiplyParam = Shader.PropertyToID( "_MultiplyParam");
		static readonly int kShaderPropertyAddColorLB = Shader.PropertyToID( "_AddColorLB");
		static readonly int kShaderPropertyAddColorLT = Shader.PropertyToID( "_AddColorLT");
		static readonly int kShaderPropertyAddColorRB = Shader.PropertyToID( "_AddColorRB");
		static readonly int kShaderPropertyAddColorRT = Shader.PropertyToID( "_AddColorRT");
		static readonly int kShaderPropertyAddParam = Shader.PropertyToID( "_AddParam");
		static readonly int kShaderPropertyAspectParam = Shader.PropertyToID( "_AspectParam");
		static readonly int kShaderPropertyRotateParam = Shader.PropertyToID( "_RotateParam");
		
		[SerializeField]
		internal Vector2Parameter m_MultiplyOffset = new( Vector2.zero);
		[SerializeField]
		internal Vector2Parameter m_MultiplyScale = new( Vector2.one);
		[SerializeField]
		internal FloatParameter m_MultiplyRotate = new( 0);
		[SerializeField]
		internal EnumParameter<AspectRatio> m_MultiplyAspect = new( AspectRatio.Shrink);
		[SerializeField]
		internal ColorParameter  m_MultiplyColorLT = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		internal ColorParameter  m_MultiplyColorLB = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		internal ColorParameter  m_MultiplyColorRT = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		internal ColorParameter  m_MultiplyColorRB = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		internal Vector2Parameter m_AddOffset = new( Vector2.zero);
		[SerializeField]
		internal Vector2Parameter m_AddScale = new( Vector2.one);
		[SerializeField]
		internal FloatParameter m_AddRotate = new( 0);
		[SerializeField]
		internal EnumParameter<AspectRatio> m_AddAspect = new( AspectRatio.Shrink);
		[SerializeField]
		internal ColorParameter  m_AddColorLT = new( Color.clear, true, true, true);
		[SerializeField]
		internal ColorParameter  m_AddColorLB = new( Color.clear, true, true, true);
		[SerializeField]
		internal ColorParameter  m_AddColorRT = new( Color.clear, true, true, true);
		[SerializeField]
		internal ColorParameter  m_AddColorRB = new( Color.clear, true, true, true);
	}
}