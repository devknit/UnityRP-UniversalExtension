
using System;
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class ColorAdjustmentsBehaviour : PlayableBehaviour
	{
		internal void Blend( float inputWeight,
			ref float blendedPostExposure, ref float weightPostExposure,
			ref float blendedContrast, ref float weightContrast,
			ref Color blendedColorFilter, ref float weightColorFilter,
			ref float blendedHueShift, ref float weightHueShift,
			ref float blendedSaturation, ref float weightSaturation)
		{
			if( m_PostExposure.OverrideState != false)
			{
				blendedPostExposure += m_PostExposure.Value * inputWeight;
				weightPostExposure += inputWeight;
			}
			if( m_Contrast.OverrideState != false)
			{
				blendedContrast += m_Contrast.Value * inputWeight;
				weightContrast += inputWeight;
			}
			if( m_ColorFilter.OverrideState != false)
			{
				blendedColorFilter += m_ColorFilter.Value * inputWeight;
				weightColorFilter += inputWeight;
			}
			if( m_HueShift.OverrideState != false)
			{
				blendedHueShift += m_HueShift.Value * inputWeight;
				weightHueShift += inputWeight;
			}
			if( m_Saturation.OverrideState != false)
			{
				blendedSaturation += m_Saturation.Value * inputWeight;
				weightSaturation += inputWeight;
			}
		}
		[SerializeField]
		FloatParam m_PostExposure = new( 0);
		[SerializeField]
		ClampedFloatParam m_Contrast = new( 0, -100, 100);
		[SerializeField]
		ColorParam m_ColorFilter = new( Color.white, true, false, true);
		[SerializeField]
		ClampedFloatParam m_HueShift = new( 0, -180, 180);
		[SerializeField]
		ClampedFloatParam m_Saturation = new( 0, -100, 100);
	}
}
