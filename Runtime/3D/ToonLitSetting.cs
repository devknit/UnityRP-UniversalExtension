
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections.Generic;

namespace Knit.Rendering.Universal
{
	[ExecuteInEditMode]
	internal sealed class ToonLitSetting : MonoBehaviour
	{
		internal void OnEnable()
		{
			if( gameObject.scene == SceneManager.GetActiveScene())
			{
				SetLightDistanceMap();
			}
			if( s_Components.ContainsKey( gameObject.scene.path) == false)
			{
				s_Components.Add( gameObject.scene.path, this);
			}
		}
		void OnDisable()
		{
			if( gameObject.scene == SceneManager.GetActiveScene())
			{
				SetDefaultLightDistanceMap();
			}
			if( s_Components.ContainsKey( gameObject.scene.path) != false)
			{
				s_Components.Remove( gameObject.scene.path);
			}
		}
		void SetLightDistanceMap()
		{
			UnityEngine.Shader.SetGlobalTexture( kLightDistanceMap, (m_LightDistanceMap != null)? m_LightDistanceMap : CreateAndGetLightDistanceMap());
		}
		static void SetDefaultLightDistanceMap()
		{
			UnityEngine.Shader.SetGlobalTexture( kLightDistanceMap, CreateAndGetLightDistanceMap());
		}
		static Texture2D CreateAndGetLightDistanceMap()
		{
			if( s_DefaultLightDistanceMap == null)
			{
				s_DefaultLightDistanceMap = new Texture2D( kDefaultLightMapWidth, kDefaultLightMapHeight, TextureFormat.R8, false, true)
				{
					wrapMode = TextureWrapMode.Clamp,
					filterMode = FilterMode.Bilinear
				};
				var colors = new Color32[ kDefaultLightMapWidth * 1];
				
				for( int x = 0; x < kDefaultLightMapWidth; ++x)
				{
					byte value = (byte)(x / (float)(kDefaultLightMapWidth - 1) * 255.0f);
					colors[ x] = new Color32( value, value, value, 255);
				}
				s_DefaultLightDistanceMap.SetPixels32( 0, 0, kDefaultLightMapWidth, kDefaultLightMapHeight, colors, 0);
				s_DefaultLightDistanceMap.Apply();
			}
			return s_DefaultLightDistanceMap;
		}
		static void ActiveSceneChanged( Scene thisScene, Scene nextScene)
		{
			if( s_Components.TryGetValue( nextScene.path, out ToonLitSetting component) != false)
			{
				component.OnEnable();
			}
			else
			{
				SetDefaultLightDistanceMap();
			}
		}
		[RuntimeInitializeOnLoadMethod( RuntimeInitializeLoadType.BeforeSceneLoad)]
		static void OnRuntimeInitialized()
		{
			SceneManager.activeSceneChanged += ActiveSceneChanged;
			SetDefaultLightDistanceMap();
		}
	#if UNITY_EDITOR
		[UnityEditor.InitializeOnLoadMethod]
		static void Initialize()
		{
			UnityEditor.SceneManagement.EditorSceneManager.activeSceneChangedInEditMode += ActiveSceneChanged;
			SetDefaultLightDistanceMap();
		}
		void OnValidate()
		{
			if( Application.isPlaying == false)
			{
				OnEnable();
			}
		}
	#endif
		const string kLightDistanceMap = "_ToonLightDistanceMap";
		internal const int kDefaultLightMapWidth = 64;
		internal const int kDefaultLightMapHeight = 1;
		static Texture2D s_DefaultLightDistanceMap;
		static Dictionary<string, ToonLitSetting> s_Components = new();
		
		[SerializeField]
		Texture2D m_LightDistanceMap;
	}
}
