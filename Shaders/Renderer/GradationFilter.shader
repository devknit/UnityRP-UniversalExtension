Shader "Hidden/GradationFilter"
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
			
			half4 _MultiplyColorLB;
			half4 _MultiplyColorRB;
			half4 _MultiplyColorLT;
			half4 _MultiplyColorRT;
			float4 _MultiplyParam;
			half4 _AddColorLB;
			half4 _AddColorRB;
			half4 _AddColorLT;
			half4 _AddColorRT;
			float4 _AddParam;
			float4 _AspectParam;
			float4 _RotateParam;
			
			#define _MultiplyOffset _MultiplyParam.xy
			#define _MultiplyScale _MultiplyParam.zw
			#define _MultiplyRotCos _RotateParam.x
			#define _MultiplyRotSin _RotateParam.y
			#define _MultiplyAspect _AspectParam.xy
			#define _AddOffset _AddParam.xy
			#define _AddScale _AddParam.zw
			#define _AddRotCos _RotateParam.z
			#define _AddRotSin _RotateParam.w
			#define _AddAspect _AspectParam.zw
			
			half4 Frag( Varyings input) : SV_Target
			{
				float2 uv = input.texcoord;
				half4 color = SAMPLE_TEXTURE2D_X( _BlitTexture, sampler_LinearClamp, uv);
				
				float2 multiplyT = mul( (uv - 0.5) * _MultiplyAspect * _MultiplyScale, 
					half2x2( _MultiplyRotCos, -_MultiplyRotSin, _MultiplyRotSin, _MultiplyRotCos)) + 0.5 + _MultiplyOffset;
				half4 multiplyColorB = lerp( _MultiplyColorLB, _MultiplyColorRB, multiplyT.x);
				half4 multiplyColorT = lerp( _MultiplyColorLT, _MultiplyColorRT, multiplyT.x);
				half4 multiplyColor = lerp( multiplyColorB, multiplyColorT, multiplyT.y);
				
				float2 addT = mul( (uv - 0.5) * _AddAspect * _AddScale, 
					half2x2( _AddRotCos, -_AddRotSin, _AddRotSin, _AddRotCos)) + 0.5 + _AddOffset;
				half4 addColorB = lerp( _AddColorLB, _AddColorRB, addT.x);
				half4 addColorT = lerp( _AddColorLT, _AddColorRT, addT.x);
				half4 addColor = lerp( addColorB, addColorT, addT.y);
				
				color.rgb = lerp( color.rgb, color.rgb * multiplyColor.rgb, multiplyColor.a);
				color.rgb = lerp( color.rgb, color.rgb + addColor.rgb, addColor.a);
				color.rgb = clamp( color.rgb, 0, 4);
				return color;
			}
			ENDHLSL
		}
	}
}