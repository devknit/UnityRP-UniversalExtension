#ifndef __KNIT_3D_SHADOW_CASTER_PASS_HLSL__
#define __KNIT_3D_SHADOW_CASTER_PASS_HLSL__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Wind.hlsl"
#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Dithering.hlsl"

// Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
// For Directional lights, _LightDirection is used when applying shadow Normal Bias.
// For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
float3 _LightDirection;
float3 _LightPosition;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
float4 GetShadowPositionHClip( Attributes input)
{
    float3 normalWS = TransformObjectToWorldNormal( input.normalOS);
    float3 positionWS = TransformObjectToWorldWind( input.positionOS.xyz, input.normalOS);
#if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirectionWS = normalize( _LightPosition - positionWS);
#else
    float3 lightDirectionWS = _LightDirection;
#endif
    float4 positionCS = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, lightDirectionWS));
#if UNITY_REVERSED_Z
    positionCS.z = min( positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max( positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif
    return positionCS;
}
Varyings ShadowPassVertex( Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID( input);
    UNITY_TRANSFER_INSTANCE_ID( input, output);
    
    output.uv = TRANSFORM_TEX( input.texcoord, _BaseMap);
    output.positionCS = GetShadowPositionHClip( input);
    return output;
}
half4 ShadowPassFragment( Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID( input);
	
	half4 albedoAlpha = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, input.uv);
	AlphaDiscard( input.positionCS, albedoAlpha.a * _BaseColor.a, _Cutoff, 0);
    return 0;
}
#endif
