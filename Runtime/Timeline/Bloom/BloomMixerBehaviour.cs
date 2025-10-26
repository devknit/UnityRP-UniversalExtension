
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering.Universal;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class BloomMixerBehaviour : PlayableBehaviour
	{
		public override void ProcessFrame( Playable playable, FrameData info, object playerData)
		{
			if( playerData is UnityEngine.Rendering.Volume volume)
			{
				if( m_Volume == null)
				{
					if( volume.profile.TryGet( out m_Volume) != false)
					{
						m_DefaultThreshold = new VolumeParamT<float>( m_Volume.threshold);
						m_DefaultIntensity = new VolumeParamT<float>( m_Volume.intensity);
						m_DefaultScatter = new VolumeParamT<float>( m_Volume.scatter);
						m_DefaultTint = new VolumeParamT<Color>( m_Volume.tint);
						m_DefaultClamp = new VolumeParamT<float>( m_Volume.clamp);
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					float blendedThreshold = 0.0f;
					float blendedIntensity = 0.0f;
					float blendedScatter = 0.0f;
					Color blendedTint = Color.black;
					float blendedClamp = 0.0f;
					float totalWeight = 0.0f;
					float thresholdWeight = 0.0f;
					float scatterWeight = 0.0f;
					float tintWeight = 0.0f;
					float clampWeight = 0.0f;
					
					for( int i0 = 0; i0 < inputCount; ++i0)
					{
						float inputWeight = playable.GetInputWeight( i0);
						
						if( inputWeight > 0.0f)
						{
							var inputPlayable = (ScriptPlayable<BloomBehaviour>)playable.GetInput( i0);
							BloomBehaviour behaviour = inputPlayable.GetBehaviour();
							behaviour.Blend( inputWeight, ref blendedThreshold, ref thresholdWeight, ref blendedIntensity,
								ref blendedScatter, ref scatterWeight, ref blendedTint, ref tintWeight, ref blendedClamp, ref clampWeight);
							
							totalWeight += inputWeight;
						}
					}
					totalWeight = 1.0f - totalWeight;
					m_Volume.threshold.Override( blendedThreshold + m_DefaultThreshold.Value * (1f - thresholdWeight));
					m_Volume.intensity.Override( blendedIntensity + m_DefaultIntensity.Value * totalWeight);
					m_Volume.scatter.Override( blendedScatter + m_DefaultScatter.Value * (1f - scatterWeight));
					m_Volume.tint.Override( blendedTint + m_DefaultTint.Value * (1f - tintWeight));
					m_Volume.clamp.Override( blendedClamp + m_DefaultClamp.Value * (1f - clampWeight));
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultThreshold.Restore( m_Volume.threshold);
				m_DefaultIntensity.Restore( m_Volume.intensity);
				m_DefaultScatter.Restore( m_Volume.scatter);
				m_DefaultTint.Restore( m_Volume.tint);
				m_DefaultClamp.Restore( m_Volume.clamp);
				m_Volume = null;
			}
		}
		Bloom m_Volume;
		VolumeParamT<float> m_DefaultThreshold;
		VolumeParamT<float> m_DefaultIntensity;
		VolumeParamT<float> m_DefaultScatter;
		VolumeParamT<Color> m_DefaultTint;
		VolumeParamT<float> m_DefaultClamp;
	}
}
