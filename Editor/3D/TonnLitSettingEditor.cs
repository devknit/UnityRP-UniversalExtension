
using UnityEngine;
using UnityEditor;
using System.IO;

namespace Knit.Rendering.Universal
{
	[CustomEditor( typeof( ToonLitSetting), true)]
	sealed class ToonLitSettingEditor : UnityEditor.Editor
	{
		public override void OnInspectorGUI()
		{
			base.OnInspectorGUI();
			
			EditorGUILayout.CurveField( "Generate Texture Curve", m_Curve);
			
			using( new EditorGUILayout.HorizontalScope())
			{
				GUILayout.FlexibleSpace();
				
				if( GUILayout.Button( "Generate") != false)
				{
					Generate();
				}
			}
		}
		void Generate()
		{
			string assetPath = EditorUtility.SaveFilePanel( "Save texture as PNG", "", "LightDistanceMap.png", "png");
			
			if( assetPath.StartsWith( Application.dataPath) != false)
			{
				assetPath = Path.Combine( "Assets", Path.GetRelativePath( Application.dataPath, assetPath)).Replace( '\\', '/');
				
				var texture = new Texture2D( ToonLitSetting.kDefaultLightMapWidth, ToonLitSetting.kDefaultLightMapHeight, TextureFormat.R8, false, true)
				{
					wrapMode = TextureWrapMode.Clamp,
					filterMode = FilterMode.Bilinear
				};
				var colors = new Color32[ ToonLitSetting.kDefaultLightMapWidth * 1];
				
				for( int x = 0; x < ToonLitSetting.kDefaultLightMapWidth; ++x)
				{
					byte value = (byte)( m_Curve.Evaluate( x / (float)(ToonLitSetting.kDefaultLightMapWidth - 1)) * 255.0f);
					colors[ x] = new Color32( value, value, value, 255);
				}
				texture.SetPixels32( 0, 0, ToonLitSetting.kDefaultLightMapWidth, ToonLitSetting.kDefaultLightMapHeight, colors, 0);
				texture.Apply();
				
				File.WriteAllBytes( assetPath, texture.EncodeToPNG());
				AssetDatabase.ImportAsset( assetPath);
				
				if( AssetImporter.GetAtPath( assetPath) is TextureImporter importer)
				{
					importer.sRGBTexture = false;
					importer.mipmapEnabled = false;
					importer.alphaSource = TextureImporterAlphaSource.None;
					importer.wrapMode = TextureWrapMode.Clamp;
					importer.filterMode = FilterMode.Bilinear;
					var settings = importer.GetDefaultPlatformTextureSettings();
					settings.format = TextureImporterFormat.R8;
					settings.textureCompression = TextureImporterCompression.Uncompressed;
					importer.SetPlatformTextureSettings( settings);
					importer.SaveAndReimport();
				}
				if( target is ToonLitSetting toonLitSetting)
				{
					toonLitSetting.OnEnable();
				}
			}
		}
		AnimationCurve m_Curve = AnimationCurve.Linear( 0, 0, 1, 1);
	}
}