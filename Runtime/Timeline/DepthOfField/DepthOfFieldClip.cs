
using System;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class DepthOfFieldClip : PlayableAsset, ITimelineClipAsset
	{
		public ClipCaps clipCaps
		{
			get { return ClipCaps.Extrapolation | ClipCaps.Blending; }
		}
		public override Playable CreatePlayable( PlayableGraph graph, GameObject owner)
		{
			var playable = ScriptPlayable<DepthOfFieldBehaviour>.Create( graph, m_Source);
			var resolver = graph.GetResolver();
			playable.GetBehaviour().Initialize( m_FocusTarget.Resolve( resolver), m_FocusCamera.Resolve( resolver));
			return playable;
		}
		[SerializeField]
		ExposedReference<Transform> m_FocusTarget;
		[SerializeField]
		ExposedReference<Camera> m_FocusCamera;
		[SerializeField]
		DepthOfFieldBehaviour m_Source = new();
	}
}
