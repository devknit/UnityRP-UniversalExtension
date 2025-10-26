Shader "Knit/3D/ToonLit With Outline | Tessellation"
{
	Properties
	{
		[Toggle(_SURFACE_TYPE_TRANSPARENT)]
		_TransparentSurface( "Transparent Surface", Float) = 0
		[Toggle(_RECEIVE_SHADOWS_OFF)]
		_ReceiveShadowsOff( "Receive Shadows Off", Float) = 0
		
		[Maintexture] _BaseMap("Base Map", 2D) = "white" {}
		[BaseColor][HDR] _BaseColor( "Base Color", Color) = (1, 1, 1, 1)
		[HDR] _ShadeColor( "Shade Color", Color) = (0, 0, 0, 0)
		[NoScaleOffset] _ColorMaskMap("Color Mask Map", 2D) = "white" {}
		
		[Toggle(_NORMALMAP)] _NormalMap( "Normal (Option)", Float) = 0
		[NoScaleOffset] _BumpMap( "Normal Map", 2D) = "bump" {}
		_BumpScale( "Normal Scale", Float) = 1.0
		
		_DiffuseBorder( "Diffuse Border", Range( -1, 1)) = 0
		_DiffuseSoftness( "Diffuse Softness", Range( 0, 1)) = 0.05
		
		_SpecularBorder( "Specular Border", Range( -1, 1)) = 0.98
		_SpecularSoftness( "Specular Softness", Range( 0, 1)) = 0.002
		_SpecularIlluminance( "Specular Illuminance", Range( 0, 1)) = 0.0
		[NoScaleOffset] _SpecularVolumeMap( "Specular Volume Map", 2D) = "white" {}
		
		// _Metallic( "Metallic", Range( 0, 1)) = 0
		// _Smoothness( "Smoothness", Range( 0, 1)) = 0
		// _ClearCoatMask( "Clear Coat Mask", Range( 0, 1)) = 0
		// _ClearCoatSmoothness( "Clear Coat Smoothness", Range( 0, 1)) = 0
		
		[NoScaleOffset] _SphereMap( "Sphere Map", 2D) = "black" {}
		
		[HDR] _RimlightColor( "Rimlight Color", Color) = (0, 0, 0, 0)
		_RimlightBorder( "Rimlight Border", Range( 0, 1)) = 0.5
		_RimlightSoftness( "Rimlight Softness", Range( 0, 1)) = 0.02
		_RimlightIlluminance( "Rimlight Illuminance", Range( 0, 1)) = 0
		[HideInInspector] _RimlightOverrideAlpha( "Rimlight Override Alpha", Range( 0, 1)) = 0
		
		[NoScaleOffset] _EmissionMap( "Emission Map", 2D) = "white" {}
		[HDR] _EmissionColor( "Emission Color", Color) = (0, 0, 0)
		
		[Enum( UnityEngine.Rendering.CullMode)]
		_OutlineCull( "Outline Cull", Float) = 1 /* Front */
		_OutlineDirection( "Outline Direction", Range( 0.0, 1.0)) = 0.0
		[HDR] _OutlineColor( "Outline Color", Color) = (0.1, 0.1, 0.1, 0)
		_OutlineWidth( "Outline Width", Range( 0, 10)) = 1.5
		_OutlineOffsetZ( "Outline Offset Z", Range( 0, 1)) = 0.001
		[NoScaleOffset] _OutlineVolumeMap( "Outline Volume Map", 2D) = "white" {}
		
		[KeywordEnum( None, Simple)]
		_WindMode( "Wind Mode", Float) = 0
		_WindStrength( "Wind Strength", Range( 0, 1)) = 0.05
		
		_TessFactor( "Tessellation Factor", Range( 1, 50)) = 5
		_TessMinDistance( "Tessellation Min Distance", Range( 0.01, 50)) = 0.01
		_TessMaxDistance( "Tessellation Max Distance", Range( 0.01, 50)) = 5
		_TessPhongStrength( "Tessellation Phong Strength", Range( 0, 1)) = 0.5
		_TessExtrusionAmount( "Tessellation Extrusion Amount", Range( -0.005, 0.005)) = 0.0
		
		[Enum( UnityEngine.Rendering.CullMode)]
		_Cull( "Cull", Float) = 2 /* Back */
		[Enum( Off, 0, On, 1)]
		_ZWrite( "ZWrite", Float) = 1 /* On */
		[Enum( UnityEngine.Rendering.CompareFunction)]
		_ZTest( "ZTest", Float) = 2 /* Less */
		_OffsetZ( "Offset Z", Range( -1, 1)) = 0
		[Enum( Off, 0, R, 8, G, 4, B, 2, A, 1, RGB, 14, RGBA, 15)]
		_ColorMask( "Color Mask", Float) = 15 /* RGBA */
		[Toggle] _Dither( "Alpha Dithering", Float) = 1
		[Toggle] _AlphaTest( "Alpha Clipping", Float) = 1
		_Cutoff( "Cutoff Threshold", Range( 0.0, 1.0)) = 0.5
		
		[Enum( UnityEngine.Rendering.BlendOp)]
		_ColorBlendOp( "Color Blend Op", Float) = 0 /* Add */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_ColorSrcFactor( "Color Src Factor", Float) = 1 /* One */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_ColorDstFactor( "Color Dst Factor", Float) = 0 /* Zero */
		[VectorRange2( RGB, 0, 1, 0, Alpha, 0, 2, 1)]
		_ColorPremultiply( "Color Premultiply", Vector) = (0, 0, 0, 0)
		[Enum( UnityEngine.Rendering.BlendOp)]
		_AlphaBlendOp( "Alpha Blend Op", Float) = 0 /* Add */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_AlphaSrcFactor( "Alpha Src Factor", Float) = 1 /* One */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_AlphaDstFactor( "Alpha Dst Factor", Float) = 0 /* Zero */
		
		_Stencil( "Stencil ID", Range( 0, 255)) = 0
		_StencilReadMask( "Stencil Read Mask", Range( 0, 255)) = 255
		_StencilWriteMask( "Stencil Write Mask", Range( 0, 255)) = 255
		[Enum( UnityEngine.Rendering.CompareFunction)]
		_StencilComp( "Stencil Compare Function", Float) = 8
		[Enum( UnityEngine.Rendering.StencilOp)]
		_StencilOp( "Stencil Pass Operation", Float) = 0
		[Enum( UnityEngine.Rendering.StencilOp)]
		_StencilFail( "Stencil Fail Operation", Float) = 0
		[Enum( UnityEngine.Rendering.StencilOp)]
		_StencilZFail( "Stencil ZFail Operation", Float) = 0
	}
	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			// "UniversalMaterialType" = "SimpleLit" //?
			"RenderPipeline" = "UniversalPipeline"
		}
		Pass
		{
			Name "Forward"
			Tags
			{
				"LightMode" = "UniversalForwardOnly"
			}
			Cull [_Cull]
			ZWrite [_ZWrite]
			ZTest [_ZTest]
			BlendOp [_ColorBlendOp], [_AlphaBlendOp]
			Blend [_ColorSrcFactor] [_ColorDstFactor], [_AlphaSrcFactor] [_AlphaDstFactor]
			ColorMask [_ColorMask]
			
			Stencil
			{
				Ref [_Stencil]
				ReadMask [_StencilReadMask]
				WriteMask [_StencilWriteMask]
				Comp [_StencilComp]
				Pass [_StencilOp]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}
			HLSLPROGRAM
			#pragma target 5.0
			#pragma only_renderers d3d11 xboxone ps4 switch
			
			// -------------------------------------
			// Shader Stages
			#pragma require tessellation
			#pragma vertex LitPassTessellationVertexToon
			#pragma hull LitPassHullToon
			#pragma domain LitPassDomainToon
			#pragma fragment LitPassFragmentToon
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ _SCREEN_SPACE_OCCLUSION_OFF
			
			// -------------------------------------
			// Universal Pipeline keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ _LIGHT_LAYERS
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fog
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// Includes
			#define TESSELLATION_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitForwardPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "ShadowCaster"
			Tags
			{
				"LightMode" = "ShadowCaster"
			}
			ZWrite On
			ColorMask 0
			Cull [_Cull]
			
			HLSLPROGRAM
			#pragma target 2.0
			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_vertex _ _WINDMODE_SIMPLE
			
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			
			// -------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
			
			// -------------------------------------
			// Includes
			#define TESSELLATION_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ShadowCasterPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "DepthOnly"
			Tags
			{
				"LightMode" = "DepthOnly"
			}
			ZWrite On
			ColorMask R
			Cull [_Cull]
			
			HLSLPROGRAM
			#pragma target 5.0
			#pragma only_renderers d3d11 xboxone ps4 switch
			
			// -------------------------------------
			// Shader Stages
			#pragma require tessellation
			#pragma vertex DepthOnlyTessellationVertex
			#pragma hull DepthOnlyHull
			#pragma domain DepthOnlyDomain
			#pragma fragment DepthOnlyFragment
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_vertex _ _WINDMODE_SIMPLE
			
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// Includes
			#define TESSELLATION_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/DepthOnlyPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "DepthNormals"
			Tags
			{
				"LightMode" = "DepthNormals"
			}
			ZWrite On
			Cull [_Cull]
			
			HLSLPROGRAM
			#pragma target 5.0
			#pragma only_renderers d3d11 xboxone ps4 switch
			
			// -------------------------------------
			// Shader Stages
			#pragma require tessellation
			#pragma vertex DepthNormalsTessellationVertex
			#pragma hull DepthNormalsHull
			#pragma domain DepthNormalsDomain
			#pragma fragment DepthNormalsFragment
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_vertex _ _WINDMODE_SIMPLE
			
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			
			// Universal Pipeline keywords
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// Includes
			#define TESSELLATION_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/DepthNormalsPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "Outline"
			Tags
			{
				"LightMode" = "OutlineOnly"
			}
			Cull [_OutlineCull]
			ZWrite On
			ZTest Less
			BlendOp [_ColorBlendOp], [_AlphaBlendOp]
			Blend [_ColorSrcFactor] [_ColorDstFactor], [_AlphaSrcFactor] [_AlphaDstFactor]
			ColorMask [_ColorMask]
			
			Stencil
			{
				Ref [_Stencil]
				ReadMask [_StencilReadMask]
				WriteMask [_StencilWriteMask]
				Comp [_StencilComp]
				Pass [_StencilOp]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}
			HLSLPROGRAM
			#pragma target 5.0
			#pragma only_renderers d3d11 xboxone ps4 switch
			
			// -------------------------------------
			// Shader Stages
			#pragma require tessellation
			#pragma vertex OutlinePassTessellationVertex
			#pragma hull OutlinePassHull
			#pragma domain OutlinePassDomain
			#pragma fragment OutlinePassFragment
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_vertex _ _WINDMODE_SIMPLE
			
			// -------------------------------------
			// Universal Pipeline keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ _LIGHT_LAYERS
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile_fog
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			//--------------------------------------
			// Defines
			#define OUTLINE_ON 1
			
			// -------------------------------------
			// Includes
			#define TESSELLATION_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/OutlinePass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "Meta"
			Tags
			{
				"LightMode" = "Meta"
			}
			// -------------------------------------
			// Render State Commands
			Cull Off
			
			HLSLPROGRAM
			#pragma target 2.0
			
			// -------------------------------------
			// Shader Stages
			#pragma vertex UniversalVertexMeta
			#pragma fragment UniversalFragmentMetaSimple
			
			// -------------------------------------
			// Material Keywords
			// #pragma shader_feature_local_fragment _EMISSION
			// #pragma shader_feature_local_fragment _SPECGLOSSMAP
			#pragma shader_feature EDITOR_VISUALIZATION
			
			// -------------------------------------
			// Includes
			#define TESSELLATION_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "Universal2D"
			Tags
			{
				"LightMode" = "Universal2D"
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
			}
			HLSLPROGRAM
			#pragma target 2.0
			
			// -------------------------------------
			// Shader Stages
			#pragma vertex vert
			#pragma fragment frag
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// Includes
			#define TESSELLATION_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "MotionVectors"
			Tags
			{
				"LightMode" = "MotionVectors"
			}
			ColorMask RG
			
			HLSLPROGRAM
			#pragma shader_feature_local _ _ALPHATEST_ON
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma shader_feature_local_vertex _ADD_PRECOMPUTED_VELOCITY
			
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ToonLitInput.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ObjectMotionVectors.hlsl"
			ENDHLSL
		}
	}
	Fallback "Zurp/3D/ToonLit With Outline"
	CustomEditor "Knit.RP.Universal.Editor.ToonLitGUI"
}
