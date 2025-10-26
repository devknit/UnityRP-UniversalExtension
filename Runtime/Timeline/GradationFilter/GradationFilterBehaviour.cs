
using System;
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class GradationFilterBehaviour : PlayableBehaviour
	{
		internal void BlendMultiply( float inputWeight,
			ref Vector2 blendedOffset, ref float weightOffset,
			ref Vector2 blendedScale, ref float weightScale,
			ref float blendedRotate, ref float weightRotate,
			ref Color blendedColorLT, ref float weightColorLT,
			ref Color blendedColorRT, ref float weightColorRT,
			ref Color blendedColorLB, ref float weightColorLB,
			ref Color blendedColorRB, ref float weightColorRB)
		{
			if( m_MultiplyOffset.OverrideState != false)
			{
				blendedOffset += m_MultiplyOffset.Value * inputWeight;
				weightOffset += inputWeight;
			}
			if( m_MultiplyScale.OverrideState != false)
			{
				blendedScale += m_MultiplyScale.Value * inputWeight;
				weightScale += inputWeight;
			}
			if( m_MultiplyRotate.OverrideState != false)
			{
				blendedRotate += m_MultiplyRotate.Value * inputWeight;
				weightRotate += inputWeight;
			}
			if( m_MultiplyColorLT.OverrideState != false)
			{
				blendedColorLT += m_MultiplyColorLT.Value * inputWeight;
				weightColorLT += inputWeight;
			}
			if( m_MultiplyColorRT.OverrideState != false)
			{
				blendedColorRT += m_MultiplyColorRT.Value * inputWeight;
				weightColorRT += inputWeight;
			}
			if( m_MultiplyColorLB.OverrideState != false)
			{
				blendedColorLB += m_MultiplyColorLB.Value * inputWeight;
				weightColorLB += inputWeight;
			}
			if( m_MultiplyColorRB.OverrideState != false)
			{
				blendedColorRB += m_MultiplyColorRB.Value * inputWeight;
				weightColorRB += inputWeight;
			}
		}
		internal void BlendAdd( float inputWeight,
			ref Vector2 blendedOffset, ref float weightOffset,
			ref Vector2 blendedScale, ref float weightScale,
			ref float blendedRotate, ref float weightRotate,
			ref Color blendedColorLT, ref float weightColorLT,
			ref Color blendedColorRT, ref float weightColorRT,
			ref Color blendedColorLB, ref float weightColorLB,
			ref Color blendedColorRB, ref float weightColorRB)
		{
			if( m_AddOffset.OverrideState != false)
			{
				blendedOffset += m_AddOffset.Value * inputWeight;
				weightOffset += inputWeight;
			}
			if( m_AddScale.OverrideState != false)
			{
				blendedScale += m_AddScale.Value * inputWeight;
				weightScale += inputWeight;
			}
			if( m_AddRotate.OverrideState != false)
			{
				blendedRotate += m_AddRotate.Value * inputWeight;
				weightRotate += inputWeight;
			}
			if( m_AddColorLT.OverrideState != false)
			{
				blendedColorLT += m_AddColorLT.Value * inputWeight;
				weightColorLT += inputWeight;
			}
			if( m_AddColorRT.OverrideState != false)
			{
				blendedColorRT += m_AddColorRT.Value * inputWeight;
				weightColorRT += inputWeight;
			}
			if( m_AddColorLB.OverrideState != false)
			{
				blendedColorLB += m_AddColorLB.Value * inputWeight;
				weightColorLB += inputWeight;
			}
			if( m_AddColorRB.OverrideState != false)
			{
				blendedColorRB += m_AddColorRB.Value * inputWeight;
				weightColorRB += inputWeight;
			}
		}
		public static readonly Color kSepiaMultiply = new( 1.07f, 0.74f, 0.43f, 0.0f);
		
		[SerializeField]
		Vector2Param m_MultiplyOffset = new( Vector2.zero);
		[SerializeField]
		Vector2Param m_MultiplyScale = new( Vector2.one);
		[SerializeField]
		FloatParam m_MultiplyRotate = new( 0);
		[SerializeField]
		ColorParam m_MultiplyColorLT = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		ColorParam m_MultiplyColorRT = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		ColorParam m_MultiplyColorLB = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		ColorParam m_MultiplyColorRB = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		Vector2Param m_AddOffset = new( Vector2.zero);
		[SerializeField]
		Vector2Param m_AddScale = new( Vector2.one);
		[SerializeField]
		FloatParam m_AddRotate = new( 0);
		[SerializeField]
		ColorParam m_AddColorLT = new( Color.clear, true, true, true);
		[SerializeField]
		ColorParam m_AddColorRT = new( Color.clear, true, true, true);
		[SerializeField]
		ColorParam m_AddColorLB = new( Color.clear, true, true, true);
		[SerializeField]
		ColorParam m_AddColorRB = new( Color.clear, true, true, true);
	}
}
