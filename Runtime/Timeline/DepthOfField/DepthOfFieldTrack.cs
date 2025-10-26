
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using System.ComponentModel; 

namespace Knit.Rendering.Universal
{
	[TrackClipType( typeof( DepthOfFieldClip))]
	[TrackBindingType( typeof( UnityEngine.Rendering.Volume))]
	[TrackColor( 128.0f / 255.0f, 128.0f / 255.0f, 128.0f / 255.0f)]
	[DisplayName( "Knit.Timeline/URP-PostProcessing/Depth Of Field Track")]
	sealed class DepthOfFieldTrack : TrackAsset
	{
		public override Playable CreateTrackMixer( PlayableGraph graph, GameObject go, int inputCount)
		{
			var playable = ScriptPlayable<DepthOfFieldMixerBehaviour>.Create( graph, inputCount);
			playable.GetBehaviour().Initialize( m_ModeVolume);
			return playable;
		}
		
		[SerializeField]
		ModeVolume m_ModeVolume = ModeVolume.Gaussian;
	}
}