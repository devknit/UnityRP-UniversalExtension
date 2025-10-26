#ifndef __KNIT_3D_TOON_LIT_INPUT_HLSL__
#define __KNIT_3D_TOON_LIT_INPUT_HLSL__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/OffsetZ.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Dithering.hlsl"

CBUFFER_START(UnityPerMaterial)
	float4 _BaseMap_ST;
	half4 _BaseColor;
	half4 _ShadeColor;
	float _BumpScale;
	float _DiffuseBorder;
	float _DiffuseSoftness;
	float _SpecularBorder;
	float _SpecularSoftness;
	float _SpecularIlluminance;
	// float _Metallic;
	// float _Smoothness;
	// float _ClearCoatMask;
	// float _ClearCoatSmoothness;
	half4 _EmissionColor;
	half4 _RimlightColor;
	float _RimlightBorder;
	float _RimlightSoftness;
	float _RimlightIlluminance;
	float _RimlightOverrideAlpha;
	float _OutlineDirection;
	float _OutlineWidth;
	float _OutlineOffsetZ;
	half4 _OutlineColor;
	float _WindStrength;
	float _OffsetZ;
	half _Dither;
	half _Cutoff;
	half2 _ColorPremultiply;
#if defined(TESSELLATION_ON)
	float _TessFactor;
	float _TessMinDistance;
	float _TessMaxDistance;
	float _TessPhongStrength;
	float _TessExtrusionAmount;
#endif
CBUFFER_END

#ifdef UNITY_DOTS_INSTANCING_ENABLED
	UNITY_DOTS_INSTANCING_START( MaterialPropertyMetadata)
		UNITY_DOTS_INSTANCED_PROP( float4 ,_BaseColor)
		UNITY_DOTS_INSTANCED_PROP( float4 ,_ShadeColor)
		UNITY_DOTS_INSTANCED_PROP( float  ,_BumpScale)
		UNITY_DOTS_INSTANCED_PROP( float  ,_DiffuseBorder)
		UNITY_DOTS_INSTANCED_PROP( float  ,_DiffuseSoftness)
		UNITY_DOTS_INSTANCED_PROP( float  ,_SpecularBorder)
		UNITY_DOTS_INSTANCED_PROP( float  ,_SpecularSoftness)
		UNITY_DOTS_INSTANCED_PROP( float  ,_SpecularIlluminance)
		UNITY_DOTS_INSTANCED_PROP( float4 ,_EmissionColor)
		UNITY_DOTS_INSTANCED_PROP( float4 ,_RimlightColor)
		UNITY_DOTS_INSTANCED_PROP( float  ,_RimlightBorder)
		UNITY_DOTS_INSTANCED_PROP( float  ,_RimlightSoftness)
		UNITY_DOTS_INSTANCED_PROP( float  ,_RimlightIlluminance)
		UNITY_DOTS_INSTANCED_PROP( float  ,_RimlightOverrideAlpha)
		// UNITY_DOTS_INSTANCED_PROP( float  ,_Metallic)
		// UNITY_DOTS_INSTANCED_PROP( float  ,_Smoothness)
		// UNITY_DOTS_INSTANCED_PROP( float  ,_ClearCoatMask)
		// UNITY_DOTS_INSTANCED_PROP( float  ,_ClearCoatSmoothness)
		UNITY_DOTS_INSTANCED_PROP( float  ,_OutlineDirection)
		UNITY_DOTS_INSTANCED_PROP( float  ,_OutlineWidth)
		UNITY_DOTS_INSTANCED_PROP( float  ,_OutlineOffsetZ)
		UNITY_DOTS_INSTANCED_PROP( half4  ,_OutlineColor)
		UNITY_DOTS_INSTANCED_PROP( half4  ,_WindStrength)
		UNITY_DOTS_INSTANCED_PROP( float  ,_OffsetZ)
		UNITY_DOTS_INSTANCED_PROP( float  ,_Dither)
		UNITY_DOTS_INSTANCED_PROP( float  ,_Cutoff)
		UNITY_DOTS_INSTANCED_PROP( float2 ,_ColorPremultiply)
	#if defined(TESSELLATION_ON)
		UNITY_DOTS_INSTANCED_PROP( float  ,_TessFactor)
		UNITY_DOTS_INSTANCED_PROP( float  ,_TessMinDistance)
		UNITY_DOTS_INSTANCED_PROP( float  ,_TessMaxDistance)
		UNITY_DOTS_INSTANCED_PROP( float  ,_TessPhongStrength)
		UNITY_DOTS_INSTANCED_PROP( float  ,_TessExtrusionAmount)
	#endif
	UNITY_DOTS_INSTANCING_END( MaterialPropertyMetadata)
	#define _BaseColor				UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float4 ,_BaseColor)
	#define _ShadeColor				UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float4 ,_ShadeColor)
	#define _DiffuseBorder			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_BumpScale)
	#define _DiffuseBorder			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_DiffuseBorder)
	#define _DiffuseSoftness		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_DiffuseSoftness)
	#define _SpecularBorder			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_SpecularBorder)
	#define _SpecularSoftness		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_SpecularSoftness)
	#define _SpecularIlluminance	UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_SpecularIlluminance)
	#define _EmissionColor			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float4 , _EmissionColor)
	#define _RimlightColor			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float4 , _RimlightColor)
	#define _RimlightBorder			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_RimlightBorder)
	#define _RimlightSoftness		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_RimlightSoftness)
	#define _RimlightIlluminance	UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  , _RimlightIlluminance)
	#define _RimlightOverrideAlpha	UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  , _RimlightOverrideAlpha)
	// #define _Metallic				UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  , _Metallic)
	// #define _Smoothness				UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  , _Smoothness)
	// #define _ClearCoatMask			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  , _ClearCoatMask)
	// #define _ClearCoatSmoothness	UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  , _ClearCoatSmoothness)
	#define _OutlineDirection		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OutlineDirection)
	#define _OutlineWidth			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OutlineWidth)
	#define _OutlineOffsetZ			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OutlineOffsetZ)
	#define _OutlineColor			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OutlineColor)
	#define _WindStrength			UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_WindStrength)
	#define _OffsetZ				UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_OffsetZ)
	#define _Dither					UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_Dither)
	#define _Cutoff					UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_Cutoff)
	#define _ColorPremultiply		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float2 ,_ColorPremultiply)
