
using System;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class GradationFilterClip : PlayableAsset, ITimelineClipAsset
	{
		public ClipCaps clipCaps
		{
			get { return ClipCaps.Extrapolation | ClipCaps.Blending; }
		}
		public override Playable CreatePlayable( PlayableGraph graph, GameObject owner)
		{
			return ScriptPlayable<GradationFilterBehaviour>.Create( graph, m_Source);
		}
		[SerializeField]
		GradationFilterBehaviour m_Source = new();
	}
}
