Shader "Hidden/Mosaic"
{
	HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
	
	TEXTURE2D(_MaskTexture);
	SAMPLER(sampler_MaskTexture);
	
	float4 _MipmapLevel;
	float4 _MarginParam;
	
	half4 FragLOD( Varyings input) : SV_Target
	{
		clip( SAMPLE_TEXTURE2D_LOD( _MaskTexture, sampler_PointClamp, input.texcoord, _MipmapLevel.x).r - 0.001);
		return SAMPLE_TEXTURE2D_X( _BlitTexture, sampler_PointClamp, input.texcoord);
	}
	half4 FragMarginLOD( Varyings input) : SV_Target
	{
		float2 uv = input.texcoord;
		half r0 = SAMPLE_TEXTURE2D_LOD( _MaskTexture, sampler_PointClamp, uv, _MipmapLevel.x).r;
		half r1 = SAMPLE_TEXTURE2D_LOD( _MaskTexture, sampler_PointClamp, uv + _MarginParam.xz, _MipmapLevel.y).r;
		half r2 = SAMPLE_TEXTURE2D_LOD( _MaskTexture, sampler_PointClamp, uv - _MarginParam.xz, _MipmapLevel.y).r;
		half r3 = SAMPLE_TEXTURE2D_LOD( _MaskTexture, sampler_PointClamp, uv + _MarginParam.zy, _MipmapLevel.y).r;
		half r4 = SAMPLE_TEXTURE2D_LOD( _MaskTexture, sampler_PointClamp, uv - _MarginParam.zy, _MipmapLevel.y).r;
		clip( (r0 + r1 + r2 + r3 + r4) - 0.001);
		return SAMPLE_TEXTURE2D_X( _BlitTexture, sampler_PointClamp, uv);
	}
	half4 FragAlways( Varyings input) : SV_Target
	{
		return SAMPLE_TEXTURE2D_X( _BlitTexture, sampler_PointClamp, input.texcoord);
	}
	ENDHLSL
	
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
			#pragma fragment FragLOD
			ENDHLSL
		}
		Pass
		{
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment FragMarginLOD
			ENDHLSL
		}
	}
}