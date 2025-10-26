
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using System.ComponentModel;

namespace Knit.Rendering.Universal
{
	[TrackClipType( typeof( SpeedLineClip))]
	[TrackBindingType( typeof( UnityEngine.Rendering.Volume))]
	[TrackColor( 128.0f / 255.0f, 128.0f / 255.0f, 128.0f / 255.0f)]
	[DisplayName( "Knit.Timeline/URP-PostProcessing/Speed Line Track")]
	sealed class SpeedLineTrack : TrackAsset
	{
		public override Playable CreateTrackMixer( PlayableGraph graph, GameObject go, int inputCount)
		{
			var playable = ScriptPlayable<SpeedLineMixerBehaviour>.Create( graph, inputCount);
			playable.GetBehaviour().Initialize( m_Pattern);
			return playable;
		}
		[SerializeField]
		Volume.SpeedLine.Pattern m_Pattern;
	}
}
