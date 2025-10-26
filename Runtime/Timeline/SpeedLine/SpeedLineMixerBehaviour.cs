
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class SpeedLineMixerBehaviour : PlayableBehaviour
	{
		internal void Initialize( Volume.SpeedLine.Pattern pattern)
		{
			m_Pattern = pattern;
		}
		public override void ProcessFrame( Playable playable, FrameData info, object playerData)
		{
			if( playerData is UnityEngine.Rendering.Volume volume)
			{
				if( m_Volume == null)
				{
					if( volume.profile.TryGet( out m_Volume) != false)
					{
						m_DefaultPattern = new VolumeParamT<Volume.SpeedLine.Pattern>( m_Volume.m_Pattern);
						m_Volume.m_Pattern.Override( m_Pattern);
						m_DefaultColor = new VolumeParamT<Color>( m_Volume.m_Color);
						m_DefaultCenter = new VolumeParamT<Vector2>( m_Volume.m_Center);
						m_DefaultAxisMask = new VolumeParamT<Vector2>( m_Volume.m_AxisMask);
						m_DefaultRotate = new VolumeParamT<float>( m_Volume.m_Rotate);
						m_DefaultTiling = new VolumeParamT<float>( m_Volume.m_Tiling);
						m_DefaultSparse = new VolumeParamT<float>( m_Volume.m_Sparse);
						m_DefaultRemap = new VolumeParamT<float>( m_Volume.m_Remap);
						m_DefaultRadialScale = new VolumeParamT<float>( m_Volume.m_RadialScale);
						m_DefaultSmoothWidth = new VolumeParamT<float>( m_Volume.m_SmoothWidth);
						m_DefaultSmoothBorder = new VolumeParamT<float>( m_Volume.m_SmoothBorder);
						m_DefaultTimeScale = new VolumeParamT<float>( m_Volume.m_TimeScale);
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					Color blendedColor = Color.clear;
					Vector2 blendedCenter = Vector2.zero;
					Vector2 blendedAxisMask = Vector2.zero;
					float blendedRotate = 0;
					float blendedTiling = 0;
					float blendedSparse = 0;
					float blendedRemap = 0;
					float blendedRadialScale = 0;
					float blendedSmoothWidth = 0;
					float blendedSmoothBorder = 0;
					float blendedTimeScale = 0;
					float centerWeight = 0;
					float axisMaskWeight = 0;
					float rotateWeight = 0;
					float tilingWeight = 0;
					float sparseWeight = 0;
					float remapWeight = 0;
					float radialScaleWeight = 0;
					float smoothWidthWeight = 0;
					float smoothBorderWeight = 0;
					float timeScaleWeight = 0;
					float totalWeight = 0;
					
					for( int i0 = 0; i0 < inputCount; ++i0)
					{
						float inputWeight = playable.GetInputWeight( i0);
						
						if( inputWeight > 0.0f)
						{
							var inputPlayable = (ScriptPlayable<SpeedLineBehaviour>)playable.GetInput( i0);
							inputPlayable.GetBehaviour().Blend( inputWeight, ref blendedColor,
								ref blendedCenter, ref centerWeight,
								ref blendedAxisMask, ref axisMaskWeight,
								ref blendedRotate, ref rotateWeight,
								ref blendedTiling, ref tilingWeight,
								ref blendedSparse, ref sparseWeight,
								ref blendedRemap, ref remapWeight,
								ref blendedRadialScale, ref radialScaleWeight,
								ref blendedSmoothWidth, ref smoothWidthWeight,
								ref blendedSmoothBorder, ref smoothBorderWeight,
								ref blendedTimeScale, ref timeScaleWeight);
							totalWeight += inputWeight;
						}
					}
					m_Volume.m_Color.Override( blendedColor + m_DefaultColor.Value * (1.0f - totalWeight));
					m_Volume.m_Center.Override( blendedCenter + m_DefaultCenter.Value * (1.0f - centerWeight));
					m_Volume.m_AxisMask.Override( blendedAxisMask + m_DefaultAxisMask.Value * (1.0f - axisMaskWeight));
					m_Volume.m_Rotate.Override( blendedRotate + m_DefaultRotate.Value * (1.0f - rotateWeight));
					m_Volume.m_Tiling.Override( blendedTiling + m_DefaultTiling.Value * (1.0f - tilingWeight));
					m_Volume.m_Sparse.Override( blendedSparse + m_DefaultSparse.Value * (1.0f - sparseWeight));
					m_Volume.m_Remap.Override( blendedRemap + m_DefaultRemap.Value * (1.0f - remapWeight));
					m_Volume.m_RadialScale.Override( blendedRadialScale + m_DefaultRadialScale.Value * (1.0f - radialScaleWeight));
					m_Volume.m_SmoothWidth.Override( blendedSmoothWidth + m_DefaultSmoothWidth.Value * (1.0f - smoothWidthWeight));
					m_Volume.m_SmoothBorder.Override( blendedSmoothBorder + m_DefaultSmoothBorder.Value * (1.0f - smoothBorderWeight));
					m_Volume.m_TimeScale.Override( blendedTimeScale + m_DefaultTimeScale.Value * (1.0f - timeScaleWeight));
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultPattern.Restore( m_Volume.m_Pattern);
				m_DefaultColor.Restore( m_Volume.m_Color);
				m_DefaultCenter.Restore( m_Volume.m_Center);
				m_DefaultAxisMask.Restore( m_Volume.m_AxisMask);
				m_DefaultRotate.Restore( m_Volume.m_Rotate);
				m_DefaultTiling.Restore( m_Volume.m_Tiling);
				m_DefaultSparse.Restore( m_Volume.m_Sparse);
				m_DefaultRemap.Restore( m_Volume.m_Remap);
				m_DefaultRadialScale.Restore( m_Volume.m_RadialScale);
				m_DefaultSmoothWidth.Restore( m_Volume.m_SmoothWidth);
				m_DefaultSmoothBorder.Restore( m_Volume.m_SmoothBorder);
				m_DefaultTimeScale.Restore( m_Volume.m_TimeScale);
				m_Volume = null;
			}
		}
		Volume.SpeedLine m_Volume;
		Volume.SpeedLine.Pattern m_Pattern;
		VolumeParamT<Volume.SpeedLine.Pattern> m_DefaultPattern;
		VolumeParamT<Color> m_DefaultColor;
		VolumeParamT<Vector2> m_DefaultCenter;
		VolumeParamT<Vector2> m_DefaultAxisMask;
		VolumeParamT<float> m_DefaultRotate;
		VolumeParamT<float> m_DefaultTiling;
		VolumeParamT<float> m_DefaultSparse;
		VolumeParamT<float> m_DefaultRemap;
		VolumeParamT<float> m_DefaultRadialScale;
		VolumeParamT<float> m_DefaultSmoothWidth;
		VolumeParamT<float> m_DefaultSmoothBorder;
		VolumeParamT<float> m_DefaultTimeScale;
	}
}
