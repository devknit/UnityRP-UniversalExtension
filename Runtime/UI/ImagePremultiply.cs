
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Pool;
using UnityEngine.EventSystems;

namespace Knit.Rendering.Universal
{
	public sealed class ImagePremultiply : UIBehaviour, IMeshModifier
	{
		public void ModifyMesh( Mesh mesh)
		{
			throw new System.NotImplementedException();
		}
		public void ModifyMesh( VertexHelper verts)
		{
			var vertices = ListPool<UIVertex>.Get();
			verts.GetUIVertexStream( vertices);
			
			for( int i0 = vertices.Count - 1; i0 >= 0; --i0)
			{
				UIVertex vertex = vertices[ i0];
				vertex.uv0 = new Vector4( 
					vertex.uv0.x, vertex.uv0.y, 
					1.0f - m_PremultiplyColor, 
					1.0f - m_PremultiplyAlpha);
				vertices[ i0] = vertex;
			}
			verts.Clear();
			verts.AddUIVertexTriangleStream( vertices);
			ListPool<UIVertex>.Release( vertices);
		}
		void SetVerticesDirty()
		{
			if( m_CacheGraphic == null)
			{
				m_CacheGraphic = GetComponent<Graphic>();
			}
			if( m_CacheGraphic != null)
			{
				m_CacheGraphic.SetVerticesDirty();
			}
		}
	#if UNITY_EDITOR
		protected override void OnValidate()
		{
			base.OnValidate();
			SetVerticesDirty();
		}
	#endif
		public float PremultiplyColor
		{
			get{ return m_PremultiplyColor; }
			set{ m_PremultiplyColor = Mathf.Clamp( value, 0.0f, 1.0f); SetVerticesDirty(); }
		}
		public float PremultiplyAlpha
		{
			get{ return m_PremultiplyAlpha; }
			set{ m_PremultiplyAlpha = Mathf.Clamp( value, 0.0f, 1.0f); SetVerticesDirty(); }
		}
		[SerializeField, Range( 0, 1)]
		float m_PremultiplyColor = 1;
		[SerializeField, Range( 0, 1)]
		float m_PremultiplyAlpha = 1;
		[System.NonSerialized]
		Graphic m_CacheGraphic;
	}
}