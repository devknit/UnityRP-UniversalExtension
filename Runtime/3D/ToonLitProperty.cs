
namespace Knit.Rendering.Universal
{
	public sealed class ToonLitProperty : Core.ShaderProperty
	{
		public static readonly int kBaseMap = UnityEngine.Shader.PropertyToID( "_BaseMap");
		public static readonly int kBaseColor = UnityEngine.Shader.PropertyToID( "_BaseColor");
		public static readonly int kColorMaskMap = UnityEngine.Shader.PropertyToID( "_ColorMaskMap");
		
		public static readonly int kBumpMap = UnityEngine.Shader.PropertyToID( "_BumpMap");
		public static readonly int kBumpScale = UnityEngine.Shader.PropertyToID( "_BumpScale");
		
		public static readonly int kDiffuseBorder = UnityEngine.Shader.PropertyToID( "_DiffuseBorder");
		public static readonly int kDiffuseSoftness = UnityEngine.Shader.PropertyToID( "_DiffuseSoftness");
		
		public static readonly int kSpecularBorder = UnityEngine.Shader.PropertyToID( "_SpecularBorder");
		public static readonly int kSpecularSoftness = UnityEngine.Shader.PropertyToID( "_SpecularSoftness");
		public static readonly int kSpecularIlluminance = UnityEngine.Shader.PropertyToID( "_SpecularIlluminance");
		
		public static readonly int kSphereMap = UnityEngine.Shader.PropertyToID( "_SphereMap");
		
		public static readonly int kRimlightColor = UnityEngine.Shader.PropertyToID( "_RimlightColor");
		public static readonly int kRimlightBorder = UnityEngine.Shader.PropertyToID( "_RimlightBorder");
		public static readonly int kRimlightSoftness = UnityEngine.Shader.PropertyToID( "_RimlightSoftness");
		public static readonly int kRimlightIlluminance = UnityEngine.Shader.PropertyToID( "_RimlightIlluminance");
		public static readonly int kRimlightOverrideAlpha = UnityEngine.Shader.PropertyToID( "_RimlightOverrideAlpha");
		
		public static readonly int kEmissionMap = UnityEngine.Shader.PropertyToID( "_EmissionMap");
		public static readonly int kEmissionColor = UnityEngine.Shader.PropertyToID( "_EmissionColor");
	}
}
