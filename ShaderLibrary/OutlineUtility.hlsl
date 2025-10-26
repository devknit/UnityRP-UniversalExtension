#ifndef __KNIT_3D_OUTLINE_UTILITY_HLSL__
#define __KNIT_3D_OUTLINE_UTILITY_HLSL__

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/OffsetZ.hlsl"
/*
CBUFFER_START(UnityPerMaterial)
	float _OutlineDirection;
	float _OutlineWidth;
	float _OutlineOffsetZ;
	half4 _OutlineColor;
CBUFFER_END

#ifdef UNITY_DOTS_INSTANCING_ENABLED
	UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
		UNITY_DOTS_INSTANCED_PROP( float, _OutlineDirection)
		UNITY_DOTS_INSTANCED_PROP( float, _OutlineWidth)
		UNITY_DOTS_INSTANCED_PROP( float, _OutlineOffsetZ)
		UNITY_DOTS_INSTANCED_PROP( half4, _OutlineColor;)
	UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
	#define _OutlineDirection	UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OutlineDirection)
	#define _OutlineWidth		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OutlineWidth)
	#define _OutlineOffsetZ		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OutlineOffsetZ)
	#define _OutlineColor		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OutlineColor)
#endif
*/
TEXTURE2D( _OutlineVolumeMap);
SAMPLER( sampler_OutlineVolumeMap);

inline half invLerp( half from, half to, half value) 
{
	return (value - from) / (to - from);
}
inline half invLerpClamp( half from, half to, half value)
{
	return saturate( invLerp( from, to, value));
}
float GetCameraFOV()
{
	//https://answers.unity.com/questions/770838/how-can-i-extract-the-fov-information-from-the-pro.html
	float t = unity_CameraProjection._m11;
	const float kRad2Deg = 180.0 / PI;
	return atan( 1.0 / t) * 2.0 * kRad2Deg;
}
float GetOutlineCameraFovAndDistanceFixMultiplier( float positionVS_Z)
{
	float cameraMulFix;
	
	// Perspective camera case
	if( unity_OrthoParams.w == 0)
	{
		// Can replace saturate to a tonemap function if a smooth stop is needed.
		// Keep outline similar width on screen accoss all camera fov.
		cameraMulFix = saturate( abs( positionVS_Z)) * GetCameraFOV();
	}
	// Orthographic camera case
	else
	{
		// 50 is a magic number to match perspective camera's outline width
		cameraMulFix = saturate( abs( unity_OrthoParams.y)) * 50.0;
	}
	return cameraMulFix * 0.00005;
}
float4 OutlineTransformWorldToHClip( float3 positionWS, float positionVS_z, float3 direction, float2 uv)
{
	float outlineExpandAmount = _OutlineWidth * GetOutlineCameraFovAndDistanceFixMultiplier( positionVS_z);
#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED) || defined(UNITY_STEREO_DOUBLE_WIDE_ENABLED)
	outlineExpandAmount *= 0.5;
#endif
	float4 outlineMap = SAMPLE_TEXTURE2D_LOD( _OutlineVolumeMap, sampler_OutlineVolumeMap, uv, 0);
	float viewSpaceZOffsetAmount = _OffsetZ + _OutlineOffsetZ;
	
	outlineExpandAmount *= outlineMap.r;
	viewSpaceZOffsetAmount *= outlineMap.g;
	
	return GetClipPositionWithZOffset( TransformWorldToHClip( 
		positionWS + direction * outlineExpandAmount), viewSpaceZOffsetAmount);
}
#endif
