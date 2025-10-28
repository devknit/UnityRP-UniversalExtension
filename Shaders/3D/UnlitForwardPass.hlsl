#ifndef __KNIT_3D_UNLIT_FORWARD_PASS_HLSL__
#define __KNIT_3D_UNLIT_FORWARD_PASS_HLSL__

#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/OffsetZ.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/ColorPremultiply.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Unlit.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"

struct Attributes
{
	float4 positionOS : POSITION;
	float2 texcoord : TEXCOORD0;
#if defined(VERTEXCOLOR_ON)
	half4 color : COLOR;
#endif
#if defined(OUTLINE_ON) || defined(DEBUG_DISPLAY)
	float3 normalOS : NORMAL;
	float4 tangentOS : TANGENT;
#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
	float4 positionCS : SV_POSITION;
	float2 uv : TEXCOORD0;
#if defined(VERTEXCOLOR_ON)
	half4 color : COLOR;
#endif
	
#if defined(DEBUG_DISPLAY)
	float3 positionWS : TEXCOORD1;
	float3 normalWS : TEXCOORD2;
	float3 viewDirWS : TEXCOORD3;
#endif
	half  fogFactor : TEXCOORD5;
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};
void InitializeInputData( Varyings input, out InputData inputData)
{
	inputData = (InputData)0;
#if defined(DEBUG_DISPLAY)
	inputData.positionWS = input.positionWS;
	inputData.normalWS = input.normalWS;
	inputData.viewDirectionWS = input.viewDirWS;
#else
	inputData.positionWS = float3( 0, 0, 0);
	inputData.normalWS = half3( 0, 0, 1);
	inputData.viewDirectionWS = half3( 0, 0, 1);
#endif
	inputData.shadowCoord = 0;
	inputData.fogCoord = 0;
	inputData.vertexLighting = half3( 0, 0, 0);
	inputData.bakedGI = half3( 0, 0, 0);
	inputData.normalizedScreenSpaceUV = 0;
	inputData.shadowMask = half4( 1, 1, 1, 1);
}
Varyings UnlitPassVertex( Attributes input)
{
	Varyings output = (Varyings)0;
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_TRANSFER_INSTANCE_ID( input, output);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output);
	
	VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz);
#if defined(OUTLINE_ON) || defined(DEBUG_DISPLAY)
	VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS);
#endif
#if defined(OUTLINE_ON)
	vertexInput.positionCS = OutlineTransformWorldToHClip( 
		vertexInput.positionWS, vertexInput.positionVS.z, 
		normalInput.normalWS, input.texcoord);
#else
	vertexInput.positionCS = GetClipPositionWithZOffset( 
		vertexInput.positionCS, _OffsetZ);
#endif
	output.positionCS = vertexInput.positionCS;
	output.uv = TRANSFORM_TEX( input.texcoord, _BaseMap);
#if defined(_FOG_FRAGMENT)
	output.fogFactor = vertexInput.positionVS.z;
#else
	output.fogFactor = ComputeFogFactor( vertexInput.positionCS.z);
#endif
#if defined(VERTEXCOLOR_ON)
	output.color = input.color;
#endif
#if defined(DEBUG_DISPLAY)
	output.positionWS = vertexInput.positionWS;
	output.normalWS = normalInput.normalWS;
	output.viewDirWS = GetWorldSpaceViewDir( vertexInput.positionWS);
#endif
	return output;
}
void UnlitPassFragment( Varyings input, out half4 outColor : SV_Target0
#ifdef _WRITE_RENDERING_LAYERS
	, out float4 outRenderingLayers : SV_Target1
#endif
)
{
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input);
	
	half4 albedoAlpha = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, input.uv);
#if defined(VERTEXCOLOR_ON)
	half alpha = AlphaDiscard( input.positionCS, albedoAlpha.a * _BaseColor.a * input.color.a, _Cutoff, _Dither);
	half3 albedo = AlphaModulate( albedoAlpha.rgb * _BaseColor.rgb * input.color.rgb, alpha);
#else
	half alpha = AlphaDiscard( input.positionCS, albedoAlpha.a * _BaseColor.a, _Cutoff, _Dither);
	half3 albedo = AlphaModulate( albedoAlpha.rgb * _BaseColor.rgb, alpha);
#endif
	
	InputData inputData;
	InitializeInputData( input, inputData);
	SETUP_DEBUG_TEXTURE_DATA( inputData, UNDO_TRANSFORM_TEX( input.uv, _BaseMap))
	
	#if defined(_DBUFFER)
	ApplyDecalToBaseColor( input.positionCS, albedo);
#endif
	half4 color = UniversalFragmentUnlit( inputData, albedo, alpha);
	
#if defined(_SCREEN_SPACE_OCCLUSION) && !defined(_SURFACE_TYPE_TRANSPARENT)
	float2 normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV( input.positionCS);
	AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(normalizedScreenSpaceUV);
	color.rgb *= aoFactor.directAmbientOcclusion;
#endif
#if defined(_FOG_FRAGMENT)
	#if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
		float viewZ = -input.fogFactor;
		float nearToFarZ = max( viewZ - _ProjectionParams.y, 0);
		half fogFactor = ComputeFogFactorZ0ToFar( nearToFarZ);
	#else
		half fogFactor = 0;
	#endif
#else
	half fogFactor = input.fogFactor;
#endif
	color.rgb = MixFog( color.rgb, fogFactor);
	outColor = ColorPremultiply( color, _ColorPremultiply);
	
#ifdef _WRITE_RENDERING_LAYERS
	uint renderingLayers = GetMeshRenderingLayer();
	outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers), 0, 0, 0);
#endif
}
#endif
