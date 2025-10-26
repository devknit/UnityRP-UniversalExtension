
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using System.ComponentModel; 

namespace Knit.Rendering.Universal
{
	[TrackClipType( typeof( ColorAdjustmentsClip))]
	[TrackBindingType( typeof( UnityEngine.Rendering.Volume))]
	[TrackColor( 128.0f / 255.0f, 128.0f / 255.0f, 128.0f / 255.0f)]
	[DisplayName( "Knit.Timeline/URP-PostProcessing/Color Adjustments Track")]
	sealed class ColorAdjustmentsTrack : TrackAsset
	{
		public override Playable CreateTrackMixer( PlayableGraph graph, GameObject go, int inputCount)
		{
			return ScriptPlayable<ColorAdjustmentsMixerBehaviour>.Create( graph, inputCount);
		}
	}
}
