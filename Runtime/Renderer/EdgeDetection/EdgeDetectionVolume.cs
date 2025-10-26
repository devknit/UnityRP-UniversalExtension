
using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace Knit.Rendering.Universal.Volume
{
	public enum EdgeType
	{
		Both,
		Inner,
	}
	[Serializable, VolumeComponentMenu( "Post-processing extensions/EdgeDetection")]
	internal sealed class EdgeDetection : VolumeComponent, IPostProcessComponent
	{
		public bool IsActive()
		{
			return m_Color.value.a > 0 && m_Width.value > 0;
		}
		public EdgeType EdgeType
		{
			get{ return m_EdgeType.value; }
			set{ m_EdgeType.value = value;}
		}
		internal bool ApplyProperties( Material material)
		{
			if( active != false && IsActive() != false)
			{
				material.SetColor( kShaderPropertyColor, m_Color.value);
				material.SetFloat( kShaderPropertyWidth, m_Width.value);
				material.SetInt( kShaderPropertyStencilRef, Mathf.Clamp( m_StencilReference.value, 0, 255));
				material.SetInt( kShaderPropertyStencilReadMask, Mathf.Clamp( m_StencilReadMask.value, 0, 255));
				material.SetInt( kShaderPropertyStencilComp, (int)m_StencilCompare.value);
				return true;
			}
			return false;
		}
		static readonly int kShaderPropertyColor = Shader.PropertyToID( "_Color");
		static readonly int kShaderPropertyWidth = Shader.PropertyToID( "_Width");
		static readonly int kShaderPropertyStencilRef = Shader.PropertyToID( "_StencilRef");
		static readonly int kShaderPropertyStencilReadMask = Shader.PropertyToID( "_StencilReadMask");
		static readonly int kShaderPropertyStencilComp = Shader.PropertyToID( "_StencilComp");
		
		[SerializeField]
		internal EnumParameter<EdgeType> m_EdgeType = new( EdgeType.Both);
		[SerializeField]
		internal ColorParameter m_Color = new( Color.white);
		[SerializeField, Range(0, 255)]
		internal ClampedIntParameter m_Width = new( 2, 0, 5);
		[SerializeField, Range(0, 255)]
		internal ClampedIntParameter m_StencilReference = new( 0, 0, 255);
		[SerializeField, Range(0, 255)]
		internal ClampedIntParameter m_StencilReadMask = new( 255, 0, 255);
		[SerializeField]
		internal EnumParameter<CompareFunction> m_StencilCompare = new( CompareFunction.Always);
	}
}