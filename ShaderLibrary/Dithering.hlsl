#ifndef __KNIT_DITHERING_HLSL__
#define __KNIT_DITHERING_HLSL__

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#if defined(LOD_FADE_CROSSFADE)
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

static const float kPattern[ 16] =
{
	1.0 / 17.0, 9.0 / 17.0, 3.0 / 17.0, 11.0 / 17.0,
	13.0 / 17.0, 5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0,
	4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 10.0 / 17.0,
	16.0 / 17.0, 8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0
};
static const int kPatternRowSize = 4;

half AlphaDiscard( float4 positionCS, half alpha, half cutoff, half dither)
{
#if defined(LOD_FADE_CROSSFADE)
	LODFadeCrossFade( positionCS);
#endif
	float2 screenUV = GetNormalizedScreenSpaceUV( positionCS.xy) * _ScreenParams.xy;
	uint index = (uint( screenUV.x) % 4) * 4 + uint( screenUV.y) % 4;
	clip( alpha - lerp( 0, kPattern[ index], dither));
#if defined(_ALPHATEST_ON)
	if( IsAlphaDiscardEnabled())
		alpha = AlphaClip( alpha, cutoff);
#endif
	return alpha;
}
#endif
