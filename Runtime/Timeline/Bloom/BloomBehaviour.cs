
using System;
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class BloomBehaviour : PlayableBehaviour
	{
		internal void Blend( float inputWeight,
			ref float blendedThreshold, ref float thresholdWeight,
			ref float blendedIntensity, ref float blendedScatter,
			ref float scatterWeight, ref Color blendedTint,
			ref float tintWeight, ref float blendedClamp, ref float clampWeight)
		{
			blendedIntensity += m_Intensity * inputWeight;
			if( m_Threshold.OverrideState != false)
			{
				blendedThreshold += m_Threshold.Value * inputWeight;
				thresholdWeight += inputWeight;
			}
			if( m_Scatter.OverrideState != false)
			{
				blendedScatter += m_Scatter.Value * inputWeight;
				scatterWeight += inputWeight;
			}
			if( m_Tint.OverrideState != false)
			{
				blendedTint += m_Tint.Value * inputWeight;
				tintWeight += inputWeight;
			}
			if( m_Clamp.OverrideState != false)
			{
				blendedClamp += m_Clamp.Value * inputWeight;
				clampWeight += inputWeight;
			}
		}
		
		[SerializeField]
		MinFloatParam m_Threshold = new( 1f, 0f);
		[SerializeField, Min( 0f)]
		float m_Intensity;
		[SerializeField]
		ClampedFloatParam m_Scatter = new( 0.7f, 0f, 1f);
		[SerializeField]
		ColorParam m_Tint = new( Color.white, false, false, true);
		[SerializeField]
		MinFloatParam m_Clamp = new( 65472f, 0f);
	}
}
