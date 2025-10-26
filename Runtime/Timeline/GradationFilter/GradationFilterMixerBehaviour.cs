
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	sealed class GradationFilterMixerBehaviour : PlayableBehaviour
	{
		public override void ProcessFrame( Playable playable, FrameData info, object playerData)
		{
			if( playerData is UnityEngine.Rendering.Volume volume)
			{
				if( m_Volume == null)
				{
					if( volume.profile.TryGet( out m_Volume) != false)
					{
						m_DefaultMultiplyOffset = new VolumeParamT<Vector2>( m_Volume.m_MultiplyOffset);
						m_DefaultMultiplyScale = new VolumeParamT<Vector2>( m_Volume.m_MultiplyScale);
						m_DefaultMultiplyRotate = new VolumeParamT<float>( m_Volume.m_MultiplyRotate);
						m_DefaultMultiplyColorLT = new VolumeParamT<Color>( m_Volume.m_MultiplyColorLT);
						m_DefaultMultiplyColorRT = new VolumeParamT<Color>( m_Volume.m_MultiplyColorRT);
						m_DefaultMultiplyColorLB = new VolumeParamT<Color>( m_Volume.m_MultiplyColorLB);
						m_DefaultMultiplyColorRB = new VolumeParamT<Color>( m_Volume.m_MultiplyColorRB);
						m_DefaultAddOffset = new VolumeParamT<Vector2>( m_Volume.m_AddOffset);
						m_DefaultAddScale = new VolumeParamT<Vector2>( m_Volume.m_AddScale);
						m_DefaultAddRotate = new VolumeParamT<float>( m_Volume.m_AddRotate);
						m_DefaultAddColorLT = new VolumeParamT<Color>( m_Volume.m_AddColorLT);
						m_DefaultAddColorRT = new VolumeParamT<Color>( m_Volume.m_AddColorRT);
						m_DefaultAddColorLB = new VolumeParamT<Color>( m_Volume.m_AddColorLB);
						m_DefaultAddColorRB = new VolumeParamT<Color>( m_Volume.m_AddColorRB);
					}
				}
				if( m_Volume != null)
				{
					int inputCount = playable.GetInputCount();
					Vector2 blendedMultiplyOffset = Vector2.zero;
					Vector2 blendedMultiplyScale = Vector2.zero;
					float blendedMultiplyRotate = 0.0f;
					Color blendedMultiplyColorLT = Color.clear;
					Color blendedMultiplyColorRT = Color.clear;
					Color blendedMultiplyColorLB = Color.clear;
					Color blendedMultiplyColorRB = Color.clear;
					Vector2 blendedAddOffset = Vector2.zero;
					Vector2 blendedAddScale = Vector2.zero;
					float blendedAddRotate = 0.0f;
					Color blendedAddColorLT = Color.clear;
					Color blendedAddColorRT = Color.clear;
					Color blendedAddColorLB = Color.clear;
					Color blendedAddColorRB = Color.clear;
					float weightMultiplyOffset = 0.0f;
					float weightMultiplyScale = 0.0f;
					float weightMultiplyRotate = 0.0f;
					float weightMultiplyColorLT = 0.0f;
					float weightMultiplyColorRT = 0.0f;
					float weightMultiplyColorLB = 0.0f;
					float weightMultiplyColorRB = 0.0f;
					float weightAddOffset = 0.0f;
					float weightAddScale = 0.0f;
					float weightAddRotate = 0.0f;
					float weightAddColorLT = 0.0f;
					float weightAddColorRT = 0.0f;
					float weightAddColorLB = 0.0f;
					float weightAddColorRB = 0.0f;
					
					for( int i0 = 0; i0 < inputCount; ++i0)
					{
						float inputWeight = playable.GetInputWeight( i0);
						
						if( inputWeight > 0.0f)
						{
							var inputPlayable = (ScriptPlayable<GradationFilterBehaviour>)playable.GetInput( i0);
							GradationFilterBehaviour behaviour = inputPlayable.GetBehaviour();
							behaviour.BlendMultiply( inputWeight, 
								ref blendedMultiplyOffset, ref weightMultiplyOffset,
								ref blendedMultiplyScale, ref weightMultiplyScale,
								ref blendedMultiplyRotate, ref weightMultiplyRotate,
								ref blendedMultiplyColorLT, ref weightMultiplyColorLT,
								ref blendedMultiplyColorRT, ref weightMultiplyColorRT,
								ref blendedMultiplyColorLB, ref weightMultiplyColorLB,
								ref blendedMultiplyColorRB, ref weightMultiplyColorRB);
							behaviour.BlendAdd( inputWeight, 
								ref blendedAddOffset, ref weightAddOffset,
								ref blendedAddScale, ref weightAddScale,
								ref blendedAddRotate, ref weightAddRotate,
								ref blendedAddColorLT, ref weightAddColorLT,
								ref blendedAddColorRT, ref weightAddColorRT,
								ref blendedAddColorLB, ref weightAddColorLB,
								ref blendedAddColorRB, ref weightAddColorRB);
						}
					}
					m_Volume.m_MultiplyOffset.Override( blendedMultiplyOffset + m_DefaultMultiplyOffset.Value * (1.0f - weightMultiplyOffset));
					m_Volume.m_MultiplyScale.Override( blendedMultiplyScale + m_DefaultMultiplyScale.Value * (1.0f - weightMultiplyScale));
					m_Volume.m_MultiplyRotate.Override( blendedMultiplyRotate + m_DefaultMultiplyRotate.Value * (1.0f - weightMultiplyRotate));
					m_Volume.m_MultiplyColorLT.Override( blendedMultiplyColorLT + m_DefaultMultiplyColorLT.Value * (1.0f - weightMultiplyColorLT));
					m_Volume.m_MultiplyColorRT.Override( blendedMultiplyColorRT + m_DefaultMultiplyColorRT.Value * (1.0f - weightMultiplyColorRT));
					m_Volume.m_MultiplyColorLB.Override( blendedMultiplyColorLB + m_DefaultMultiplyColorLB.Value * (1.0f - weightMultiplyColorLB));
					m_Volume.m_MultiplyColorRB.Override( blendedMultiplyColorRB + m_DefaultMultiplyColorRB.Value * (1.0f - weightMultiplyColorRB));
					m_Volume.m_AddOffset.Override( blendedAddOffset + m_DefaultAddOffset.Value * (1.0f - weightAddOffset));
					m_Volume.m_AddScale.Override( blendedAddScale + m_DefaultAddScale.Value * (1.0f - weightAddScale));
					m_Volume.m_AddRotate.Override( blendedAddRotate + m_DefaultAddRotate.Value * (1.0f - weightAddRotate));
					m_Volume.m_AddColorLT.Override( blendedAddColorLT + m_DefaultAddColorLT.Value * (1.0f - weightAddColorLT));
					m_Volume.m_AddColorRT.Override( blendedAddColorRT + m_DefaultAddColorRT.Value * (1.0f - weightAddColorRT));
					m_Volume.m_AddColorLB.Override( blendedAddColorLB + m_DefaultAddColorLB.Value * (1.0f - weightAddColorLB));
					m_Volume.m_AddColorRB.Override( blendedAddColorRB + m_DefaultAddColorRB.Value * (1.0f - weightAddColorRB));
				}
			}
		}
		public override void OnPlayableDestroy( Playable playable)
		{
			if( m_Volume != null)
			{
				m_DefaultMultiplyOffset.Restore( m_Volume.m_MultiplyOffset);
				m_DefaultMultiplyScale.Restore( m_Volume.m_MultiplyScale);
				m_DefaultMultiplyRotate.Restore( m_Volume.m_MultiplyRotate);
				m_DefaultMultiplyColorLT.Restore( m_Volume.m_MultiplyColorLT);
				m_DefaultMultiplyColorRT.Restore( m_Volume.m_MultiplyColorRT);
				m_DefaultMultiplyColorLB.Restore( m_Volume.m_MultiplyColorLB);
				m_DefaultMultiplyColorRB.Restore( m_Volume.m_MultiplyColorRB);
				m_DefaultAddOffset.Restore( m_Volume.m_AddOffset);
				m_DefaultAddScale.Restore( m_Volume.m_AddScale);
				m_DefaultAddRotate.Restore( m_Volume.m_AddRotate);
				m_DefaultAddColorLT.Restore( m_Volume.m_AddColorLT);
				m_DefaultAddColorRT.Restore( m_Volume.m_AddColorRT);
				m_DefaultAddColorLB.Restore( m_Volume.m_AddColorLB);
				m_DefaultAddColorRB.Restore( m_Volume.m_AddColorRB);
				m_Volume = null;
			}
		}
		Volume.GradationFilter m_Volume;
		VolumeParamT<Vector2> m_DefaultMultiplyOffset;
		VolumeParamT<Vector2> m_DefaultMultiplyScale;
		VolumeParamT<float> m_DefaultMultiplyRotate;
		VolumeParamT<Color> m_DefaultMultiplyColorLT;
		VolumeParamT<Color> m_DefaultMultiplyColorRT;
		VolumeParamT<Color> m_DefaultMultiplyColorLB;
		VolumeParamT<Color> m_DefaultMultiplyColorRB;
		VolumeParamT<Vector2> m_DefaultAddOffset;
		VolumeParamT<Vector2> m_DefaultAddScale;
		VolumeParamT<float> m_DefaultAddRotate;
		VolumeParamT<Color> m_DefaultAddColorLT;
		VolumeParamT<Color> m_DefaultAddColorRT;
		VolumeParamT<Color> m_DefaultAddColorLB;
		VolumeParamT<Color> m_DefaultAddColorRB;
	}
}
