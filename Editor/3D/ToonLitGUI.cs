
using System;
using System.Linq;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Knit.Rendering.Core;
using Knit.Rendering.Core.Editor;

namespace Knit.Rendering.Universal.Editor
{
	public class ToonLitGUI : Core.Editor.ShaderGUI
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
				"_ShadeColor",
				"_ColorMaskMap",
			};
		}
		sealed class Normal : MaterialPropertyGroup
		{
			public Normal() : base( "Normal", kPropertyNames, 0)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_NormalMap",
				"_BumpMap",
				"_BumpScale",
			};
		}
		sealed class Diffuse : MaterialPropertyGroup
		{
			public Diffuse() : base( "Diffuse", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_DiffuseBorder",
				"_DiffuseSoftness",
			};
		}
		sealed class Specular : MaterialPropertyGroup
		{
			public Specular() : base( "Specular", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_SpecularBorder",
				"_SpecularSoftness",
				"_SpecularIlluminance",
				"_SpecularVolumeMap",
			};
		}
		sealed class Sphere : MaterialPropertyGroup
		{
			public Sphere() : base( "Sphere", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_SphereMap",
			};
		}
		sealed class Rimlight : MaterialPropertyGroup
		{
			public Rimlight() : base( "Rimlight", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_RimlightColor",
				"_RimlightBorder",
				"_RimlightSoftness",
				"_RimlightIlluminance",
				"_RimlightOverrideAlpha",
			};
		}
		sealed class Emission : MaterialPropertyGroup
		{
			public Emission() : base( "Emission", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_EmissionMap",
				"_EmissionColor",
			};
		}
		sealed class Wind : MaterialPropertyGroup
		{
			public Wind() : base( "Wind", kPropertyNames)
			{
			}
			static readonly string[] kPropertyNames = new string[]
			{
				"_WindMode",
				"_WindStrength"
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
			typeof( Normal),
			typeof( Diffuse),
			typeof( Specular),
			typeof( Sphere),
			typeof( Rimlight),
			typeof( Emission),
			typeof( Wind),
			typeof( Outline),
			typeof( Tessellation),
		};
		protected override void OnFotterGUI( MaterialEditor materialEditor, List<MaterialProperty> properties)
		{
			switch( ButtonDropdown( "Preset", ref s_PresetOptionIndex, kPresetOptions))
			{
				case 0: materialEditor.targets.Cast<Material>().ToList().ForEach( x => RenderStatus.SetMaterial( RenderStatus.Preset.Opaque3D, x)); break;
				case 1: materialEditor.targets.Cast<Material>().ToList().ForEach( x => RenderStatus.SetMaterial( RenderStatus.Preset.Transparent3D, x)); break;
				case 2: materialEditor.targets.Cast<Material>().ToList().ForEach( x => RenderStatus.SetMaterial( RenderStatus.Preset.TransparentPreDepth, x)); break;
			}
		}
		static readonly string[] kPresetOptions = new[]
		{
			"Opaque",
			"Transparent",
			"Transparent Pre-Depth",
		};
		static int s_PresetOptionIndex = 0;
	}
}
