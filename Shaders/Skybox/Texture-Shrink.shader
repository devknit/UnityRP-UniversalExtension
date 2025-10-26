
Shader "Knit/Skybox/Texture-Shrink"
{
	Properties
	{
		_MainTex( "Texture", 2D) = "white" {}
		[VectorRange2( 0, 1, 0, 0, 1, 0)]
		_Pivot( "Pivot", Vector) = (0.5, 0.5, 0, 0)
	}
	SubShader
	{
		Tags
		{
			"Queue"="Background"
			"RenderType"="Background"
			"PreviewType"="Skybox"
		}
		Cull Off ZWrite Off
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float2 _Pivot;
			
			void vert( float4 vertex : POSITION, out float4 texcoord : TEXCOORD0, out float4 position : SV_POSITION)
			{				
				position = UnityObjectToClipPos( vertex);
				texcoord = ComputeScreenPos( position);
			}
			fixed4 frag( float4 texcoord : TEXCOORD0) : SV_Target
			{
				float textureAspect = _MainTex_TexelSize.z / _MainTex_TexelSize.w;
				float screenAspect = _ScreenParams.x / _ScreenParams.y;
				float scale, offset;
					
				texcoord /= texcoord.w;
				
				if( screenAspect < textureAspect)
				{
					scale = screenAspect / textureAspect;
					offset = (1.0 - scale) * _Pivot.x;
					texcoord.x = texcoord.x * scale + offset;
				}
				else
				{
					scale = textureAspect / screenAspect;
					offset = (1.0 - scale) * _Pivot.y;
					texcoord.y = texcoord.y * scale + offset;
				} 
				return tex2D( _MainTex, texcoord);
			}
			ENDCG
		}
	}
}