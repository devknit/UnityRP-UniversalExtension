
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering.Universal;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class ColorAdjustmentsMixerBehaviour : PlayableBehaviour
	{
		public override void ProcessFrame( Playable playable, FrameData info, object playerData)
		{
			if( playerData is UnityEngine.Rendering.Volume volume)
			{
				if( m_Volume == null)
				{
					if( volume.profile.TryGet( out m_Volume) != false)
					{
						m_DefaultPostExposure = new VolumeParamT<float>( m_Volume.postExposure);
						m_DefaultContrast = new VolumeParamT<float>( m_Volume.contrast);
						m_DefaultColorFilter = new VolumeParamT<Color>( m_Volume.colorFilter);
						m_DefaultHueShift = new VolumeParamT<float>( m_Volume.hueShift);
						m_DefaultSaturation = new VolumeParamT<float>( m_Volume.saturation);
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					float blendedPostExposure = 0.0f;
					float blendedContrast = 0.0f;
					Color blendedColorFilter = Color.clear;
					float blendedHueShift = 0.0f;
					float blendedSaturation = 0.0f;
					float weightPostExposure = 0.0f;
					float weightContrast = 0.0f;
					float weightColorFilter = 0.0f;
					float weightHueShift = 0.0f;
					float weightSaturation = 0.0f;
					
					for( int i0 = 0; i0 < inputCount; ++i0)
					{
						float inputWeight = playable.GetInputWeight( i0);
						
						if( inputWeight > 0.0f)
						{
							var inputPlayable = (ScriptPlayable<ColorAdjustmentsBehaviour>)playable.GetInput( i0);
							inputPlayable.GetBehaviour().Blend( inputWeight, 
								ref blendedPostExposure, ref weightPostExposure,
								ref blendedContrast, ref weightContrast,
								ref blendedColorFilter, ref weightColorFilter,
								ref blendedHueShift, ref weightHueShift,
								ref blendedSaturation, ref weightSaturation);
						}
					}
					m_Volume.postExposure.Override( blendedPostExposure + m_DefaultPostExposure.Value * (1.0f - weightPostExposure));
					m_Volume.contrast.Override( blendedContrast + m_DefaultContrast.Value * (1.0f - weightContrast));
					m_Volume.colorFilter.Override( blendedColorFilter + m_DefaultColorFilter.Value * (1.0f - weightColorFilter));
					m_Volume.hueShift.Override( blendedHueShift + m_DefaultHueShift.Value * (1.0f - weightHueShift));
					m_Volume.saturation.Override( blendedSaturation + m_DefaultSaturation.Value * (1.0f - weightSaturation));
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultPostExposure.Restore( m_Volume.postExposure);
				m_DefaultContrast.Restore( m_Volume.contrast);
				m_DefaultColorFilter.Restore( m_Volume.colorFilter);
				m_DefaultHueShift.Restore( m_Volume.hueShift);
				m_DefaultSaturation.Restore( m_Volume.saturation);
				m_Volume = null;
			}
		}
		ColorAdjustments m_Volume;
		VolumeParamT<float> m_DefaultPostExposure;
		VolumeParamT<float> m_DefaultContrast;
		VolumeParamT<Color> m_DefaultColorFilter;
		VolumeParamT<float> m_DefaultHueShift;
		VolumeParamT<float> m_DefaultSaturation;
	}
}
