
using UnityEngine;
using UnityEditor;

namespace Knit.Rendering.Universal
{
	static class DefaultMaterials
	{
	#if UNITY_EDITOR
		[InitializeOnLoadMethod]
		static void Initialize()
		{
			RuntimeInitialize();
		}
	#endif
		[RuntimeInitializeOnLoadMethod( RuntimeInitializeLoadType.BeforeSceneLoad)]
		static void RuntimeInitialize()
		{
			ReplaceCanvasShader( "Knit/UI/Default");
		}
		static void ReplaceCanvasShader( string shaderName)
		{
			var newShader = UnityEngine.Shader.Find( shaderName);
			if( newShader != null)
			{
				var currentMaterial = Canvas.GetDefaultCanvasMaterial();
				if( currentMaterial.shader.name != newShader.name)
				{
					currentMaterial.shader = newShader;
				}
			}
			else
			{
				Debug.LogError( $"Unable to replace default canvas material because {shaderName} shader was not found");
			}
		}
	}
}