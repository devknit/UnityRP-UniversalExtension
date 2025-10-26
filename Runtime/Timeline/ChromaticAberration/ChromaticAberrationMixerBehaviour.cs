
using UnityEngine.Playables;
using UnityEngine.Rendering.Universal;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class ChromaticAberrationMixerBehaviour : PlayableBehaviour
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
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					float blendedIntensity = 0.0f;
					float totalWeight = 0.0f;
					
					for( int i0 = 0; i0 < inputCount; ++i0)
					{
						float inputWeight = playable.GetInputWeight( i0);
						
						if( inputWeight > 0.0f)
						{
							var inputPlayable = (ScriptPlayable<ChromaticAberrationBehaviour>)playable.GetInput( i0);
							ChromaticAberrationBehaviour behaviour = inputPlayable.GetBehaviour();
							blendedIntensity += behaviour.m_Intensity * inputWeight;
							totalWeight += inputWeight;
						}
					}
					totalWeight = 1.0f - totalWeight;
					m_Volume.intensity.Override( blendedIntensity + m_DefaultIntensity.Value * totalWeight);
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultIntensity.Restore( m_Volume.intensity);
				m_Volume = null;
			}
		}
		ChromaticAberration m_Volume;
		VolumeParamT<float> m_DefaultIntensity;
	}
}
