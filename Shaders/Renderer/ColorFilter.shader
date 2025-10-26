Shader "Hidden/ColorFilter"
{
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
		
		Pass
		{
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
			
			half4 _DotColor;
			half4 _MultiplyColor;
			half4 _AddColor;
			float4 _Param;
			#define _Contrast _Param.x
			#define _FlipX _Param.y
			#define _FlipY _Param.z
			
			half4 Frag( Varyings input) : SV_Target
			{
				float2 uv = input.texcoord;
				uv.x = lerp( uv.x, 1.0f - uv.x, _FlipX);
				uv.y = lerp( uv.y, 1.0f - uv.y, _FlipY);
				half4 color = SAMPLE_TEXTURE2D_X( _BlitTexture, sampler_LinearClamp, uv);
				color.rgb = lerp( color.rgb, dot( color.rgb, _DotColor.rgb), _DotColor.a);
				color.rgb = lerp( color.rgb, color.rgb * _MultiplyColor.rgb, _MultiplyColor.a);
				color.rgb = lerp( color.rgb, color.rgb + _AddColor.rgb, _AddColor.a);
				color.rgb = saturate( (saturate( color.rgb) - 0.5) * _Contrast + 0.5);
				return color;
			}
			ENDHLSL
		}
	}
}