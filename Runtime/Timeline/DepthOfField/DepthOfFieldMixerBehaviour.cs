
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering.Universal;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class DepthOfFieldMixerBehaviour : PlayableBehaviour
	{
		internal void Initialize( ModeVolume modeVolume)
		{
			m_ModeVolume = modeVolume;
		}
		public override void ProcessFrame( Playable playable, FrameData info, object playerData)
		{
			if( playerData is UnityEngine.Rendering.Volume volume)
			{
				if( m_Volume == null)
				{
					if( volume.profile.TryGet( out m_Volume) != false)
					{
						m_DefaultMode = new VolumeParamT<DepthOfFieldMode>(m_Volume.mode);
						m_DefaultGaussianStart = new VolumeParamT<float>(m_Volume.gaussianStart);
						m_DefaultGaussianEnd = new VolumeParamT<float>(m_Volume.gaussianEnd);
						m_DefaultGaussianMaxRadius = new VolumeParamT<float>(m_Volume.gaussianMaxRadius);
						m_DefaultFocusDistance = new VolumeParamT<float>(m_Volume.focusDistance);
						m_DefaultFocalLength = new VolumeParamT<float>(m_Volume.focalLength);
						m_DefaultAperture = new VolumeParamT<float>(m_Volume.aperture);
						m_DefaultBladeCount = new VolumeParamT<int>(m_Volume.bladeCount);
						m_DefaultBladeCurvature = new VolumeParamT<float>(m_Volume.bladeCurvature);
						m_DefaultBladeRotation = new VolumeParamT<float>(m_Volume.bladeRotation);
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					float totalWeight = 0.0f;
					switch( m_ModeVolume)
					{
						case ModeVolume.Gaussian:
						{
							float blendedGaussianStart = 0.0f;
							float blendedGaussianEnd = 0.0f;
							float blendedGaussianMaxRadius = 0.0f;
							float gaussianStartWeight = 0.0f;
							float gaussianEndWeight = 0.0f;
							float gaussianMaxRadiusWeight = 0.0f;
							
							for( int i0 = 0; i0 < inputCount; ++i0)
							{
								float inputWeight = playable.GetInputWeight( i0);
								
								if( inputWeight > 0.0f)
								{
									var inputPlayable = (ScriptPlayable<DepthOfFieldBehaviour>)playable.GetInput( i0);
									DepthOfFieldBehaviour behaviour = inputPlayable.GetBehaviour();
									behaviour.BlendGaussian( inputWeight, ref blendedGaussianStart, ref gaussianStartWeight, ref blendedGaussianEnd, 
										ref gaussianEndWeight, ref blendedGaussianMaxRadius, ref gaussianMaxRadiusWeight);
									totalWeight += inputWeight;
								}
							}
							
							m_Volume.mode.Override( totalWeight > 0f ? DepthOfFieldMode.Gaussian : m_DefaultMode.Value);
							m_Volume.gaussianStart.Override( blendedGaussianStart + m_DefaultGaussianStart.Value * (1f - gaussianStartWeight));
							m_Volume.gaussianEnd.Override( blendedGaussianEnd + m_DefaultGaussianEnd.Value * (1f - gaussianEndWeight));
							m_Volume.gaussianMaxRadius.Override( blendedGaussianMaxRadius + m_DefaultGaussianMaxRadius.Value * (1f - gaussianMaxRadiusWeight));
							break;
						}
						case ModeVolume.Bokeh:
						{
							float blendedFocusDistance = 0.0f;
							float blendedFocalLength = 0.0f;
							float blendedAperture = 0.0f;
							float blendedBladeCount = 0;
							float blendedBladeCurvature = 0.0f;
							float blendedBladeRotation = 0.0f;
							float focusDistanceWeight = 0.0f;
							float focalLengthWeight = 0.0f;
							float apertureWeight = 0.0f;
							float bladeCountWeight = 0.0f;
							float bladeCurvatureWeight = 0.0f;
							float bladeRotationWeight = 0.0f;
							
							for( int i0 = 0; i0 < inputCount; ++i0)
							{
								float inputWeight = playable.GetInputWeight( i0);
								
								if( inputWeight > 0.0f)
								{
									var inputPlayable = (ScriptPlayable<DepthOfFieldBehaviour>)playable.GetInput( i0);
									DepthOfFieldBehaviour behaviour = inputPlayable.GetBehaviour();
									behaviour.BlendBokeh( inputWeight, ref blendedFocusDistance, ref focusDistanceWeight, ref blendedFocalLength, 
										ref focalLengthWeight, ref blendedAperture, ref apertureWeight, ref blendedBladeCount, ref bladeCountWeight,
										ref blendedBladeCurvature, ref bladeCurvatureWeight, ref blendedBladeRotation, ref bladeRotationWeight);
									totalWeight += inputWeight;
								}
							}
							
							m_Volume.mode.Override( totalWeight > 0f ? DepthOfFieldMode.Bokeh : m_DefaultMode.Value);
							m_Volume.focusDistance.Override( blendedFocusDistance + m_DefaultFocusDistance.Value * (1f - focusDistanceWeight));
							m_Volume.focalLength.Override( blendedFocalLength + m_DefaultFocalLength.Value * (1f - focalLengthWeight));
							m_Volume.aperture.Override( blendedAperture + m_DefaultAperture.Value * (1f - apertureWeight));
							m_Volume.bladeCount.Override( Mathf.RoundToInt(blendedBladeCount + m_DefaultBladeCount.Value * (1f - bladeCountWeight)));
							m_Volume.bladeCurvature.Override( blendedBladeCurvature + m_DefaultBladeCurvature.Value * (1f - bladeCurvatureWeight));
							m_Volume.bladeRotation.Override( blendedBladeRotation + m_DefaultBladeRotation.Value * (1f - bladeRotationWeight));
							break;
						}
					}
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultMode.Restore( m_Volume.mode);
				m_DefaultGaussianStart.Restore( m_Volume.gaussianStart);
				m_DefaultGaussianEnd.Restore( m_Volume.gaussianEnd);
				m_DefaultGaussianMaxRadius.Restore( m_Volume.gaussianMaxRadius);
				m_DefaultFocusDistance.Restore( m_Volume.focusDistance);
				m_DefaultFocalLength.Restore( m_Volume.focalLength);
				m_DefaultAperture.Restore( m_Volume.aperture);
				m_DefaultBladeCount.Restore( m_Volume.bladeCount);
				m_DefaultBladeCurvature.Restore( m_Volume.bladeCurvature);
				m_DefaultBladeRotation.Restore( m_Volume.bladeRotation);
				m_Volume = null;
			}
		}
		DepthOfField m_Volume;
		VolumeParamT<DepthOfFieldMode> m_DefaultMode;
		VolumeParamT<float> m_DefaultGaussianStart;
		VolumeParamT<float> m_DefaultGaussianEnd;
		VolumeParamT<float> m_DefaultGaussianMaxRadius;
		VolumeParamT<float> m_DefaultFocusDistance;
		VolumeParamT<float> m_DefaultFocalLength;
		VolumeParamT<float> m_DefaultAperture;
		VolumeParamT<int> m_DefaultBladeCount;
		VolumeParamT<float> m_DefaultBladeCurvature;
		VolumeParamT<float> m_DefaultBladeRotation;
		ModeVolume m_ModeVolume;
	}
	internal enum ModeVolume
	{
		Gaussian,
		Bokeh,
	}
}
