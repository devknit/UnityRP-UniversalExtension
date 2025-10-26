
using System;
using UnityEngine;
using UnityEngine.Rendering;
using Knit.Rendering.Core;

namespace Knit.Rendering.Universal.Volume
{
	[Serializable, VolumeComponentMenu( "Post-processing extensions/Mosaic")]
	internal sealed class Mosaic : VolumeComponent, IPostProcessComponent
	{
		public bool IsActive()
		{
			return m_DownSample.value.y > 0;
		}
		[SerializeField]
		internal BoolParameter m_DynamicDownSample = new( false);
		[SerializeField]
		internal IntRangeParameter m_DownSample = new( new Vector2Int( 3, 4), 0, 12);
		[SerializeField, Range(0, 255)]
		internal ClampedIntParameter m_StencilReference = new( 0, 0, 255);
		[SerializeField, Range(0, 255)]
		internal ClampedIntParameter m_StencilReadMask = new( 255, 0, 255);
		[SerializeField]
		internal EnumParameter<CompareFunction> m_StencilCompare = new( CompareFunction.Always);
		[SerializeField]
		internal EnumParameter<FilterMode> m_StencilFilterMode = new( FilterMode.Point);
	}
}