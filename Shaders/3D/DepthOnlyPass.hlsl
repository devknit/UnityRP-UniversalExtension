#ifndef __KNIT_3D_DEPTH_ONLY_PASS_HLSL__
#define __KNIT_3D_DEPTH_ONLY_PASS_HLSL__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
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
	float4 positionSS : TEXCOORD0;
	float2 uv : TEXCOORD1;
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};
Varyings DepthOnlyVertex( Attributes input)
{
	Varyings output = (Varyings)0;
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_TRANSFER_INSTANCE_ID( input, output);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output);
	
	output.uv = TRANSFORM_TEX( input.texcoord, _BaseMap);
	float3 normalWS = TransformObjectToWorldNormal( input.normalOS);
	float3 positionWS = TransformObjectToWorldWind( input.positionOS.xyz, input.normalOS);
	output.positionCS = TransformWorldToHClip( positionWS);
	output.positionCS = GetClipPositionWithZOffset( output.positionCS, _OffsetZ);
	return output;
}
half DepthOnlyFragment( Varyings input) : SV_TARGET
{
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input);
	half4 albedoAlpha = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, input.uv);
	AlphaDiscard( input.positionCS, albedoAlpha.a * _BaseColor.a, _Cutoff, _Dither);
	return input.positionCS.z;
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
ControlPoint DepthOnlyHull( InputPatch<ControlPoint, 3> patch, uint id : SV_OutputControlPointID)
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
Varyings DepthOnlyDomain( TessellationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
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
	return DepthOnlyVertex( output);
}
ControlPoint DepthOnlyTessellationVertex( Attributes input)
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
