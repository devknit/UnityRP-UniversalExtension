
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering.Universal;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class VignetteMixerBehaviour : PlayableBehaviour
	{
		public override void ProcessFrame( Playable playable, FrameData info, object playerData)
		{
			if( playerData is UnityEngine.Rendering.Volume volume)
			{
				if( m_Volume == null)
				{
					if( volume.profile.TryGet( out m_Volume) != false)
					{
						m_DefaultColor = new VolumeParamT<Color>( m_Volume.color);
						m_DefaultCenter = new VolumeParamT<Vector2>( m_Volume.center);
						m_DefaultIntensity = new VolumeParamT<float>( m_Volume.intensity);
						m_DefaultSmoothness = new VolumeParamT<float>( m_Volume.smoothness);
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					Color blendedColor = Color.clear;
					Vector2 blendedCenter = Vector2.zero;
					float blendedIntensity = 0.0f;
					float blendedSmoothness = 0.0f;
					float colorWeight = 0.0f;
					float centerWeight = 0.0f;
					float smoothnessWeight = 0.0f;
					float totalWeight = 0.0f;
					
					for( int i0 = 0; i0 < inputCount; ++i0)
					{
						float inputWeight = playable.GetInputWeight( i0);
						
						if( inputWeight > 0.0f)
						{
							var inputPlayable = (ScriptPlayable<VignetteBehaviour>)playable.GetInput( i0);
							inputPlayable.GetBehaviour().Blend( 
								inputWeight, ref blendedColor, 
								ref colorWeight, ref blendedCenter, 
								ref centerWeight, ref blendedIntensity, 
								ref blendedSmoothness, ref smoothnessWeight);
							totalWeight += inputWeight;
						}
					}
					m_Volume.color.Override( blendedColor + m_DefaultColor.Value * (1.0f - colorWeight));
					m_Volume.center.Override( blendedCenter + m_DefaultCenter.Value * (1.0f - centerWeight));
					m_Volume.intensity.Override( blendedIntensity + m_DefaultIntensity.Value * (1.0f - totalWeight));
					m_Volume.smoothness.Override( blendedSmoothness + m_DefaultSmoothness.Value * (1.0f - smoothnessWeight));
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultColor.Restore( m_Volume.color);
				m_DefaultCenter.Restore( m_Volume.center);
				m_DefaultIntensity.Restore( m_Volume.intensity);
				m_DefaultSmoothness.Restore( m_Volume.smoothness);
				m_Volume = null;
			}
		}
		Vignette m_Volume;
		VolumeParamT<Color> m_DefaultColor;
		VolumeParamT<Vector2> m_DefaultCenter;
		VolumeParamT<float> m_DefaultIntensity;
		VolumeParamT<float> m_DefaultSmoothness;
	}
}
