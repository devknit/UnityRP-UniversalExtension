#ifndef __KNIT_3D_UNLIT_INPUT_HLSL__
#define __KNIT_3D_UNLIT_INPUT_HLSL__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/OffsetZ.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Dithering.hlsl"

CBUFFER_START(UnityPerMaterial)
	float4 _BaseMap_ST;
	half4 _BaseColor;
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


#endif
