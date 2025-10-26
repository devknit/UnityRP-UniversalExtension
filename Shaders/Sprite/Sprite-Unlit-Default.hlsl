#ifndef __KNIT_2D_SPRITE_UNLIT_DEFAULT_HLSL__
#define __KNIT_2D_SPRITE_UNLIT_DEFAULT_HLSL__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"
#if defined(DEBUG_DISPLAY)
	#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/InputData2D.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"
#endif
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/DebuggingCommon.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/ColorPremultiply.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START( UnityPerMaterial)
	float4 _MainTex_ST;
	half4 _Color;
	half _Cutoff;
	half2 _ColorPremultiply;
CBUFFER_END

struct Attributes
{
	float3 positionOS : POSITION;
	float4 color : COLOR;
	float4 texcoord : TEXCOORD0;
	UNITY_SKINNED_VERTEX_INPUTS
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
	float4 positionCS : SV_POSITION;
	float4 color : COLOR;
	float2 texcoord : TEXCOORD0;
#if defined(DEBUG_DISPLAY)
	float3 positionWS : TEXCOORD1;
#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};
Varyings vert( Attributes input)
{
	Varyings output = (Varyings)0;
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_SKINNED_VERTEX_COMPUTE( input);
	UNITY_TRANSFER_INSTANCE_ID( input, output); 
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output);
	
	input.positionOS = UnityFlipSprite( input.positionOS, unity_SpriteProps.xy);
	output.positionCS = TransformObjectToHClip( input.positionOS);
#if defined(DEBUG_DISPLAY)
	output.positionWS = TransformObjectToWorld( input.positionOS);
#endif
	output.texcoord = TRANSFORM_TEX( input.texcoord, _MainTex);
	output.color = input.color * _Color * unity_SpriteColor;
	return output;
}
half4 frag( Varyings input) : SV_Target
{
	UNITY_SETUP_INSTANCE_ID( input);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input);
	
	float4 color = input.color * SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, input.texcoord);
#if defined(_ALPHATEST_ON)
	clip( color.a - _Cutoff - 0.0001);
#endif
#if defined(DEBUG_DISPLAY)
	SurfaceData2D surfaceData;
	InputData2D inputData;
	half4 debugColor = 0;
	
	InitializeSurfaceData( color.rgb, color.a, surfaceData);
	InitializeInputData( input.texcoord, inputData);
	SETUP_DEBUG_DATA_2D( inputData, input.positionWS);
	
	if( CanDebugOverrideOutputColor( surfaceData, inputData, debugColor))
	{
		return debugColor;
	}
#endif
	return ColorPremultiply( color, _ColorPremultiply);
}
#endif
