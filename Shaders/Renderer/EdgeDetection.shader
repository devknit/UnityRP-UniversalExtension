Shader "Hidden/EdgeDetection"
{
	HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
	// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
	
	half4 _Color;
	half _Width;
	
	static const float4 kOne4 = float4( 1, 1, 1, 1);
	static const float4 kHorizDiagCoeff = float4( 1, 1, -1, -1);
	static const float4 kVertDiagCoeff = float4( -1, 1, -1, 1);
	static const float4 kHorizAxisCoeff = float4( 1, 0, 0, -1);
	static const float4 kVertAxisCoeff = float4( 0, 1, -1, 0);
	
	struct VertexOutput
	{
		float4 positionCS : SV_POSITION;
		float2 texcoord0   : TEXCOORD0;
		float2 texcoord1   : TEXCOORD1;
		UNITY_VERTEX_OUTPUT_STEREO
	};
	VertexOutput VertEdgeDetection( Attributes input)
	{
		VertexOutput output;
		UNITY_SETUP_INSTANCE_ID( input);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output);
		output.positionCS = GetFullScreenTriangleVertexPosition( input.vertexID);
		float2 texcoord = float2( (input.vertexID << 1) & 2, input.vertexID & 2);
		output.texcoord0 = DYNAMIC_SCALING_APPLY_SCALEBIAS( texcoord);
	#if UNITY_UV_STARTS_AT_TOP
		texcoord.y = 1.0 - texcoord.y; 
	#endif
		output.texcoord1 = DYNAMIC_SCALING_APPLY_SCALEBIAS( texcoord);
		return output;
	}
	half4 FragCheap( VertexOutput input) : SV_Target
	{
		float centerDepth = Linear01Depth( SampleSceneDepth( input.texcoord1), _ZBufferParams);
		float4 depthsDiag;
		float4 depthsAxis;
		
		float2 uvDist = _Width * _BlitTexture_TexelSize.xy;
		depthsDiag.x = Linear01Depth( SampleSceneDepth( input.texcoord1 + uvDist), _ZBufferParams);
		depthsDiag.y = Linear01Depth( SampleSceneDepth( float2( -1, 1) * uvDist + input.texcoord1), _ZBufferParams);
		depthsDiag.z = Linear01Depth( SampleSceneDepth( input.texcoord1 - uvDist * float2( -1, 1)), _ZBufferParams);
		depthsDiag.w = Linear01Depth( SampleSceneDepth( input.texcoord1 - uvDist), _ZBufferParams);
		depthsAxis.x = Linear01Depth( SampleSceneDepth( float2( 0, 1) * uvDist + input.texcoord1), _ZBufferParams);
		depthsAxis.y = Linear01Depth( SampleSceneDepth( input.texcoord1 - uvDist * float2( 1, 0)), _ZBufferParams);
		depthsAxis.z = Linear01Depth( SampleSceneDepth( float2( 1, 0) * uvDist + input.texcoord1), _ZBufferParams);
		depthsAxis.w = Linear01Depth( SampleSceneDepth( input.texcoord1 - uvDist * float2( 0, 1)), _ZBufferParams);
		
		half4 baseColor = SAMPLE_TEXTURE2D_X( _BlitTexture, sampler_LinearClamp, input.texcoord1);
		depthsDiag -= centerDepth;
		depthsAxis /= centerDepth;
		
		float4 sobelH = depthsDiag * kHorizDiagCoeff + depthsAxis * kHorizAxisCoeff;
		float4 sobelV = depthsDiag * kVertDiagCoeff + depthsAxis * kVertAxisCoeff;
		float sobelX = dot( sobelH, kOne4);
		float sobelY = dot( sobelV, kOne4);
		float sobel = 1.0 - saturate( sqrt( sobelX * sobelX + sobelY * sobelY)) * _Color.a;
		return half4( lerp( _Color.rgb, baseColor.rgb, sobel), baseColor.a);
	}
	half4 FragThin( VertexOutput input) : SV_Target
	{
		float centerDepth = Linear01Depth( SampleSceneDepth( input.texcoord1), _ZBufferParams);
		float4 depthsDiag;
		float4 depthsAxis;
		
		float2 uvDist = _Width * _BlitTexture_TexelSize.xy;
		depthsDiag.x = Linear01Depth( SampleSceneDepth( input.texcoord1 + uvDist), _ZBufferParams);
		depthsDiag.y = Linear01Depth( SampleSceneDepth( float2( -1, 1) * uvDist + input.texcoord1), _ZBufferParams);
		depthsDiag.z = Linear01Depth( SampleSceneDepth( input.texcoord1 - uvDist * float2( -1, 1)), _ZBufferParams);
		depthsDiag.w = Linear01Depth( SampleSceneDepth( input.texcoord1 - uvDist), _ZBufferParams);
		depthsAxis.x = Linear01Depth( SampleSceneDepth( float2( 0, 1) * uvDist + input.texcoord1), _ZBufferParams);
		depthsAxis.y = Linear01Depth( SampleSceneDepth( input.texcoord1 - uvDist * float2( 1, 0)), _ZBufferParams);
		depthsAxis.z = Linear01Depth( SampleSceneDepth( float2( 1, 0) * uvDist + input.texcoord1), _ZBufferParams);
		depthsAxis.w = Linear01Depth( SampleSceneDepth( input.texcoord1 - uvDist * float2( 0, 1)), _ZBufferParams);
		
		half4 baseColor = SAMPLE_TEXTURE2D_X( _BlitTexture, sampler_LinearClamp, input.texcoord1);
		depthsDiag = (depthsDiag > centerDepth.xxxx) ? depthsDiag : centerDepth.xxxx;
		depthsAxis = (depthsAxis > centerDepth.xxxx) ? depthsAxis : centerDepth.xxxx;
		depthsDiag -= centerDepth;
		depthsAxis /= centerDepth;
		
		float4 sobelH = depthsDiag * kHorizDiagCoeff + depthsAxis * kHorizAxisCoeff;
		float4 sobelV = depthsDiag * kVertDiagCoeff + depthsAxis * kVertAxisCoeff;
		float sobelX = dot( sobelH, kOne4);
		float sobelY = dot( sobelV, kOne4);
		float sobel = 1.0 - saturate( sqrt( sobelX * sobelX + sobelY * sobelY)) * _Color.a * baseColor.a;
		return half4( lerp( _Color.rgb, baseColor.rgb, sobel), baseColor.a);
	}
	ENDHLSL
	
	Properties
	{
		_StencilRef( "Stencil Reference", Range( 0, 255)) = 0
		_StencilReadMask( "Stencil Read Mask", Range( 0, 255)) = 255
		[Enum( UnityEngine.Rendering.CompareFunction)]
		_StencilComp( "Stencil Comparison Function", Float) = 8	/* Always */
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
		
		Stencil
		{
			Ref [_StencilRef]
			ReadMask [_StencilReadMask]
			Comp [_StencilComp]
		}
		Pass
		{
			HLSLPROGRAM
			#pragma vertex VertEdgeDetection
			#pragma fragment FragCheap
			ENDHLSL
		}
		Pass
		{
			HLSLPROGRAM
			#pragma vertex VertEdgeDetection
			#pragma fragment FragThin
			ENDHLSL
		}
	}
}