
using System;
using UnityEngine;
using UnityEngine.Playables;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class SpeedLineBehaviour : PlayableBehaviour
	{
		internal void Blend( float inputWeight, ref Color blendedColor,
			ref Vector2 blendedCenter, ref float centerWeight,
			ref Vector2 blendedAxisMask, ref float axisMaskWeight,
			ref float blendedRotate, ref float rotateWeight,
			ref float blendedTiling, ref float tilingWeight,
			ref float blendedSparse, ref float sparseWeight,
			ref float blendedRemap, ref float remapWeight,
			ref float blendedRadialScale, ref float radialScaleWeight,
			ref float blendedSmoothWidth, ref float smoothWidthWeight,
			ref float blendedSmoothBorder, ref float smoothBorderWeight,
			ref float blendedTimeScale, ref float timeScaleWeight)
		{
			blendedColor += m_Color * inputWeight;
			
			if( m_Center.OverrideState != false)
			{
				blendedCenter += m_Center.Value * inputWeight;
				centerWeight += inputWeight;
			}
			if( m_AxisMask.OverrideState != false)
			{
				blendedAxisMask += m_AxisMask.Value * inputWeight;
				axisMaskWeight += inputWeight;
			}
			if( m_Rotate.OverrideState != false)
			{
				blendedRotate += m_Rotate.Value * inputWeight;
				rotateWeight += inputWeight;
			}
			if( m_Tiling.OverrideState != false)
			{
				blendedTiling += m_Tiling.Value * inputWeight;
				tilingWeight += inputWeight;
			}
			if( m_Sparse.OverrideState != false)
			{
				blendedSparse += m_Sparse.Value * inputWeight;
				sparseWeight += inputWeight;
			}
			if( m_Remap.OverrideState != false)
			{
				blendedRemap += m_Remap.Value * inputWeight;
				remapWeight += inputWeight;
			}
			if( m_RadialScale.OverrideState != false)
			{
				blendedRadialScale += m_RadialScale.Value * inputWeight;
				radialScaleWeight += inputWeight;
			}
			if( m_SmoothWidth.OverrideState != false)
			{
				blendedSmoothWidth += m_SmoothWidth.Value * inputWeight;
				smoothWidthWeight += inputWeight;
			}
			if( m_SmoothBorder.OverrideState != false)
			{
				blendedSmoothBorder += m_SmoothBorder.Value * inputWeight;
				smoothBorderWeight += inputWeight;
			}
			if( m_TimeScale.OverrideState != false)
			{
				blendedTimeScale += m_TimeScale.Value * inputWeight;
				timeScaleWeight += inputWeight;
			}
		}
		[SerializeField]
		Color m_Color = new( 1.0f, 1.0f, 1.0f, 0.0f);
		[SerializeField]
		internal Vector2Param m_Center = new( new Vector2( 0.5f, 0.5f));
		[SerializeField]
		internal Vector2Param m_AxisMask = new( Vector2.one);
		[SerializeField]
		internal FloatParam m_Rotate = new( 0.0f, false);
		[SerializeField]
		internal FloatParam m_Tiling = new( 200.0f, false);
		[SerializeField]
		internal FloatParam m_Sparse = new( 3.0f);
		[SerializeField]
		internal ClampedFloatParam m_Remap = new( 0.5f, 0.0f, 1.0f);
		[SerializeField]
		internal ClampedFloatParam m_RadialScale = new( 0.5f, 0.0f, 10.0f);
		[SerializeField]
		internal FloatParam m_SmoothWidth = new( 0.45f);
		[SerializeField]
		internal FloatParam m_SmoothBorder = new( 0.3f);
		[SerializeField]
		internal FloatParam m_TimeScale = new( 3.0f);
	}
}