#if defined(TESSELLATION_ON)
	#define _TessFactor				UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_TessFactor)
	#define _TessMinDistance		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_TessMinDistance)
	#define _TessMaxDistance		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_TessMaxDistance)
	#define _TessPhongStrength		UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_TessPhongStrength)
	#define _TessExtrusionAmount	UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT( float  ,_TessExtrusionAmount)
#endif
#endif

TEXTURE2D( _ColorMaskMap);
SAMPLER( sampler_ColorMaskMap);
TEXTURE2D( _SpecularVolumeMap);
SAMPLER( sampler_SpecularVolumeMap);
TEXTURE2D( _SphereMap);
SAMPLER( sampler_SphereMap);

#if defined(VERTEXCOLOR_ON)
inline void InitializeToonLitSurfaceData( float2 uv, float4 positionCS, half4 color, out SurfaceData outSurfaceData)
{
	outSurfaceData = (SurfaceData)0;
	
	half4 albedoAlpha = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv);
	half4 colorShadeMask = SAMPLE_TEXTURE2D( _ColorMaskMap, sampler_ColorMaskMap, uv);
	outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a * color.a;
	outSurfaceData.alpha = AlphaDiscard( positionCS, outSurfaceData.alpha, _Cutoff, _Dither);
	outSurfaceData.albedo = albedoAlpha.rgb * color.rgb;
	outSurfaceData.albedo = lerp( outSurfaceData.albedo, outSurfaceData.albedo *_BaseColor.rgb, colorShadeMask.rgb);
	outSurfaceData.albedo = AlphaModulate( outSurfaceData.albedo, outSurfaceData.alpha);
#else
inline void InitializeToonLitSurfaceData( float2 uv, float4 positionCS, out SurfaceData outSurfaceData)
{
	outSurfaceData = (SurfaceData)0;
	
	half4 albedoAlpha = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv);
	half4 colorShadeMask = SAMPLE_TEXTURE2D( _ColorMaskMap, sampler_ColorMaskMap, uv);
	outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a;
	outSurfaceData.alpha = AlphaDiscard( positionCS, outSurfaceData.alpha, _Cutoff, _Dither);
	outSurfaceData.albedo = lerp( albedoAlpha.rgb, albedoAlpha.rgb * _BaseColor.rgb, colorShadeMask.rgb);
	outSurfaceData.albedo = AlphaModulate( outSurfaceData.albedo, outSurfaceData.alpha);
#endif
	// outSurfaceData.specular = half3( 0, 0, 0); // unused
	outSurfaceData.normalTS = SampleNormal( uv, TEXTURE2D_ARGS( _BumpMap, sampler_BumpMap), _BumpScale);
	outSurfaceData.occlusion = 1.0;
	outSurfaceData.emission = SAMPLE_TEXTURE2D( _EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
	// outSurfaceData.metallic = _Metallic; // unused
	// outSurfaceData.smoothness = _Smoothness; // unused
	// outSurfaceData.clearCoatMask = _ClearCoatMask; // unused
	// outSurfaceData.clearCoatSmoothness = _ClearCoatSmoothness; // unused
}
#endif
