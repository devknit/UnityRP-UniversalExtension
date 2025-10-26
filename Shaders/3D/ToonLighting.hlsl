#ifndef __KNIT_3D_TOON_LIGHTING_HLSL__
#define __KNIT_3D_TOON_LIGHTING_HLSL__

#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/Blend.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#if defined(LOD_FADE_CROSSFADE)
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonGlobalIllumination.hlsl"

TEXTURE2D( _ToonLightDistanceMap);
SAMPLER( sampler_ToonLightDistanceMap);

struct SpecularData
{
	float border;
	float softness;
	float illuminance;
};
inline void InitializeToonLitSpecularData( float2 uv, out SpecularData outSpecularData)
{
	half4 volume = SAMPLE_TEXTURE2D( _SpecularVolumeMap, sampler_SpecularVolumeMap, uv);
	outSpecularData.border = volume.r * _SpecularBorder;
	outSpecularData.softness = volume.g * _SpecularSoftness;
	outSpecularData.illuminance = volume.b * _SpecularIlluminance;
}
half3 CalculateToonShade( Light light, InputData inputData, inout SurfaceData surfaceData, SpecularData specularData, half3 sphereMapColor)
{
	float distanceAttenuation = SAMPLE_TEXTURE2D_LOD( _ToonLightDistanceMap, 
		sampler_ToonLightDistanceMap, float2( light.distanceAttenuation, 0), 0).r;
	half3 attenuatedLightColor = light.color * distanceAttenuation * smoothstep( 
		0.5 - _DiffuseSoftness, 0.5 + _DiffuseSoftness, light.shadowAttenuation);
	half NdotL = smoothstep( _DiffuseBorder - _DiffuseSoftness, _DiffuseBorder + _DiffuseSoftness, 
		dot( inputData.normalWS, light.direction));
	half NdotH = smoothstep( 
		specularData.border - specularData.softness, 
		specularData.border + specularData.softness, 
		dot( inputData.normalWS, SafeNormalize( float3( light.direction) + float3( inputData.viewDirectionWS))));
	half specularPower = specularData.illuminance * min( NdotL, NdotH);
	half3 lightDiffuseColor = attenuatedLightColor * NdotL;
	half3 lightSphereMapColor = attenuatedLightColor * sphereMapColor * NdotL;
	half3 lightSpecularColor = attenuatedLightColor * specularPower;
	return lightDiffuseColor * surfaceData.albedo + lightSpecularColor + lightSphereMapColor;
}
half3 CalculateLightingColor( half3 lightingColor, LightingData lightingData, half3 albedo)
{
	if( IsOnlyAOLightingFeatureEnabled())
	{
		return lightingData.giColor; // Contains white + AO
	}
	if( IsLightingFeatureEnabled( DEBUGLIGHTINGFEATUREFLAGS_GLOBAL_ILLUMINATION))
	{
		lightingColor = max( lightingColor, lightingData.giColor);
	}
	if( IsLightingFeatureEnabled( DEBUGLIGHTINGFEATUREFLAGS_MAIN_LIGHT))
	{
		lightingColor = max( lightingColor, lightingData.mainLightColor);
	}
	if( IsLightingFeatureEnabled( DEBUGLIGHTINGFEATUREFLAGS_ADDITIONAL_LIGHTS))
	{
		lightingColor = max( lightingColor, lightingData.additionalLightsColor);
	}
	if( IsLightingFeatureEnabled( DEBUGLIGHTINGFEATUREFLAGS_VERTEX_LIGHTING))
	{
		lightingColor = max( lightingColor, lightingData.vertexLightingColor);
	}
	lightingColor *= albedo;
	
	if( IsLightingFeatureEnabled( DEBUGLIGHTINGFEATUREFLAGS_EMISSION))
	{
		lightingColor += lightingData.emissionColor;
	}
	return lightingColor;
}
half4 CalculateFinalColor( half3 lightingColor, LightingData lightingData, half alpha)
{
	return half4( CalculateLightingColor( lightingColor, lightingData, 1), alpha);
}
half4 UniversalFragmentToonShade( InputData inputData, SurfaceData surfaceData, SpecularData specularData, half3 sphereMapColor)
{
#if defined(DEBUG_DISPLAY)
	half4 debugColor;
	
	if( CanDebugOverrideOutputColor( inputData, surfaceData, debugColor))
	{
		return debugColor;
	}
#endif
	uint meshRenderingLayers = GetMeshRenderingLayer();
	half4 shadowMask = CalculateShadowMask( inputData);
	AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor( inputData, surfaceData);
	aoFactor.indirectAmbientOcclusion = lerp( aoFactor.indirectAmbientOcclusion, 1.0f, surfaceData.alpha);
	aoFactor.directAmbientOcclusion = lerp( aoFactor.directAmbientOcclusion, 1.0f, surfaceData.alpha);
	Light mainLight = GetMainLight( inputData, shadowMask, aoFactor);
	
	MixRealtimeAndBakedGI( mainLight, inputData.normalWS, inputData.bakedGI, aoFactor);
	inputData.bakedGI *= surfaceData.albedo;
	inputData.bakedGI = lerp( inputData.bakedGI, BelndOverlay( 
		inputData.bakedGI, _ShadeColor.rgb), _ShadeColor.a);
	// inputData.bakedGI = GlobalIllumination( surfaceData,
	// 	inputData.bakedGI, aoFactor.indirectAmbientOcclusion, inputData.positionWS,
	// 	inputData.normalWS, inputData.viewDirectionWS, inputData.normalizedScreenSpaceUV);
	
	float distanceAttenuation = 0;
	LightingData lightingData = CreateLightingData( inputData, surfaceData);
	
#if defined(_LIGHT_LAYERS)
	if( IsMatchingLightLayer( mainLight.layerMask, meshRenderingLayers))
#endif
	{
		lightingData.mainLightColor += CalculateToonShade( mainLight, inputData, surfaceData, specularData, sphereMapColor);
	}
#if defined(_ADDITIONAL_LIGHTS)
	uint pixelLightCount = GetAdditionalLightsCount();
	
	#if USE_FORWARD_PLUS
	for( uint lightIndex = 0; lightIndex < min( URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
	{
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		
		Light light = GetAdditionalLight( lightIndex, inputData, shadowMask, aoFactor);
		#if defined(_LIGHT_LAYERS)
		if( IsMatchingLightLayer( light.layerMask, meshRenderingLayers))
		#endif
		{
			lightingData.additionalLightsColor += CalculateToonShade( light, inputData, surfaceData, specularData, sphereMapColor);
		}
		}
	#endif
	LIGHT_LOOP_BEGIN( pixelLightCount)
	Light light = GetAdditionalLight( lightIndex, inputData, shadowMask, aoFactor);
	#if defined(_LIGHT_LAYERS)
	if( IsMatchingLightLayer( light.layerMask, meshRenderingLayers))
	#endif
	{
		lightingData.additionalLightsColor += CalculateToonShade( light, inputData, surfaceData, specularData, sphereMapColor);
	}
	LIGHT_LOOP_END
#endif
	
#if defined(_ADDITIONAL_LIGHTS_VERTEX)
	lightingData.vertexLightingColor += inputData.vertexLighting * surfaceData.albedo;
#endif
	
	half3 rimlightColor = surfaceData.albedo;
	half NdotV = saturate( dot( inputData.normalWS, inputData.viewDirectionWS));
	NdotV = smoothstep( _RimlightBorder, saturate( _RimlightBorder + _RimlightSoftness), 1.0 - NdotV);
	rimlightColor = lerp( rimlightColor, BelndOverlay( rimlightColor, _RimlightColor.rgb), _RimlightColor.a);
	half rimlightPower = NdotV * _RimlightIlluminance;
	rimlightColor = rimlightColor * rimlightPower.xxx;
	surfaceData.alpha = max( surfaceData.alpha, lerp( surfaceData.alpha, min( 1, rimlightPower), _RimlightOverrideAlpha));
	
	return CalculateFinalColor( rimlightColor, lightingData, surfaceData.alpha);
}
#endif
