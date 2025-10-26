Shader "Knit/3D/Unlit Without Outline"
{
	Properties
	{
		[Toggle(_SURFACE_TYPE_TRANSPARENT)]
		_TransparentSurface( "Transparent Surface", Float) = 0
		[Toggle(_RECEIVE_SHADOWS_OFF)]
		_ReceiveShadowsOff( "Receive Shadows Off", Float) = 0
		
		[Maintexture] _BaseMap("Base Map", 2D) = "white" {}
		[BaseColor][HDR] _BaseColor( "Base Color", Color) = (1, 1, 1, 1)
		
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
			"UniversalMaterialType" = "Unlit"
			"RenderPipeline" = "UniversalPipeline"
		}
		Pass
		{
			Name "Forward"
			Tags
			{
				"LightMode" = "UniversalForwardOnly" // UniversalForward にして GBuffer を実装予定
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
			#pragma target 2.0
			
			// -------------------------------------
			// Shader Stages
			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ _SCREEN_SPACE_OCCLUSION_OFF
			
			// -------------------------------------
			// Universal Pipeline keywords
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			
			// -------------------------------------
			// Unity defined keywords
			
			
			#pragma multi_compile_fog
			#pragma multi_compile _ DEBUG_DISPLAY
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// Includes
			#define VERTEXCOLOR_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/UnlitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/UnlitForwardPass.hlsl"
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
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/UnlitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/ShadowCasterPass.hlsl"
			ENDHLSL
		}
		// Pass
		// {
		// 	Name "GBuffer"
		// 	Tags
		// 	{
		// 		"LightMode" = "UniversalGBuffer"
		// 	}
		// 	HLSLPROGRAM
		// 	#pragma target 4.5
		// 	#pragma exclude_renderers gles3 glcore
		// 	#pragma vertex UnlitPassVertex
		// 	#pragma fragment UnlitPassFragment
			
		// 	// -------------------------------------
		// 	// Material Keywords
		// 	#pragma shader_feature_local_fragment _ALPHATEST_ON
			
		// 	// -------------------------------------
		// 	// Unity defined keywords
		// 	#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
		// 	#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
		// 	#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
		// 	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
		// 	#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			
		// 	//--------------------------------------
		// 	// GPU Instancing
		// 	#pragma multi_compile_instancing
		// 	#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
		// 	// -------------------------------------
		// 	// Includes
		// 	#include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
		// 	#include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitGBufferPass.hlsl"
		// 	ENDHLSL
		// }
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
			#pragma target 2.0
			
			// -------------------------------------
			// Shader Stages
			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// Includes
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/UnlitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/DepthOnlyPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "DepthNormals"
			Tags
			{
				"LightMode" = "DepthNormalsOnly" // DepthNormals?
			}
			ZWrite On
			Cull [_Cull]
			
			HLSLPROGRAM
			#pragma target 2.0
			
			// -------------------------------------
			// Shader Stages
			#pragma vertex DepthNormalsVertex
			#pragma fragment DepthNormalsFragment
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			// #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT // forward-only variant
			
			// Universal Pipeline keywords
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// Includes
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/UnlitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/DepthNormalsPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "TransparentDepthOnly"
			Tags
			{
				"LightMode" = "TransparentDepthOnly"
			}
			ZWrite On
			ZTest LEqual
			Blend Zero One
			Cull [_Cull]
			
			HLSLPROGRAM
			#pragma target 2.0
			
			// -------------------------------------
			// Shader Stages
			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment
			
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			
			// -------------------------------------
			// Includes
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/UnlitInput.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/DepthOnlyPass.hlsl"
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
			#pragma fragment UniversalFragmentMetaUnlit
			
			// -------------------------------------
			// Unity defined keywords
			#pragma shader_feature EDITOR_VISUALIZATION
			
			// -------------------------------------
			// Includes
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/UnlitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitMetaPass.hlsl"
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
			
			#include "Packages/com.devknit.rp.universal.extension/Shaders/3D/UnlitInput.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ObjectMotionVectors.hlsl"
			ENDHLSL
		}
	}
	Fallback "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "Knit.RP.Universal.Editor.UnlitGUI"
}
