#ifndef __KNIT_3D_DEPTH_NORMALS_PASS_HLSL__
#define __KNIT_3D_DEPTH_NORMALS_PASS_HLSL__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#if defined(LOD_FADE_CROSSFADE)
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Wind.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/OffsetZ.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Dithering.hlsl"

struct Attributes
{
	float4 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float4 tangentOS : TANGENT;
	float2 texcoord : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
	float4 positionCS : SV_POSITION;
	float2 uv : TEXCOORD0;
#if defined(_NORMALMAP)
	half4 normalWS : TEXCOORD1;		// xyz: normal, w: viewDir.x
	half4 tangentWS : TEXCOORD2;	// xyz: tangent, w: viewDir.y
	half4 bitangentWS : TEXCOORD3;	// xyz: bitangent, w: viewDir.z
#else
	half3 normalWS : TEXCOORD1;
#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};
Varyings DepthNormalsVertex( Attributes input)
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
    vertexInput.positionCS = GetClipPositionWithZOffset( TransformWorldToHClip( vertexInput.positionWS), _OffsetZ);
    // float4 normalizedDeviceCoordinate = vertexInput.positionCS * 0.5f;
    // vertexInput.positionNDC.xy = float2( normalizedDeviceCoordinate.x, 
	// 	normalizedDeviceCoordinate.y * _ProjectionParams.x) + normalizedDeviceCoordinate.w;
    // vertexInput.positionNDC.zw = vertexInput.positionCS.zw;
	
	half3 viewDirWS = GetWorldSpaceNormalizeViewDir( vertexInput.positionWS);
#if defined(_NORMALMAP)
	output.normalWS = half4( normalInput.normalWS, viewDirWS.x);
	output.tangentWS = half4( normalInput.tangentWS, viewDirWS.y);
	output.bitangentWS = half4( normalInput.bitangentWS, viewDirWS.z);
#else
	output.normalWS = half3( NormalizeNormalPerVertex( normalInput.normalWS));
#endif
	output.uv = TRANSFORM_TEX( input.texcoord, _BaseMap);
	output.positionCS = vertexInput.positionCS;
	return output;
}
void DepthNormalsFragment( Varyings input, out half4 outNormalWS : SV_Target0
#ifdef _WRITE_RENDERING_LAYERS
	, out float4 outRenderingLayers : SV_Target1
#endif
)
{
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input);
	
	half4 albedoAlpha = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, input.uv);
	AlphaDiscard( input.positionCS, albedoAlpha.a * _BaseColor.a, _Cutoff, _Dither);
	
#if defined(_GBUFFER_NORMALS_OCT)
	float3 normalWS = normalize( input.normalWS);
	float2 octNormalWS = PackNormalOctQuadEncode( normalWS);           // values between [-1, +1], must use fp32 on some platforms
	float2 remappedOctNormalWS = saturate( octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
	half3 packedNormalWS = PackFloat2To888( remappedOctNormalWS);      // values between [ 0,  1]
	outNormalWS = half4( packedNormalWS, 0.0);
#else
	float2 uv = input.uv;
#if defined(_NORMALMAP)
	half3 normalTS = SampleNormal( uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
	half3 normalWS = TransformTangentToWorld( normalTS, half3x3( input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
#else
	half3 normalWS = input.normalWS;
#endif
	normalWS = NormalizeNormalPerPixel( normalWS);
	outNormalWS = half4( normalWS, 0.0);
#endif
#ifdef _WRITE_RENDERING_LAYERS
	uint renderingLayers = GetMeshRenderingLayer();
	outRenderingLayers = float4(EncodeMeshRenderingLayer( renderingLayers), 0, 0, 0);
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
	float2 texcoord : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
[domain( "tri")]
[partitioning( "integer")]
[outputcontrolpoints( 3)]
[outputtopology( "triangle_cw")]
[patchconstantfunc( "PatchConstantFunction")]
ControlPoint DepthNormalsHull( InputPatch<ControlPoint, 3> patch, uint id : SV_OutputControlPointID)
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
Varyings DepthNormalsDomain( TessellationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
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
	float3 position0 = output.positionOS.xyz - patch[ 0].normalOS * (dot( output.positionOS.xyz, patch[ 0].normalOS) - dot( patch[ 0].positionOS.xyz, patch[ 0].normalOS));
	float3 position1 = output.positionOS.xyz - patch[ 1].normalOS * (dot( output.positionOS.xyz, patch[ 1].normalOS) - dot( patch[ 1].positionOS.xyz, patch[ 1].normalOS));
	float3 position2 = output.positionOS.xyz - patch[ 2].normalOS * (dot( output.positionOS.xyz, patch[ 2].normalOS) - dot( patch[ 2].positionOS.xyz, patch[ 2].normalOS));
	output.positionOS.xyz = _TessPhongStrength * (position0 * barycentricCoordinates.x + position1 * barycentricCoordinates.y + position2 * barycentricCoordinates.z) + (1.0f - _TessPhongStrength) * output.positionOS.xyz;
	output.positionOS.xyz += output.normalOS.xyz * _TessExtrusionAmount;
	UNITY_TRANSFER_INSTANCE_ID( patch[0], output);
	return DepthNormalsVertex( output);
}
ControlPoint DepthNormalsTessellationVertex( Attributes input)
{   
	ControlPoint output;
	output.positionOS = input.positionOS;
	output.normalOS = normalize( input.normalOS);
	output.tangentOS = input.tangentOS;
	output.texcoord = input.texcoord;
	UNITY_TRANSFER_INSTANCE_ID( input, output);
	return output;
}
#endif
#endif
