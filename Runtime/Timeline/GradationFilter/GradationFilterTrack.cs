
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using System.ComponentModel;

namespace Knit.Rendering.Universal
{
	[TrackClipType( typeof( GradationFilterClip))]
	[TrackBindingType( typeof( UnityEngine.Rendering.Volume))]
	[TrackColor( 128.0f / 255.0f, 128.0f / 255.0f, 128.0f / 255.0f)]
	[DisplayName( "Knit.Timeline/URP-PostProcessing/Depth Of Field Track")]
	sealed class GradationFilterTrack : TrackAsset
	{
		public override Playable CreateTrackMixer( PlayableGraph graph, GameObject go, int inputCount)
		{
			return ScriptPlayable<GradationFilterMixerBehaviour>.Create( graph, inputCount);
		}
	}
}
