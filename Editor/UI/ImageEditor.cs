
using UnityEngine;
using UnityEditor;
using System.Linq;

namespace Knit.Rendering.Universal
{
	[CustomEditor( typeof( UnityEngine.UI.Image), true), CanEditMultipleObjects]
	sealed class ImgeEditor : UnityEditor.UI.ImageEditor
	{
		public override void OnInspectorGUI()
		{
			base.OnInspectorGUI();
			
			using( new EditorGUILayout.HorizontalScope())
			{
				GUILayout.FlexibleSpace();
				
				if( GUILayout.Button( "Add Premultiply Component") != false)
				{
					foreach( var target in targets.Cast<UnityEngine.UI.Image>())
					{
						if( target.GetComponent<ImagePremultiply>() == null)
						{
							target.gameObject.AddComponent<ImagePremultiply>();
						}
					}
				}
			}
		}
	}
}