
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class ColorFilterMixerBehaviour : PlayableBehaviour
	{
		public override void ProcessFrame( Playable playable, FrameData info, object playerData)
		{
			if( playerData is UnityEngine.Rendering.Volume volume)
			{
				if( m_Volume == null)
				{
					if( volume.profile.TryGet( out m_Volume) != false)
					{
						m_DefaultDotColor = new VolumeParamT<Color>( m_Volume.m_DotColor);
						m_DefaultMultiplyColor = new VolumeParamT<Color>( m_Volume.m_MultiplyColor);
						m_DefaultAddColor = new VolumeParamT<Color>( m_Volume.m_AddColor);
						m_DefaultContrast = new VolumeParamT<float>( m_Volume.m_Contrast);
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					Color blendedDotColor = Color.clear;
					Color blendedMultiplyColor = Color.clear;
					Color blendedAddColor = Color.clear;
					float blendedContrast = 0.0f;
					float dotColorWeight = 0.0f;
					float multiplyColorWeight = 0.0f;
					float addColorWeight = 0.0f;
					float contrastWeight = 0.0f;
					
					for( int i0 = 0; i0 < inputCount; ++i0)
					{
						float inputWeight = playable.GetInputWeight( i0);
						
						if( inputWeight > 0.0f)
						{
							var inputPlayable = (ScriptPlayable<ColorFilterBehaviour>)playable.GetInput( i0);
							inputPlayable.GetBehaviour().Blend( inputWeight, 
								ref blendedDotColor, ref dotColorWeight, 
								ref blendedMultiplyColor, ref multiplyColorWeight, 
								ref blendedAddColor, ref addColorWeight,
								ref blendedContrast, ref contrastWeight);
						}
					}
					m_Volume.m_DotColor.Override( blendedDotColor + m_DefaultDotColor.Value * (1.0f - dotColorWeight));
					m_Volume.m_MultiplyColor.Override( blendedMultiplyColor + m_DefaultMultiplyColor.Value * (1.0f - multiplyColorWeight));
					m_Volume.m_AddColor.Override( blendedAddColor + m_DefaultAddColor.Value * (1.0f - addColorWeight));
					m_Volume.m_Contrast.Override( blendedContrast + m_DefaultContrast.Value * (1.0f - contrastWeight));
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultDotColor.Restore( m_Volume.m_DotColor);
				m_DefaultMultiplyColor.Restore( m_Volume.m_MultiplyColor);
				m_DefaultAddColor.Restore( m_Volume.m_AddColor);
				m_DefaultContrast.Restore( m_Volume.m_Contrast);
				m_Volume = null;
			}
		}
		Volume.ColorFilter m_Volume;
		VolumeParamT<Color> m_DefaultDotColor;
		VolumeParamT<Color> m_DefaultMultiplyColor;
		VolumeParamT<Color> m_DefaultAddColor;
		VolumeParamT<float> m_DefaultContrast;
	}
}
