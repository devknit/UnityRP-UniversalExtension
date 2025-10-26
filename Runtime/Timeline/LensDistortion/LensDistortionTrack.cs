
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using System.ComponentModel;

namespace Knit.Rendering.Universal
{
	[TrackClipType( typeof( LensDistortionClip))]
	[TrackBindingType( typeof( UnityEngine.Rendering.Volume))]
	[TrackColor( 128.0f / 255.0f, 128.0f / 255.0f, 128.0f / 255.0f)]
	[DisplayName( "Knit.Timeline/URP-PostProcessing/Lens Distortion Track")]
	sealed class LensDistortionTrack : TrackAsset
	{
		public override Playable CreateTrackMixer( PlayableGraph graph, GameObject go, int inputCount)
		{
			return ScriptPlayable<LensDistortionMixerBehaviour>.Create( graph, inputCount);
		}
	}
}
