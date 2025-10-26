
using UnityEngine;
using UnityEditor;

namespace Knit.Rendering.Universal
{
	[CustomEditor( typeof( ImagePremultiply), true), CanEditMultipleObjects]
	sealed class ImagePremultiplyEditor : UnityEditor.Editor
	{
		void OnEnable()
		{
			m_PremultiplyColorProperty = serializedObject.FindProperty( "m_PremultiplyColor");
			m_PremultiplyAlphaProperty = serializedObject.FindProperty( "m_PremultiplyAlpha");
		}
		public override void OnInspectorGUI()
		{
			serializedObject.UpdateIfRequiredOrScript();
			EditorGUILayout.PropertyField( m_PremultiplyColorProperty);
			EditorGUILayout.PropertyField( m_PremultiplyAlphaProperty);
			serializedObject.ApplyModifiedProperties();
			
			Rect rect = EditorGUILayout.GetControlRect();
			float addWidth = GUI.skin.button.CalcSize( kAddContent).x;
			float alphaWidth = GUI.skin.button.CalcSize( kAlphaContent).x;
			var addRect = new Rect( rect.xMax - addWidth, rect.y, addWidth, rect.height);
			var alphaRect = new Rect( addRect.xMin - (alphaWidth + 4), rect.y, alphaWidth, rect.height);
			
			EditorGUI.LabelField( rect, "Blend Mode");
			
			if( GUI.Button( addRect, kAddContent) != false)
			{
				m_PremultiplyColorProperty.floatValue = 1.0f;
				m_PremultiplyAlphaProperty.floatValue = 0.0f;
				serializedObject.ApplyModifiedProperties();
			}
			if( GUI.Button( alphaRect, kAlphaContent) != false)
			{
				m_PremultiplyColorProperty.floatValue = 1.0f;
				m_PremultiplyAlphaProperty.floatValue = 1.0f;
				serializedObject.ApplyModifiedProperties();
			}
		}
		static readonly GUIContent kAlphaContent = new( "Alpha");
		static readonly GUIContent kAddContent = new( "Add");
		SerializedProperty m_PremultiplyColorProperty;
		SerializedProperty m_PremultiplyAlphaProperty;
	}
}