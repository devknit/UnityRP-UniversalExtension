
using System;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class SpeedLineClip : PlayableAsset, ITimelineClipAsset
	{
		public ClipCaps clipCaps
		{
			get { return ClipCaps.Extrapolation | ClipCaps.Blending; }
		}
		public override Playable CreatePlayable( PlayableGraph graph, GameObject owner)
		{
			return ScriptPlayable<SpeedLineBehaviour>.Create( graph, m_Source);
		}
		[SerializeField]
		SpeedLineBehaviour m_Source = new();
	}
}
