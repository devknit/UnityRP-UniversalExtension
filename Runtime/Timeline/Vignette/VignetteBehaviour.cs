
using System;
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class VignetteBehaviour : PlayableBehaviour
	{
		internal void Blend( float inputWeight,
			ref Color blendedColor, ref float colorWeight,
			ref Vector2 blendedCenter, ref float centerWeight,
			ref float blendedIntensity, ref float blendedSmoothness,
			ref float smoothnessWeight)
		{
			if( m_Color.OverrideState != false)
			{
				blendedColor += m_Color.Value * inputWeight;
				colorWeight += inputWeight;
			}
			if( m_Center.OverrideState != false)
			{
				blendedCenter += m_Center.Value * inputWeight;
				centerWeight += inputWeight;
			}
			blendedIntensity += m_Intensity * inputWeight;
			
			if( m_Smoothness.OverrideState != false)
			{
				blendedSmoothness += m_Smoothness.Value * inputWeight;
				smoothnessWeight += inputWeight;
			}
		}
		[SerializeField]
		ColorParam m_Color = new( Color.clear, false, false, false);
		[SerializeField]
		Vector2Param m_Center = new( new Vector2( 0.5f, 0.5f), false);
		[SerializeField, Range( 0.0f, 1.0f)]
		float m_Intensity = 0.0f;
		[SerializeField]
		ClampedFloatParam m_Smoothness = new( 0.2f, 0.0f, 1.0f, false);
	}
}
