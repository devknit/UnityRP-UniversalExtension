Shader "Hidden/SpeedLine"
{
	Properties
	{
		[Enum( UnityEngine.Rendering.BlendMode)]
		_ColorSrcFactor( "Color Src Factor", Float) = 1 /* One */
		[Enum( UnityEngine.Rendering.BlendMode)]
		_ColorDstFactor( "Color Dst Factor", Float) = 0 /* Zero */
	}
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"Renderpipeline"="UniversalPipeline"
		}
		ZTest Always
		ZWrite Off
		Cull Off
		// Blend SrcAlpha OneMinusSrcAlpha, Zero One
		Blend [_ColorSrcFactor] [_ColorDstFactor], Zero One
		
		Pass
		{
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_local _ _ALPHA_BLEND_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
			#include "Packages/com.devknit.rp.universal.extension/ShaderLibrary/SimplexNoise.hlsl"
			
			half4 _Color;
			float4 _Param1;
			float4 _Param2;
			float4 _Param3;
			float4 _Param4;
			
			#define _Center			_Param1.xy
			#define _AxisMask		_Param1.zw
			#define _Sparse			_Param2.x
			#define _Remap			_Param2.y
			#define _SmoothBorder	_Param2.z
			#define _SmoothWidth	_Param2.w
			#define _Tiling			_Param3.x
			#define _RadialScale	_Param3.y
			#define _TimeScale		_Param3.z
			#define _Pattern		_Param3.w
			#define _RotateCos		_Param4.x
			#define _RotateSin		_Param4.y
			
			inline float Remap01n1( float v, float min)
			{
				return saturate( (v - min) / (1.0 - min));
			}
			half4 Frag( Varyings input) : SV_Target
			{
			#if !defined(_ALPHA_BLEND_ON)
				half4 color = SAMPLE_TEXTURE2D_X( _BlitTexture, sampler_LinearClamp, input.texcoord);
			#endif
				half2x2 rotate = half2x2( 
					_RotateCos, -_RotateSin, 
					_RotateSin, _RotateCos);
				float2 center = mul( input.texcoord - _Center, rotate);
				float t = _TimeScale * -_Time.y;
				float l = length( center);
				float r = atan2( center.x, center.y);
				r = lerp( 
					lerp( r, center.y, step( 0.5, _Pattern)),
					lerp( center.x, l, step( 2.5, _Pattern)),
					step( 1.5, _Pattern));
				float2 v = float2( (l * _RadialScale * 2.0) + t, (r * INV_TWO_PI * _Tiling));
				float n = abs( snoise( v) * 0.5 + 0.5);
				float b = _SmoothBorder * 0.5;
				float m = smoothstep( b - _SmoothWidth, b + _SmoothWidth, length( center * _AxisMask));
				float a = Remap01n1( pow( n * m, _Sparse), _Remap) * _Color.a;
			#if defined(_ALPHA_BLEND_ON)
				return half4( _Color.rgb, a);
			#else
				return lerp( color, _Color, a);
			#endif
			}
			ENDHLSL
		}
	}
}