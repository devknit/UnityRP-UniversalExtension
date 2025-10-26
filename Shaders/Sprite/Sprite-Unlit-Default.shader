Shader "Knit/2D/Sprite-Unlit-Default"
{
	Properties
	{
		_MainTex("Base Map", 2D) = "white" {}
		[HDR] _Color( "Color", Color) = (1,1,1,1)
		
		[Enum( UnityEngine.Rendering.CullMode)]
		_Cull( "Cull", Float) = 0 /* Off */
		[Enum( Off, 0, On, 1)]
		_ZWrite( "ZWrite", Float) = 0 /* Off */
		[Enum( UnityEngine.Rendering.CompareFunction)]
		_ZTest( "ZTest", Float) = 2 /* Less */
		[Enum( Off, 0, R, 8, G, 4, B, 2, A, 1, RGB, 14, RGBA, 15)]
		_ColorMask( "Color Mask", Float) = 15 /* RGBA */
		[Toggle] _AlphaTest( "Alpha Clipping", Float) = 0
		_Cutoff( "Cutoff Threshold", Range( 0.0, 1.0)) = 0
		
		[Enum( UnityEngine.Rendering.BlendOp)]
		_ColorBlendOp( "Color Blend Op", Float) = 0 /* Add */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_ColorSrcFactor( "Color Src Factor", Float) = 1 /* One */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_ColorDstFactor( "Color Dst Factor", Float) = 10 /* OneMinusSrcAlpha */
		[VectorRange2( RGB, 0, 1, 0, Alpha, 0, 2, 1)]
		_ColorPremultiply( "Color Premultiply", Vector) = (1, 1, 0, 0)
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
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"RenderPipeline" = "UniversalPipeline"
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
		Pass
		{
			Tags
			{
				"LightMode" = "Universal2D"
				"Queue"="Transparent"
				"RenderType"="Transparent"
			}
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma multi_compile _ DEBUG_DISPLAY SKINNED_SPRITE
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/Sprite/Sprite-Unlit-Default.hlsl"
			ENDHLSL
		}
		Pass
		{
			Tags
			{
				"LightMode" = "UniversalForward"
				"Queue"="Transparent"
				"RenderType"="Transparent"
			}
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma multi_compile _ DEBUG_DISPLAY SKINNED_SPRITE
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#include "Packages/com.devknit.rp.universal.extension/Shaders/Sprite/Sprite-Unlit-Default.hlsl"
			ENDHLSL
		}
	}
	Fallback "Sprites/Default"
	CustomEditor "Knit.RP.Core.Editor.ShaderGUI"
}
