
using System;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class BloomClip : PlayableAsset, ITimelineClipAsset
	{
		public ClipCaps clipCaps
		{
			get { return ClipCaps.Extrapolation | ClipCaps.Blending; }
		}
		public override Playable CreatePlayable( PlayableGraph graph, GameObject owner)
		{
			return ScriptPlayable<BloomBehaviour>.Create( graph, m_Source);
		}
		[SerializeField]
		BloomBehaviour m_Source = new();
	}
}
