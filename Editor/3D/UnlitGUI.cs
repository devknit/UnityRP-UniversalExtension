
using System;
using System.Linq;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Knit.Rendering.Core;
using Knit.Rendering.Core.Editor;

namespace Knit.Rendering.Universal.Editor
{
	public class UnlitGUI : Core.Editor.ShaderGUI
	{
		sealed class Option : MaterialPropertyGroup
		{
			public Option() : base( "Option", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_TransparentSurface",
				"_ReceiveShadowsOff",
			};
		}
		sealed class Base : MaterialPropertyGroup
		{
			public Base() : base( "Base", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_BaseMap",
				"_BaseColor",
			};
		}
		sealed class Outline : MaterialPropertyGroup
		{
			public Outline() : base( "Outline", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_OutlineCull",
				"_OutlineColor",
				"_OutlineDirection",
				"_OutlineWidth",
				"_OutlineOffsetZ",
				"_OutlineVolumeMap",
			};
		}
		sealed class Tessellation : MaterialPropertyGroup
		{
			public Tessellation() : base( "Tessellation", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_TessFactor",
				"_TessMinDistance",
				"_TessMaxDistance",
				"_TessPhongStrength",
				"_TessExtrusionAmount",
			};
		}
		protected override Type[] MaterialGroupTypes
		{
			get{ return kStatusTypes; }
		}
		static readonly Type[] kStatusTypes = new Type[]
		{
			typeof( Option),
			typeof( Base),
			typeof( Outline),
			typeof( Tessellation),
		};
		protected override void OnFotterGUI( MaterialEditor materialEditor, List<MaterialProperty> properties)
		{
			switch( ButtonDropdown( "Preset", ref s_PresetOptionIndex, kPresetOptions))
			{
				case 0: materialEditor.targets.Cast<Material>().ToList().ForEach( x => RenderStatus.SetMaterial( RenderStatus.Preset.Opaque3D, x)); break;
				case 1: materialEditor.targets.Cast<Material>().ToList().ForEach( x => RenderStatus.SetMaterial( RenderStatus.Preset.TransparentPreDepth, x)); break;
			}
		}
		static readonly string[] kPresetOptions = new[]
		{
			"Opaque",
			"Transparent",
		};
		static int s_PresetOptionIndex = 0;
	}
}
