
using System;
using UnityEngine;
using UnityEngine.Playables;

namespace Knit.Rendering.Universal
{
	[Serializable]
	sealed class ChromaticAberrationBehaviour : PlayableBehaviour
	{
		[SerializeField, Range( 0f, 1.0f)]
		internal float m_Intensity;
	}
}
