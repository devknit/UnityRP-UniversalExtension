Shader "Knit/UI/Default"
{
	Properties
	{
		[PerRendererData] _MainTex( "Sprite Texture", 2D) = "white" {}
		[HDR] _Color( "Tint", Color) = (1,1,1,1)
		
		[Enum( UnityEngine.Rendering.CullMode)]
		_Cull( "Cull", Float) = 0 /* Off */
		[Enum( Off, 0, On, 1)]
		_ZWrite( "ZWrite", Float) = 0 /* Off */
		// [Enum( UnityEngine.Rendering.CompareFunction)]
		// _ZTest( "ZTest", Float) = 2 /* Less */
		[Enum( Off, 0, R, 8, G, 4, B, 2, A, 1, RGB, 14, RGBA, 15)]
		_ColorMask( "Color Mask", Float) = 15 /* RGBA */
		[Toggle( UNITY_UI_ALPHACLIP)]
		_UseUIAlphaClip( "Use UI Alpha Clip", Float) = 0
		
		[Enum( UnityEngine.Rendering.BlendOp)]
		_ColorBlendOp( "Color Blend Op", Float) = 0 /* Add */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_ColorSrcFactor( "Color Src Factor", Float) = 1 /* One */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_ColorDstFactor( "Color Dst Factor", Float) = 10 /* OneMinusSrcAlpha */
		[Enum( UnityEngine.Rendering.BlendOp)]
		_AlphaBlendOp( "Alpha Blend Op", Float) = 0 /* Add */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_AlphaSrcFactor( "Alpha Src Factor", Float) = 1 /* One */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_AlphaDstFactor( "Alpha Dst Factor", Float) = 10 /* OneMinusSrcAlpha */
		
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
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Transparent"
			"Queue"="Transparent"
			// DisableBatching: <None>
			"ShaderGraphShader"="true"
			"ShaderGraphTargetId"="UniversalCanvasSubTarget"
			"IgnoreProjector"="True"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		Lighting Off
		Cull [_Cull]
		ZWrite [_ZWrite]
		ZTest [unity_GUIZTestMode]
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
			Name "Default"
			HLSLPROGRAM
			#pragma target 2.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			float4 _TextureSampleAdd;
			float _UIMaskSoftnessX;
			float _UIMaskSoftnessY;
			float4 _ClipRect;
			
			CBUFFER_START( UnityPerMaterial)
				float4 _MainTex_ST;
				float4 _Color;
				int _UIVertexColorAlwaysGammaSpace;
			CBUFFER_END
			
			struct Attributes
			{
				float4 positionOS : POSITION;
				float4 color : COLOR;
				float4 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 color : COLOR;
				float4 texcoord : TEXCOORD0;
				float4 positionOS : TEXCOORD1;
				float4 mask : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			// This piecewise approximation has a precision better than 0.5 / 255 in gamma space over the [0..255] range
			// i.e. abs(l2g_exact(g2l_approx(value)) - value) < 0.5 / 255
			// It is much more precise than GammaToLinearSpace but remains relatively cheap
			half3 GammaToLinear( half3 value)
			{
				half3 low = 0.0849710 * value - 0.000163029;
				half3 high = value * (value * (value * 0.265885 + 0.736584) - 0.00980184) + 0.00319697;
				
				// We should be 0.5 away from any actual gamma value stored in an 8 bit channel
				const half3 split = (half3)0.0725490; // Equals 18.5 / 255
				return (value < split) ? low : high;
			}
			Varyings vert( Attributes input)
			{
				Varyings output = (Varyings)0;
				
				UNITY_SETUP_INSTANCE_ID( input);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output);
				UNITY_TRANSFER_INSTANCE_ID( input, output);
				
				float4 positionCS = TransformObjectToHClip( input.positionOS.xyz);
				output.positionCS = positionCS;
				output.positionOS = input.positionOS;
				
				float2 pixelSize = positionCS.w;
				pixelSize /= float2( 1, 1) * abs( mul( (float2x2)UNITY_MATRIX_P, _ScreenParams.xy));
				
				float4 clampedRect = clamp( _ClipRect, -2e10, 2e10);
				output.mask = float4( input.positionOS.xy * 2 - clampedRect.xy - clampedRect.zw,
						0.25 / (0.25 * half2( _UIMaskSoftnessX, _UIMaskSoftnessY) + abs( pixelSize.xy)));
				output.texcoord.xy = TRANSFORM_TEX( input.texcoord.xy, _MainTex);
				output.texcoord.zw = input.texcoord.zw;
				
			#if defined(UNITY_COLORSPACE_GAMMA)
				input.color.rgb = lerp( input.color.rgb, GammaToLinear( input.color.rgb), _UIVertexColorAlwaysGammaSpace);
			#endif
				output.color = input.color * _Color;
				return output;
			}
			half4 frag( Varyings input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input);
				
				//Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
				//The incoming alpha could have numerical instability, which makes it very sensible to
				//HDR color transparency blend, when it blends with the world's texture.
				const half alphaPrecision = half( 0xff);
				const half invAlphaPrecision = half( 1.0 / alphaPrecision);
				
				input.color.a = round( input.color.a * alphaPrecision) * invAlphaPrecision;
				half4 color = input.color * (SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, input.texcoord.xy) + _TextureSampleAdd);
				
			#if defined(UNITY_UI_CLIP_RECT)
				half2 m = saturate( (_ClipRect.zw - _ClipRect.xy - abs( input.mask.xy)) * input.mask.zw);
				color.a *= m.x * m.y;
			#endif
			#if defined(UNITY_UI_ALPHACLIP)
				clip( color.a - 0.0001);
			#endif
				color.rgb = lerp( color.rgb * color.a, color.rgb, input.texcoord.z);
				color.a *= 1.0 - input.texcoord.w;
				return color;
			}
			ENDHLSL
		}
	}
	FallBack "UI/Default"
	CustomEditor "Knit.RP.Core.Editor.ShaderGUI"
}
