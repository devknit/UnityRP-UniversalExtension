
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering.Universal;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class LensDistortionMixerBehaviour : PlayableBehaviour
	{
		public override void ProcessFrame( Playable playable, FrameData info, object playerData)
		{
			if( playerData is UnityEngine.Rendering.Volume volume)
			{
				if( m_Volume == null)
				{
					if( volume.profile.TryGet( out m_Volume) != false)
					{
						m_DefaultIntensity = new VolumeParamT<float>( m_Volume.intensity);
						m_DefaultMultiplierX = new VolumeParamT<float>( m_Volume.xMultiplier);
						m_DefaultMultiplierY = new VolumeParamT<float>( m_Volume.yMultiplier);
						m_DefaultCenter = new VolumeParamT<Vector2>( m_Volume.center);
						m_DefaultScale = new VolumeParamT<float>( m_Volume.scale);
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					float blendedIntensity = 0.0f;
					float blendedMultiplierX = 0.0f;
					float blendedMultiplierY = 0.0f;
					Vector2 blendedCenter = Vector2.zero;
					float blendedScale = 0.0f;
					float totalWeight = 0.0f;
					float multiplierXWeight = 0.0f;
					float multiplierYWeight = 0.0f;
					float centerWeight = 0.0f;
					float scaleWeight = 0.0f;
					
					for( int i0 = 0; i0 < inputCount; ++i0)
					{
						float inputWeight = playable.GetInputWeight( i0);
						
						if( inputWeight > 0.0f)
						{
							var inputPlayable = (ScriptPlayable<LensDistortionBehaviour>)playable.GetInput( i0);
							LensDistortionBehaviour behaviour = inputPlayable.GetBehaviour();
							behaviour.Blend( inputWeight, ref blendedIntensity, ref blendedMultiplierX, ref multiplierXWeight,
								ref blendedMultiplierY, ref multiplierYWeight, ref blendedCenter, ref centerWeight, ref blendedScale, ref scaleWeight);
							
							totalWeight += inputWeight;
						}
					}
					totalWeight = 1.0f - totalWeight;
					m_Volume.intensity.Override( blendedIntensity + m_DefaultIntensity.Value * totalWeight);
					m_Volume.xMultiplier.Override( blendedMultiplierX + m_DefaultMultiplierX.Value * (1f - multiplierXWeight));
					m_Volume.yMultiplier.Override( blendedMultiplierY + m_DefaultMultiplierY.Value * (1f - multiplierYWeight));
					m_Volume.center.Override( blendedCenter + m_DefaultCenter.Value * (1f - centerWeight));
					m_Volume.scale.Override( blendedScale + m_DefaultScale.Value * (1f - scaleWeight));
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultIntensity.Restore( m_Volume.intensity);
				m_DefaultMultiplierX.Restore( m_Volume.xMultiplier);
				m_DefaultMultiplierY.Restore( m_Volume.yMultiplier);
				m_DefaultCenter.Restore( m_Volume.center);
				m_DefaultScale.Restore( m_Volume.scale);
				m_Volume = null;
			}
		}
		LensDistortion m_Volume;
		VolumeParamT<float> m_DefaultIntensity;
		VolumeParamT<float> m_DefaultMultiplierX;
		VolumeParamT<float> m_DefaultMultiplierY;
		VolumeParamT<Vector2> m_DefaultCenter;
		VolumeParamT<float> m_DefaultScale;
	}
}
