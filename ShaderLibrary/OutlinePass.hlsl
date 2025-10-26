#ifndef __KNIT_3D_OUTLINE_PASS_HLSL__
#define __KNIT_3D_OUTLINE_PASS_HLSL__

#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/OutlineUtility.hlsl"
#if defined(LOD_FADE_CROSSFADE)
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Wind.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Dithering.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/ColorPremultiply.hlsl"

struct Attributes
{
	float4 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float4 tangentOS : TANGENT;
	float2 texcoord : TEXCOORD0;
	float4 color: COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
	float4 positionCS : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 positionWS : TEXCOORD1;
	half fogFactor : TEXCOORD2;
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};
float3 GetOutlineVectorOS( float4 color, float3 normalOS, float4 tangentOS)
{
	float3 bitangentOS = normalize( cross( normalOS, tangentOS.xyz)) * (tangentOS.w * length( normalOS));
	float3 outlineVectorTS = color.rgb * 2.0 - 1.0;
	float3 outlineVector = normalize( outlineVectorTS.x * tangentOS.xyz + outlineVectorTS.y * bitangentOS + outlineVectorTS.z * normalOS);
	return outlineVector * color.a;
}
float3 GetOutlineVectorWS( float4 color, float3 normalOS, float4 tangentOS)
{
	float3 normalWS = TransformObjectToWorldNormal( normalOS);
	float3 tangentWS = TransformObjectToWorldDir( tangentOS.xyz);
    float3 bitangentWS = cross( normalWS, tangentWS.xyz) * tangentOS.w * unity_WorldTransformParams.w;
    float3 outlineVectorTS = color.rgb * 2.0 - 1.0;
    float3 outlineVector = outlineVectorTS.x * tangentWS.xyz + outlineVectorTS.y * bitangentWS + outlineVectorTS.z * normalWS;
    return outlineVector * color.a;
}
float3 GetOutlineVectorWS( float4 color, float3 normalWS, float3 tangentWS, float4 tangentOS)
{
    float3 bitangentWS = cross( normalWS, tangentWS.xyz) * tangentOS.w * unity_WorldTransformParams.w;
    float3 outlineVectorTS = color.rgb * 2.0 - 1.0;
    float3 outlineVector = outlineVectorTS.x * tangentWS.xyz + outlineVectorTS.y * bitangentWS + outlineVectorTS.z * normalWS;
    return outlineVector * color.a;
}
Varyings OutlinePassVertex( Attributes input)
{
	Varyings output = (Varyings)0;
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_TRANSFER_INSTANCE_ID( input, output);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output);
	
	float3 normalWS = TransformObjectToWorldNormal( input.normalOS);
	float3 tangentWS = TransformObjectToWorldDir( input.tangentOS.xyz);
	float3 positionWS = TransformObjectToWorldWind( input.positionOS.xyz, input.normalOS);
	float3 positionVS = TransformWorldToView( positionWS);
	float3 outlineVector = lerp( normalWS, GetOutlineVectorWS( input.color, normalWS, tangentWS, input.tangentOS), _OutlineDirection);
	
	output.positionCS = OutlineTransformWorldToHClip( positionWS, 
		positionVS.z, outlineVector, input.texcoord);
	output.positionWS = positionWS;
	output.uv = TRANSFORM_TEX( input.texcoord, _BaseMap);
#if defined(_FOG_FRAGMENT)
	output.fogFactor = 0;
#else
	output.fogFactor = ComputeFogFactor( output.positionCS.z);
#endif
	return output;
}
void OutlinePassFragment( Varyings input, out half4 outColor : SV_Target0
#if defined(_WRITE_RENDERING_LAYERS)
	, out float4 outRenderingLayers : SV_Target1
#endif
){
	half4 albedoAlpha = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, input.uv);
	half alpha = AlphaDiscard( input.positionCS, albedoAlpha.a * _BaseColor.a, _Cutoff, _Dither);
	
	half3 albedo = albedoAlpha.rgb * _BaseColor.rgb;
	albedo = lerp( _OutlineColor.rgb, _OutlineColor.rgb * albedo, _OutlineColor.a);
	albedo = AlphaModulate( albedo, alpha);
	albedo = MixFog( albedo, InitializeInputDataFog( 
		float4( input.positionWS, 1.0), input.fogFactor));
	outColor = ColorPremultiply( half4( albedo, alpha), _ColorPremultiply);
	
#if defined(_WRITE_RENDERING_LAYERS)
	outRenderingLayers = float4( EncodeMeshRenderingLayer( GetMeshRenderingLayer()), 0, 0, 0);
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
	float4 color: COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
[domain( "tri")]
[partitioning( "integer")]
[outputcontrolpoints( 3)]
[outputtopology( "triangle_cw")]
[patchconstantfunc( "PatchConstantFunction")]
ControlPoint OutlinePassHull( InputPatch<ControlPoint, 3> patch, uint id : SV_OutputControlPointID)
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
Varyings OutlinePassDomain( TessellationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
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
	DomainVertex( color)
	float3 position0 = output.positionOS.xyz - patch[ 0].normalOS * (dot( output.positionOS.xyz, patch[ 0].normalOS) - dot( patch[ 0].positionOS.xyz, patch[ 0].normalOS));
	float3 position1 = output.positionOS.xyz - patch[ 1].normalOS * (dot( output.positionOS.xyz, patch[ 1].normalOS) - dot( patch[ 1].positionOS.xyz, patch[ 1].normalOS));
	float3 position2 = output.positionOS.xyz - patch[ 2].normalOS * (dot( output.positionOS.xyz, patch[ 2].normalOS) - dot( patch[ 2].positionOS.xyz, patch[ 2].normalOS));
	output.positionOS.xyz = _TessPhongStrength * (position0 * barycentricCoordinates.x + position1 * barycentricCoordinates.y + position2 * barycentricCoordinates.z) + (1.0f - _TessPhongStrength) * output.positionOS.xyz;
	output.positionOS.xyz += output.normalOS.xyz * _TessExtrusionAmount;
	UNITY_TRANSFER_INSTANCE_ID( patch[0], output);
	return OutlinePassVertex( output);
}
ControlPoint OutlinePassTessellationVertex( Attributes input)
{   
	ControlPoint output;
	output.positionOS = input.positionOS;
	output.normalOS = normalize( input.normalOS);
	output.tangentOS = input.tangentOS;
	output.texcoord = input.texcoord;
	output.color = input.color;
	UNITY_TRANSFER_INSTANCE_ID( input, output);
	return output;
}
#endif
#endif
