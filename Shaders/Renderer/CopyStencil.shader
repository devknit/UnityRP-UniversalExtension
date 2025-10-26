Shader "Hidden/CopyStencil"
{
	Properties
	{
		_StencilRef( "Stencil Reference", Range( 0, 255)) = 1
		_StencilReadMask( "Stencil Read Mask", Range( 0, 255)) = 255
		[Enum( UnityEngine.Rendering.CompareFunction)]
		_StencilComp( "Stencil Comparison Function", float) = 3	/* Equal */
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
		
		Pass
		{
			Stencil
			{
				Ref [_StencilRef]
				ReadMask [_StencilReadMask]
				Comp [_StencilComp]
			}
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment FragMask
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
			
			half4 FragMask( Varyings input) : SV_Target
			{
				return half4( 1, 1, 1, 1);
			}
			ENDHLSL
		}
	}
}