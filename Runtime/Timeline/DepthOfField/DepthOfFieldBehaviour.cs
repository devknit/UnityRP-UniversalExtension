
using System;
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class DepthOfFieldBehaviour : PlayableBehaviour
	{
		internal void Initialize( Transform target, Camera camera)
		{
			m_Target = target;
			m_Camera = camera?.transform;
		#if UNITY_EDITOR
			bool unlock = m_Target != null && m_Camera != null;
			m_FocusDistance.SetUnlockLimit( unlock);
			m_Start.SetUnlockLimit( unlock);
			m_End.SetUnlockLimit( unlock);
		#endif
		}
		internal void BlendGaussian( float inputWeight,
			ref float blendedGaussianStart, ref float gaussianStartWeight,
			ref float blendedGaussianEnd, ref float gaussianEndWeight,
			ref float blendedGaussianMaxRadius, ref float gaussianMaxRadiusWeight)
		{
			if( m_Target != null && m_Camera != null)
			{
				float depthBlendWeight = GetDepth( m_Target, m_Camera) * inputWeight;
				blendedGaussianStart += depthBlendWeight;
				blendedGaussianEnd += depthBlendWeight;
				gaussianStartWeight += inputWeight;
				gaussianEndWeight += inputWeight;
				if( m_Start.OverrideState != false)
				{
					blendedGaussianStart += m_Start.Value * inputWeight;
				}
				if( m_End.OverrideState != false)
				{
					blendedGaussianEnd += m_End.Value * inputWeight;
				}
			}
			else
			{
				if( m_Start.OverrideState != false)
				{
					blendedGaussianStart += m_Start.Value * inputWeight;
					gaussianStartWeight += inputWeight;
				}
				if( m_End.OverrideState != false)
				{
					blendedGaussianEnd += m_End.Value * inputWeight;
					gaussianEndWeight += inputWeight;
				}
			}
			if( m_MaxRadius.OverrideState != false)
			{
				blendedGaussianMaxRadius += m_MaxRadius.Value * inputWeight;
				gaussianMaxRadiusWeight += inputWeight;
			}
		}
		internal void BlendBokeh( float inputWeight,
			ref float blendedFocusDistance, ref float focusDistanceWeight,
			ref float blendedFocalLength, ref float focalLengthWeight,
			ref float blendedAperture, ref float apertureWeight,
			ref float  blendedBladeCount, ref float bladeCountWeight,
			ref float blendedBladeCurvature, ref float bladeCurvatureWeight,
			ref float blendedBladeRotation, ref float bladeRotationWeight)
		{
			if( m_Target != null && m_Camera != null)
			{
				blendedFocusDistance += GetDepth( m_Target, m_Camera) * inputWeight;
				focusDistanceWeight += inputWeight;
				if( m_FocusDistance.OverrideState != false)
				{
					blendedFocusDistance += m_FocusDistance.Value * inputWeight;
				}
			}
			else
			{
				if( m_FocusDistance.OverrideState != false)
				{
					blendedFocusDistance += m_FocusDistance.Value * inputWeight;
					focusDistanceWeight += inputWeight;
				}
			}
			if( m_FocalLength.OverrideState != false)
			{
				blendedFocalLength += m_FocalLength.Value * inputWeight;
				focalLengthWeight += inputWeight;
			}
			if( m_Aperture.OverrideState != false)
			{
				blendedAperture += m_Aperture.Value * inputWeight;
				apertureWeight += inputWeight;
			}
			if( m_BladeCount.OverrideState != false)
			{
				blendedBladeCount += m_BladeCount.Value * inputWeight;
				bladeCountWeight += inputWeight;
			}
			if( m_BladeCurvature.OverrideState != false)
			{
				blendedBladeCurvature += m_BladeCurvature.Value * inputWeight;
				bladeCurvatureWeight += inputWeight;
			}
			if( m_BladeRotation.OverrideState != false)
			{
				blendedBladeRotation += m_BladeRotation.Value * inputWeight;
				bladeRotationWeight += inputWeight;
			}
		}
		static float GetDepth( Transform target, Transform camera)
		{
			Vector3 direction = target.position - camera.position;
			float dirLength = direction.magnitude;
			
			float c = Mathf.Clamp( Vector3.Dot( camera.forward, direction) / dirLength, -1f, 1f);
			float angle = Mathf.Acos( c);
			
			return Mathf.Cos( angle) * dirLength;
		}
		
		[NonSerialized]
		Transform m_Target;
		[NonSerialized]
		Transform m_Camera;
		[Header("Gaussian")]
		[SerializeField]
		MinFloatParam m_Start = new( 10f, 0f);
		[SerializeField]
		MinFloatParam m_End = new( 30f, 0f);
		[SerializeField]
		ClampedFloatParam m_MaxRadius = new( 1f, 0.5f, 1.5f);
		[Header("Bokeh")]
		[SerializeField]
		MinFloatParam m_FocusDistance = new( 10f, 0.1f);
		[SerializeField]
		ClampedFloatParam m_FocalLength = new( 50f, 1f, 300f);
		[SerializeField]
		ClampedFloatParam m_Aperture = new( 5.6f, 1f, 32f);
		[SerializeField]
		ClampedIntParam m_BladeCount = new( 5, 3, 9);
		[SerializeField]
		ClampedFloatParam m_BladeCurvature = new( 1f, 0f, 1f);
		[SerializeField]
		ClampedFloatParam m_BladeRotation = new( 0f, -180f, 180f);
	}
}
