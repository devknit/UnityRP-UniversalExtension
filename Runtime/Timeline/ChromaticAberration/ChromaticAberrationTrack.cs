
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using System.ComponentModel; 

namespace Knit.Rendering.Universal
{
	[TrackClipType( typeof( ChromaticAberrationClip))]
	[TrackBindingType( typeof( UnityEngine.Rendering.Volume))]
	[TrackColor( 128.0f / 255.0f, 128.0f / 255.0f, 128.0f / 255.0f)]
	[DisplayName( "Knit.Timeline/URP-PostProcessing/Chromatic Aberration Track")]
	sealed class ChromaticAberrationTrack : TrackAsset
	{
		public override Playable CreateTrackMixer( PlayableGraph graph, GameObject go, int inputCount)
		{
			return ScriptPlayable<ChromaticAberrationMixerBehaviour>.Create( graph, inputCount);
		}
	}
}
