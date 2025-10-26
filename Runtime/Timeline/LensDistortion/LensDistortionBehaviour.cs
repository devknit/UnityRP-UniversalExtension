
using System;
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class LensDistortionBehaviour : PlayableBehaviour
	{
		internal void Blend( float inputWeight,
			ref float blendedIntensity, ref float blendedMultiplierX,
			ref float multiplierXWeight, ref float blendedMultiplierY,
			ref float multiplierYWeight, ref Vector2 blendedCenter,
			ref float centerWeight, ref float blendedScale, ref float scaleWeight)
		{
			blendedIntensity += m_Intensity * inputWeight;
			if( m_MultiplierX.OverrideState != false)
			{
				blendedMultiplierX += m_MultiplierX.Value * inputWeight;
				multiplierXWeight += inputWeight;
			}
			if( m_MultiplierY.OverrideState != false)
			{
				blendedMultiplierY += m_MultiplierY.Value * inputWeight;
				multiplierYWeight += inputWeight;
			}
			if( m_Center.OverrideState != false)
			{
				blendedCenter += m_Center.Value * inputWeight;
				centerWeight += inputWeight;
			}
			if( m_Scale.OverrideState != false)
			{
				blendedScale += m_Scale.Value * inputWeight;
				scaleWeight += inputWeight;
			}
		}
		[SerializeField, Range( -1.0f, 1.0f)]
		float m_Intensity;
		[SerializeField]
		ClampedFloatParam m_MultiplierX = new( 1f, 0f, 1f);
		[SerializeField]
		ClampedFloatParam m_MultiplierY = new( 1f, 0f, 1f);
		[SerializeField]
		Vector2Param m_Center = new( new Vector2(0.5f, 0.5f));
		[SerializeField]
		ClampedFloatParam m_Scale = new( 1f, 0.01f, 5f);
	}
}
