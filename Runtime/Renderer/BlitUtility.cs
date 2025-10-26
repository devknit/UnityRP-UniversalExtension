
using UnityEngine;
using UnityEngine.Rendering;

namespace Knit.Rendering.Universal
{
	internal static class BlitUtility
	{
		public static class BlitShaderIDs
		{
			public static readonly int kBlitTexture = Shader.PropertyToID( "_BlitTexture");
			public static readonly int kBlitScaleBias = Shader.PropertyToID( "_BlitScaleBias");
		}
		public static Vector4 GetScaleBias( RTHandle source)
		{
			if( source.useScaling == false)
			{
				return Vector2.one;
			}
			RTHandleProperties rtHandleProperties = source.rtHandleProperties;
			ref Vector4 rtHandleScale = ref rtHandleProperties.rtHandleScale;
			return new Vector2( rtHandleScale.x, rtHandleScale.y);
		}
		public static void BlitCameraTexture( CommandBuffer commandBuffer, RTHandle source, RTHandle destination, float mipLevel, bool bilinear)
		{
			commandBuffer.SetRenderTarget( destination, 
				RenderBufferLoadAction.DontCare,  RenderBufferStoreAction.Store, 
				RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
			Blitter.BlitTexture( commandBuffer, source, GetScaleBias( source), mipLevel, bilinear);
		}
		public static void BlitCameraTexture( CommandBuffer commandBuffer, RTHandle source, RTHandle destination, Material material, int pass)
		{
			commandBuffer.SetRenderTarget( destination, 
				RenderBufferLoadAction.DontCare,  RenderBufferStoreAction.Store, 
				RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
			Blitter.BlitTexture( commandBuffer, source, GetScaleBias( source), material, pass);
		}
		public static void SetTexture( int nameID, Texture value)
		{
			s_PropertyBlock.SetTexture( nameID, value);
		}
		public static void SetBlitTexture( Texture value)
		{
			s_PropertyBlock.SetTexture( BlitShaderIDs.kBlitTexture, value);
		}
		public static void DrawTriangle( CommandBuffer commandBuffer, Material material, int shaderPass)
		{
			s_PropertyBlock.SetVector( BlitShaderIDs.kBlitScaleBias, Vector2.one);
			
			if( SystemInfo.graphicsShaderLevel < 30)
			{
				if( s_TriangleMesh == null)
				{
					Initialize();
				}
				commandBuffer.DrawMesh( s_TriangleMesh, Matrix4x4.identity, material, 0, shaderPass, s_PropertyBlock);
			}
			else
			{
				commandBuffer.DrawProcedural( Matrix4x4.identity, material, shaderPass, MeshTopology.Triangles, 3, 1, s_PropertyBlock);
			}
		}
		internal static void Initialize()
		{
			if( SystemInfo.graphicsShaderLevel < 30)
			{
				float nearClipZ = (SystemInfo.usesReversedZBuffer != false)? 1 : -1;
				
				s_TriangleMesh ??= new Mesh
				{
					vertices = GetFullScreenTriangleVertexPosition( nearClipZ),
					uv = GetFullScreenTriangleTexCoord(),
					triangles = new int[ 3]{ 0, 1, 2 }
				};
				s_QuadMesh ??= new Mesh
				{
					vertices = GetQuadVertexPosition(nearClipZ),
					uv = GetQuadTexCoord(),
					triangles = new int[6] { 0, 1, 2, 0, 2, 3 }
				};
				static Vector3[] GetFullScreenTriangleVertexPosition( float z)
				{
					var vertices = new Vector3[ 3];
					
					for( int i0 = 0; i0 < 3; ++i0)
					{
						var uv = new Vector2( (i0 << 1) & 2, i0 & 2);
						vertices[ i0] = new Vector3( uv.x * 2.0f - 1.0f, uv.y * 2.0f - 1.0f, z);
					}
					return vertices;
				}
				static Vector2[] GetFullScreenTriangleTexCoord()
				{
					var uv = new Vector2[ 3];
					
					for( int i0 = 0; i0 < 3; ++i0)
					{
						uv[ i0] = (SystemInfo.graphicsUVStartsAtTop != false)?
							new Vector2( (i0 << 1) & 2, 1.0f - (i0 & 2)):
							new Vector2( (i0 << 1) & 2, i0 & 2);
					}
					return uv;
				}
				static Vector3[] GetQuadVertexPosition( float z)
				{
					var vertices = new Vector3[ 4];
					
					for( uint i0 = 0; i0 < 4; ++i0)
					{
						uint topBit = i0 >> 1;
						uint botBit = i0 & 1;
						float x = topBit;
						float y = 1 - (topBit + botBit) & 1;
						vertices[ i0] = new Vector3( x, y, z);
					}
					return vertices;
				}
				static Vector2[] GetQuadTexCoord()
				{
					var uv = new Vector2[ 4];
					
					for( uint i0 = 0; i0 < 4; ++i0)
					{
						uint topBit = i0 >> 1;
						uint botBit = i0 & 1;
						float u = topBit;
						float v = (topBit + botBit) & 1;
						
						if (SystemInfo.graphicsUVStartsAtTop != false)
						{
							v = 1.0f - v;
						}
						uv[ i0] = new Vector2( u, v);
					}
					return uv;
				}
			}
		}
		static readonly MaterialPropertyBlock s_PropertyBlock = new();
		static Mesh s_TriangleMesh;
		static Mesh s_QuadMesh;
	}
}