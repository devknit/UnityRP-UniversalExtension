#ifndef __KNIT_3D_TOON_GLOBALI_LLUMINATION_HLSL__
#define __KNIT_3D_TOON_GLOBALI_LLUMINATION_HLSL__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

inline half3 EnvironmentSpecular( half3 specular, half roughness2, half grazingTerm, half fresnelTerm)
{
	float surfaceReduction = 1.0 / (roughness2 + 1.0);
	return half3( surfaceReduction * lerp( specular, grazingTerm, fresnelTerm));
}
inline half3 Environment( half3 diffuse, half3 indirectDiffuse, half3 specular, half3 indirectSpecular, half roughness2, half grazingTerm, half fresnelTerm)
{
	return (diffuse * indirectDiffuse) + EnvironmentSpecular( specular, roughness2, grazingTerm, fresnelTerm) * indirectSpecular;
}
inline half3 EnvironmentClearCoat( half clearCoatMask, half3 specular, half3 indirectSpecular, half roughness2, half grazingTerm, half fresnelTerm)
{
	float surfaceReduction = 1.0 / (roughness2 + 1.0);
	return indirectSpecular * EnvironmentSpecular( specular, roughness2, grazingTerm, fresnelTerm) * clearCoatMask;
}
half3 GlobalIllumination( inout SurfaceData surfaceData,
	half3 bakedGI, half occlusion, float3 positionWS,
	half3 normalWS, half3 viewDirectionWS, float2 normalizedScreenSpaceUV)
{
	half3 albedo = (1).xxx;
	half oneMinusReflectivity = OneMinusReflectivityMetallic( surfaceData.metallic);
	half reflectivity = 1.0h - oneMinusReflectivity;
	half3 diffuse = albedo * oneMinusReflectivity;
	half3 specular = lerp( kDielectricSpec.rgb, albedo, surfaceData.metallic);
	
	half perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness( surfaceData.smoothness);
	half roughness = max( PerceptualRoughnessToRoughness( perceptualRoughness), HALF_MIN_SQRT);
	half roughness2 = max( roughness * roughness, HALF_MIN);
	half grazingTerm = saturate( surfaceData.smoothness + reflectivity);
	
	half3 reflectVector = reflect( -viewDirectionWS, normalWS);
	half NoV = saturate( dot( normalWS, viewDirectionWS));
	half fresnelTerm = Pow4( 1.0 - NoV);
	
	half3 indirectDiffuse = bakedGI;
	half3 indirectSpecular = GlossyEnvironmentReflection( reflectVector, positionWS, perceptualRoughness, 1.0h, normalizedScreenSpaceUV);
	
	half3 color = Environment( diffuse, indirectDiffuse, specular, indirectSpecular, roughness2, grazingTerm, fresnelTerm);
	
	if( IsOnlyAOLightingFeatureEnabled())
	{
		color = half3( 1, 1, 1); // "Base white" for AO debug lighting mode
	}
#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
	half3 clearCoatSpecular = kDielectricSpec.rgb;
	half clearCoatPerceptualRoughness = PerceptualSmoothnessToPerceptualRoughness( surfaceData.clearCoatSmoothness);
	half clearCoatRoughness = max(PerceptualRoughnessToRoughness( clearCoatPerceptualRoughness), HALF_MIN_SQRT);
	half clearCoatRoughness2 = max( clearCoatRoughness * clearCoatRoughness, HALF_MIN);
	half clearCoatGrazingTerm = saturate( surfaceData.clearCoatSmoothness + kDielectricSpec.x);
	
	half3 coatIndirectSpecular = GlossyEnvironmentReflection( reflectVector, positionWS, clearCoatPerceptualRoughness, 1.0h, normalizedScreenSpaceUV);
	half3 coatColor = EnvironmentClearCoat( surfaceData.clearCoatMask, clearCoatSpecular, coatIndirectSpecular, clearCoatRoughness2, clearCoatGrazingTerm, fresnelTerm);
	half coatFresnel = kDielectricSpec.x + kDielectricSpec.a * fresnelTerm;
	return (color * (1.0 - coatFresnel * surfaceData.clearCoatMask) + coatColor) * occlusion;
#else
	return color * occlusion;
#endif
}
#endif
