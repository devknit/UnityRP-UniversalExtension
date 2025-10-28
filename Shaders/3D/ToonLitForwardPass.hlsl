#ifndef __KNIT_3D_TOON_LIT_FORWARD_PASS_HLSL__
#define __KNIT_3D_TOON_LIT_FORWARD_PASS_HLSL__

#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Wind.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/OffsetZ.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/ColorPremultiply.hlsl"
#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLighting.hlsl"

struct Attributes
{
	float4 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float4 tangentOS : TANGENT;
#if defined(VERTEXCOLOR_ON)
	half4 color : COLOR;
#endif
	float2 texcoord : TEXCOORD0;
	float2 staticLightmapUV : TEXCOORD1;
	float2 dynamicLightmapUV : TEXCOORD2;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
	float4 positionCS : SV_POSITION;
#if defined(VERTEXCOLOR_ON)
	half4 color : COLOR;
#endif
	float2 uv : TEXCOORD0;
	float3 positionWS : TEXCOORD1;
#if defined(_NORMALMAP)
	half4 normalWS : TEXCOORD2;
	half4 tangentWS : TEXCOORD3;
	half4 bitangentWS : TEXCOORD4;
#else
	half3 normalWS : TEXCOORD2;
#endif
#if defined(_ADDITIONAL_LIGHTS_VERTEX)
	half4 fogFactorAndVertexLight : TEXCOORD5;
#else
	half  fogFactor : TEXCOORD5;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
	float4 shadowCoord : TEXCOORD6;
#endif
	DECLARE_LIGHTMAP_OR_SH( staticLightmapUV, vertexSH, 7);
#if defined(DYNAMICLIGHTMAP_ON)
	float2 dynamicLightmapUV : TEXCOORD8; // Dynamic lightmap UVs
#endif
#ifdef USE_APV_PROBE_OCCLUSION
    float4 probeOcclusion : TEXCOORD9;
#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};
void InitializeInputData( Varyings input, half3 normalTS, out InputData inputData)
{
	inputData = (InputData)0;
	inputData.positionWS = input.positionWS;
#if defined(DEBUG_DISPLAY)
    inputData.positionCS = input.positionCS;
#endif
	
#if defined(_NORMALMAP)
	half3 viewDirWS = half3( input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
	inputData.tangentToWorld = half3x3( input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
	inputData.normalWS = TransformTangentToWorld( normalTS, inputData.tangentToWorld);
#else
	half3 viewDirWS = GetWorldSpaceNormalizeViewDir( inputData.positionWS);
	inputData.normalWS = input.normalWS;
#endif
	inputData.normalWS = NormalizeNormalPerPixel( inputData.normalWS);
	viewDirWS = SafeNormalize( viewDirWS);
	inputData.viewDirectionWS = viewDirWS;
	
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
	inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
	inputData.shadowCoord = TransformWorldToShadowCoord( inputData.positionWS);
#else
	inputData.shadowCoord = float4( 0, 0, 0, 0);
#endif
	
#if defined(_ADDITIONAL_LIGHTS_VERTEX)
	inputData.fogCoord = InitializeInputDataFog( float4( inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
	inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
#else
	inputData.fogCoord = InitializeInputDataFog( float4( inputData.positionWS, 1.0), input.fogFactor);
	inputData.vertexLighting = half3( 0, 0, 0);
#endif
	inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV( input.positionCS);
	
#if defined(DEBUG_DISPLAY)
	#if defined(DYNAMICLIGHTMAP_ON)
		inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
	#endif
	#if defined(LIGHTMAP_ON)
		inputData.staticLightmapUV = input.staticLightmapUV;
	#else
		inputData.vertexSH = input.vertexSH;
	#endif
	#if defined(USE_APV_PROBE_OCCLUSION)
		inputData.probeOcclusion = input.probeOcclusion;
    #endif
#endif
}
void InitializeBakedGIData(Varyings input, inout InputData inputData)
{
#if defined(DYNAMICLIGHTMAP_ON)
    inputData.bakedGI = SAMPLE_GI( input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
    inputData.shadowMask = SAMPLE_SHADOWMASK( input.staticLightmapUV);
#elif !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
    inputData.bakedGI = SAMPLE_GI( input.vertexSH,
        GetAbsolutePositionWS(inputData.positionWS),
        inputData.normalWS,
        inputData.viewDirectionWS,
        input.positionCS.xy,
        input.probeOcclusion,
        inputData.shadowMask);
#else
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
#endif
}
Varyings LitPassVertexToon( Attributes input)
{
	Varyings output = (Varyings)0;
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_TRANSFER_INSTANCE_ID( input, output);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output);
	
	VertexNormalInputs normalInput;
    real sign = real( input.tangentOS.w) * GetOddNegativeScale();
    normalInput.normalWS = TransformObjectToWorldNormal( input.normalOS);
    normalInput.tangentWS = real3( TransformObjectToWorldDir( input.tangentOS.xyz));
    normalInput.bitangentWS = real3( cross( normalInput.normalWS, float3( normalInput.tangentWS))) * sign;
	
	VertexPositionInputs vertexInput;
    vertexInput.positionWS = TransformObjectToWorldWind( input.positionOS.xyz, input.normalOS);
    vertexInput.positionVS = TransformWorldToView( vertexInput.positionWS);
    vertexInput.positionCS = TransformWorldToHClip( vertexInput.positionWS);
#if OUTLINE_ON
	vertexInput.positionCS = OutlineTransformWorldToHClip( 
		vertexInput.positionWS, vertexInput.positionVS.z, 
		normalInput.normalWS, input.texcoord);
#else
	vertexInput.positionCS = GetClipPositionWithZOffset( 
		vertexInput.positionCS, _OffsetZ);
#endif
#if defined(_FOG_FRAGMENT)
	half fogFactor = 0;
#else
	half fogFactor = ComputeFogFactor( vertexInput.positionCS.z);
#endif
	output.uv = TRANSFORM_TEX( input.texcoord, _BaseMap);
	output.positionWS = vertexInput.positionWS;
	output.positionCS = vertexInput.positionCS;
#if defined(VERTEXCOLOR_ON)
	output.color = input.color;
#endif
#if defined(_NORMALMAP)
	half3 viewDirWS = GetWorldSpaceViewDir( vertexInput.positionWS);
	output.normalWS = half4( normalInput.normalWS, viewDirWS.x);
	output.tangentWS = half4( normalInput.tangentWS, viewDirWS.y);
	output.bitangentWS = half4( normalInput.bitangentWS, viewDirWS.z);
#else
	output.normalWS = NormalizeNormalPerVertex( normalInput.normalWS);
#endif
	
	OUTPUT_LIGHTMAP_UV( input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#if defined(DYNAMICLIGHTMAP_ON)
	output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
	OUTPUT_SH4( vertexInput.positionWS, output.normalWS.xyz, 
		GetWorldSpaceNormalizeViewDir( vertexInput.positionWS), 
		output.vertexSH, output.probeOcclusion);
	
#if defined(_ADDITIONAL_LIGHTS_VERTEX)
	half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS);
	output.fogFactorAndVertexLight = half4( fogFactor, vertexLight);
#else
	output.fogFactor = fogFactor;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
	output.shadowCoord = GetShadowCoord( vertexInput);
#endif
	return output;
}
void LitPassFragmentToon( Varyings input, out half4 outColor : SV_Target0
#if defined(_WRITE_RENDERING_LAYERS)
	, out float4 outRenderingLayers : SV_Target1
#endif
){
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input);
	
	SpecularData specularData;
	InitializeToonLitSpecularData( input.uv, specularData);
	
	SurfaceData surfaceData;
#if defined(VERTEXCOLOR_ON)
	InitializeToonLitSurfaceData( input.uv, input.positionCS, input.color, surfaceData);
#else
	InitializeToonLitSurfaceData( input.uv, input.positionCS, surfaceData);
#endif
	
	InputData inputData;
	InitializeInputData( input, surfaceData.normalTS, inputData);
#if (defined(_DBUFFER_MRT1) || defined(_DBUFFER_MRT2) || defined(_DBUFFER_MRT3))
	ApplyDecalToSurfaceData( input.positionCS, surfaceData, inputData);
#endif
	half4 sphereMapColor = SAMPLE_TEXTURE2D( _SphereMap, sampler_SphereMap, 
		TransformWorldToViewDir( inputData.normalWS).xy * 0.5 + 0.5);
	SETUP_DEBUG_TEXTURE_DATA( inputData, UNDO_TRANSFORM_TEX( input.uv, _BaseMap));
	
	InitializeBakedGIData( input, inputData);
	
	half4 color = UniversalFragmentToonShade( inputData, surfaceData, specularData, sphereMapColor.rgb);
	color.rgb = MixFog( color.rgb, inputData.fogCoord);
#if OUTLINE_ON
	color *= _OutlineColor;
#endif
	outColor = ColorPremultiply( color, _ColorPremultiply);
	
#if defined(_WRITE_RENDERING_LAYERS)
	uint renderingLayers = GetMeshRenderingLayer();
	outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers), 0, 0, 0);
#endif
}
#if defined(TESSELLATION_ON)
struct TessellationFactors
{
	float edge[ 3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};
struct ControlPoint
{
	float4 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float4 tangentOS : TANGENT;
#if defined(VERTEXCOLOR_ON)
	half4 color : COLOR;
#endif
	float2 texcoord : TEXCOORD0;
	float2 staticLightmapUV : TEXCOORD1;
	float2 dynamicLightmapUV : TEXCOORD2;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
[domain( "tri")]
[partitioning( "integer")]
[outputcontrolpoints( 3)]
[outputtopology( "triangle_cw")]
[patchconstantfunc( "PatchConstantFunction")]
ControlPoint LitPassHullToon( InputPatch<ControlPoint, 3> patch, uint id : SV_OutputControlPointID)
{
	return patch[ id];
}
float CalcDistanceTessFactor( float3 positionWS, float minDist, float maxDist, float tess)
{
	return clamp(1.0 - (distance( positionWS, _WorldSpaceCameraPos) - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
}
TessellationFactors PatchConstantFunction( const InputPatch<ControlPoint, 3> input)
{
	TessellationFactors output;
	float3 positionWS0 = mul( unity_ObjectToWorld, input[ 0].positionOS).xyz;
	float3 positionWS1 = mul( unity_ObjectToWorld, input[ 1].positionOS).xyz;
	float3 positionWS2 = mul( unity_ObjectToWorld, input[ 2].positionOS).xyz;
	float x = CalcDistanceTessFactor( positionWS0, _TessMinDistance, _TessMaxDistance, _TessFactor);
	float y = CalcDistanceTessFactor( positionWS1, _TessMinDistance, _TessMaxDistance, _TessFactor);
	float z = CalcDistanceTessFactor( positionWS2, _TessMinDistance, _TessMaxDistance, _TessFactor);
	output.inside = (x + y + z) / 3.0;
	output.edge[ 0] = 0.5 * (y + z);
	output.edge[ 1] = 0.5 * (x + z);
	output.edge[ 2] = 0.5 * (x + y);
	return output;
}
[domain("tri")]
Varyings LitPassDomainToon( TessellationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
{
	Attributes output; 
	#define DomainVertex( fieldName) output.fieldName = \
		patch[ 0].fieldName * barycentricCoordinates.x + \
		patch[ 1].fieldName * barycentricCoordinates.y + \
		patch[ 2].fieldName * barycentricCoordinates.z;
	DomainVertex( positionOS)
	DomainVertex( normalOS)
	DomainVertex( tangentOS)
	DomainVertex( texcoord)
#if defined(VERTEXCOLOR_ON)
	DomainVertex( color)
#endif
	DomainVertex( staticLightmapUV)
	DomainVertex( dynamicLightmapUV)
	float3 position0 = output.positionOS.xyz - patch[ 0].normalOS * (dot( output.positionOS.xyz, patch[ 0].normalOS) - dot( patch[ 0].positionOS.xyz, patch[ 0].normalOS));
	float3 position1 = output.positionOS.xyz - patch[ 1].normalOS * (dot( output.positionOS.xyz, patch[ 1].normalOS) - dot( patch[ 1].positionOS.xyz, patch[ 1].normalOS));
	float3 position2 = output.positionOS.xyz - patch[ 2].normalOS * (dot( output.positionOS.xyz, patch[ 2].normalOS) - dot( patch[ 2].positionOS.xyz, patch[ 2].normalOS));
	output.positionOS.xyz = _TessPhongStrength * (position0 * barycentricCoordinates.x + position1 * barycentricCoordinates.y + position2 * barycentricCoordinates.z) + (1.0f - _TessPhongStrength) * output.positionOS.xyz;
	output.positionOS.xyz += output.normalOS.xyz * _TessExtrusionAmount;
	UNITY_TRANSFER_INSTANCE_ID( patch[0], output);
	return LitPassVertexToon( output);
}
ControlPoint LitPassTessellationVertexToon( Attributes input)
{   
	ControlPoint output;
	output.positionOS = input.positionOS;
	output.normalOS = normalize( input.normalOS);
	output.tangentOS = input.tangentOS;
	output.texcoord = input.texcoord;
#if defined(VERTEXCOLOR_ON)
	output.color = input.color;
#endif
	output.staticLightmapUV = input.staticLightmapUV;
	output.dynamicLightmapUV = input.dynamicLightmapUV;
	UNITY_TRANSFER_INSTANCE_ID( input, output);
	return output;
}
#endif
#endif
