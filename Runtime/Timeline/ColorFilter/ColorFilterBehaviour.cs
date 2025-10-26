
using System;
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class ColorFilterBehaviour : PlayableBehaviour
	{
		internal void Blend( float inputWeight,
			ref Color blendedDotColor, ref float dotColorWeight,
			ref Color blendedMultiplyColor, ref float multiplyColorWeight,
			ref Color blendedAddColor, ref float addColorWeight,
			ref float blendedContrast, ref float contrastWeight)
		{
			if( m_DotColor.OverrideState != false)
			{
				blendedDotColor += m_DotColor.Value * inputWeight;
				dotColorWeight += inputWeight;
			}
			if( m_MultiplyColor.OverrideState != false)
			{
				blendedMultiplyColor += m_MultiplyColor.Value * inputWeight;
				multiplyColorWeight += inputWeight;
			}
			if( m_AddColor.OverrideState != false)
			{
				blendedAddColor += m_AddColor.Value * inputWeight;
				addColorWeight += inputWeight;
			}
			if( m_Contrast.OverrideState != false)
			{
				blendedContrast += m_Contrast.Value * inputWeight;
				contrastWeight += inputWeight;
			}
		}
		public static readonly Color kMonochromeDot = new( 0.298912f, 0.586611f, 0.114478f, 0.0f);
		public static readonly Color kSepiaMultiply = new( 1.07f, 0.74f, 0.43f, 0.0f);
		
		[SerializeField]
		ColorParam m_DotColor = new( kMonochromeDot, true, true, true);
		[SerializeField]
		ColorParam m_MultiplyColor = new( kSepiaMultiply, true, true, true);
		[SerializeField]
		ColorParam m_AddColor = new( Color.clear, true, true, true);
		[SerializeField]
		ClampedFloatParam m_Contrast = new( 1.0f, -5.0f, 5.0f);
	}
}
