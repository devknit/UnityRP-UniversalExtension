#ifndef __KNIT_BLEND_HLSL__
#define __KNIT_BLEND_HLSL__

inline float remap( float value, float srcMin, float srcMax, float dstMin, float dstMax)
{
	float volume = srcMax - srcMin;
	return dstMin + ((volume != 0.0)? (value - srcMin) * (dstMax - dstMin) / volume : 0.0);
}
inline float remap( float value, float4 param)
{
	return remap( value, param.x, param.y, param.z, param.w);
}

float3 RGB2HSV( float3 rgb)
{
	float4 K = float4( 0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	float4 P = lerp( float4( rgb.bg, K.wz), float4( rgb.gb, K.xy), step( rgb.b, rgb.g));
	float4 Q = lerp( float4( P.xyw, rgb.r), float4( rgb.r, P.yzx), step( P.x, rgb.r));
	float  D = Q.x - min( Q.w, Q.y);
	float  E = 1e-4;
	return float3( abs( Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);
}
float3 HSV2RGB( float3 hsv)
{
	float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	float3 P = abs( frac( hsv.xxx + K.xyz) * 6.0 - K.www);
	return hsv.z * lerp( K.xxx, saturate( P - K.xxx), hsv.y);
}
/* グレースケール:平均 */
inline half GlayScaleAverage( half3 color)
{
	return (color.r + color.g + color.b) / 3.0;
}

/* グレースケール:ITU-R Rec BT.601
 * https://www.itu.int/rec/R-REC-BT.601/en
 */
inline half GlayScaleBT601( half3 color)
{
	return color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
}

/* グレースケール:ITU-R Rec BT.709
 * https://www.itu.int/rec/R-REC-BT.709/en
 */
inline half GlayScaleBT709( half3 color)
{
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.722;
}

/* グレースケール:標準テレビジョン放送規格
 * https://www.tele.soumu.go.jp/horei/reiki_honbun/a72ab21051.html
 */
inline half GlayScaleTV( half3 color)
{
	return color.r * 0.30 + color.g * 0.59 + color.b * 0.11;
}

/* グレースケール:YCgCo の Y
 * https://www.tele.soumu.go.jp/horei/reiki_honbun/a72ab21051.html
 */
inline half GlayScaleYofYCgCo( half3 color)
{
	return color.r / 4.0 + color.g / 2.0 + color.b  / 4.0;
	// return (((color.r + color.b) >> 1) + color.g) >> 1;
}

//http://optie.hatenablog.com/entry/2018/03/15/212107

/* 乗算 */
inline half3 BelndMultiply( half3 background, half3 foreground)
{
	return background * foreground;
}

/* 比較(暗):各成分の低い方を出力する */
inline half3 BelndDarken( half3 background, half3 foreground)
{
	return min( background, foreground);
}

/* 焼き込みカラー:(反転した背景 / 前景) を反転する */
inline half3 BelndColorBurn( half3 background, half3 foreground)
{
	return 1.0 - (1.0 - background) / (foreground + 1e-12);
}

/* 焼き込みリニア:(反転背景 + 反転前景) を反転する */
inline half3 BelndLinearBurn( half3 background, half3 foreground)
{
//	return saturate( 1.0 - ((1.0 - background) + (1.0 - foreground)));
	return saturate( background + foreground - 1.0);
}

/* 比較(明):各成分の高い方を出力する */
inline half3 BelndLighten( half3 background, half3 foreground)
{
	return max( background, foreground);
}

/* スクリーン:反転して乗算し、また反転して戻す */
inline half3 BelndScreen( half3 background, half3 foreground)
{
	return 1.0 - (1.0 - background) * (1.0 - foreground);
}

/* 覆い焼きカラー:背景 / 反転した前景 */
inline half3 BelndColorDodge( half3 background, half3 foreground)
{
	return background / (1.0 - clamp( foreground, 1e-12, 0.999999));
}

/* 覆い焼きリニア:加算する */
inline half3 BelndLinearDodge( half3 background, half3 foreground)
{
	return saturate( foreground + background);
}

/* オーバーレイ:背景の暗部では乗算、背景の明部ではスクリーン */
inline half3 BelndOverlay( half3 background, half3 foreground)
{
	float3 result1 = 2.0 * background * foreground;
	float3 result2 = 1.0 - 2.0 * (1.0 - background) * (1.0 - foreground);
    float3 zeroOrOne = step( background, 0.5);
    return result1 * zeroOrOne + (1 - zeroOrOne) * result2;
}

/* ハードライト:前景の暗部では乗算、前景の明部ではスクリーン */
inline half3 BelndHardLight( half3 background, half3 foreground)
{
	float3 result1 = 2.0 * background * foreground;
	float3 result2 = 1.0 - 2.0 * (1.0 - background) * (1.0 - foreground);
	float3 zeroOrOne = step( foreground, 0.5);
	return result1 * zeroOrOne + (1 - zeroOrOne) * result2;
}

/* ビビッドライト:前景の暗部では焼き込みカラー、前景の明部では覆い焼きカラー */
inline half3 BelndVividLight( half3 background, half3 foreground)
{
    float3 result1 = BelndColorBurn( background, 2.0 * foreground);
    float3 result2 = BelndColorDodge( background, 2.0 * (foreground - 0.5));
    float3 zeroOrOne = step( foreground, 0.5);
    return result1 * zeroOrOne + (1 - zeroOrOne) * result2;
}

/* リニアライト:前景の暗部では焼き込みリニア、前景の明部では覆い焼きリニア */
inline half3 BelndLinearLight( half3 background, half3 foreground)
{
	float3 result1 = BelndLinearBurn( background, 2.0 * foreground);
	float3 result2 = BelndLinearDodge( background, 2.0 * (foreground - 0.5));
	float3 zeroOrOne = step( foreground, 0.5);
	return result1 * zeroOrOne + (1 - zeroOrOne) * result2;
}

/* ピンライト:前景の暗部では比較(暗)、前景の明部では比較(明) */
inline half3 BelndPinLight( half3 background, half3 foreground)
{
	float3 result1 = BelndDarken( background, 2.0 * foreground);
	float3 result2 = BelndLighten( background, 2.0 * (foreground - 0.5));
	float3 zeroOrOne = step( foreground, 0.5);
	return result1 * zeroOrOne + (1 - zeroOrOne) * result2;
}

/* ハードミックス:ビビッドライトの演算結果を各成分毎に二値化します */
inline half3 BelndHardMix( half3 background, half3 foreground)
{
//	return step( 0.5, BelndVividLight( background, foreground));
	return step( 1 - background, foreground);
}

/* 差:前景と背景の値の差分を出力する */
inline half3 BelndDifference( half3 background, half3 foreground)
{
	return abs( background - foreground);
}

/* 除外:前景と背景の相加平均と相乗平均の差をとって2倍する */
inline half3 BelndExclusion( half3 background, half3 foreground)
{
	return background + foreground - 2.0 * background * foreground;
}

/* 減算:背景から前景を引きます */
inline half3 BelndSubstract( half3 background, half3 foreground)
{
	return saturate( background - foreground);
}

/* 除算:前景で背景を割ります */
inline half3 BelndDivision( half3 background, half3 foreground)
{
	return saturate( background / (foreground + 1e-12));
}

/* 色相:背景の輝度と彩度を維持したまま、前景の色相だけを移します */
inline half3 BelndHue( half3 background, half3 foreground)
{
	float3 hsvBackground = RGB2HSV( background);
	float3 hsvForeground = RGB2HSV( foreground);
	return HSV2RGB( float3( hsvForeground.x, hsvBackground.yz));
}
/* 彩度:背景の輝度と色相を維持したまま、前景の彩度だけを移します */
inline half3 BelndSaturation( half3 background, half3 foreground)
{
	float3 hsvBackground = RGB2HSV( background);
	float3 hsvForeground = RGB2HSV( foreground);
	return HSV2RGB( float3( hsvBackground.x, hsvForeground.y, hsvBackground.z));
}
/* 彩度:背景の色相と彩度を維持したまま、前景の輝度だけを移します */
inline half3 BelndLuminosity( half3 background, half3 foreground)
{
	float3 hsvBackground = RGB2HSV( background);
	float3 hsvForeground = RGB2HSV( foreground);
	return HSV2RGB( float3( hsvBackground.xy, hsvForeground.z));
}
/* 彩度:背景の輝度を維持したまま、前景の色相と彩度を移します */
inline half3 BelndColor( half3 background, half3 foreground)
{
	float3 hsvBackground = RGB2HSV( background);
	float3 hsvForeground = RGB2HSV( foreground);
	return HSV2RGB( float3( hsvForeground.xy, hsvBackground.z));
}

/*
Shader
{
	Properties
	{
		[KeywordEnum(None, Override, Multiply, Darken, ColorBurn, LinearBurn, Lighten, Screen, ColorDodge, LinearDodge, Overlay, HardLight, VividLight, LinearLight, PinLight, HardMix, Difference, Exclusion, Substract, Division)]
		_CBLENDOP1( "Color blend operation", float) = 2
		[KeywordEnum(Value, AlphaBlendOp, OneMinusAlphaBlendOp, BaseAlpha, OneMinusBaseAlpha, BlendAlpha, OneMinusBlendAlpha, BaseColorValue, OneMinusBaseColorValue, BlendColorValue, OneMinusBlendColorValue)]
		_CBLENDSRC1( "Color blend RGB interpolation source", float) = 0
		_ColorBlendT1( "Color blend interpolation value", float) = 1.0
		[KeywordEnum(None, Override, Multiply, Add, Substract, ReverseSubstract, Maximum)]
		_ABLENDOP1( "Alpha blend operation", float) = 2
		_AlphaBlendT1( "Alpha blend interpolation value", float) = 1.0
	}
	SubShader
	{
		Pass
		{
			#pragma shader_feature_local _CBLENDOP1_NONE _CBLENDOP1_OVERRIDE _CBLENDOP1_MULTIPLY _CBLENDOP1_DARKEN _CBLENDOP1_COLORBURN _CBLENDOP1_LINEARBURN _CBLENDOP1_LIGHTEN _CBLENDOP1_SCREEN _CBLENDOP1_COLORDODGE _CBLENDOP1_LINEARDODGE _CBLENDOP1_OVERLAY _CBLENDOP1_HARDLIGHT _CBLENDOP1_VIVIDLIGHT _CBLENDOP1_LINEARLIGHT _CBLENDOP1_PINLIGHT _CBLENDOP1_HARDMIX _CBLENDOP1_DIFFERENCE _CBLENDOP1_EXCLUSION _CBLENDOP1_SUBSTRACT _CBLENDOP1_DIVISION
			#pragma shader_feature_local _CBLENDSRC1_VALUE _CBLENDSRC1_ABLENDOP _CBLENDSRC1_ONEMINUSALPHABLENDOP _CBLENDSRC1_BASEALPHA _CBLENDSRC1_ONEMINUSBASEALPHA _CBLENDSRC1_BLENDALPHA _CBLENDSRC1_ONEMINUSBLENDALPHA _CBLENDSRC1_BASECOLORVALUE _CBLENDSRC1_ONEMINUSBASECOLORVALUE _CBLENDSRC1_BLENDCOLORVALUE _CBLENDSRC1_ONEMINUSBLENDCOLORVALUE
			#pragma shader_feature_local _ABLENDOP1_NONE _ABLENDOP1_OVERRIDE _ABLENDOP1_MULTIPLY _ABLENDOP1_ADD _ABLENDOP1_SUBSTRACT _ABLENDOP1_REVERSESUBSTRACT _ABLENDOP1_MAXIMUM
		}
	}
}
*/
inline half AlphaBlend1( half4 background, half4 foreground, float tAlpha)
{
	half alpha = background.a;
#if   _ABLENDOP1_OVERRIDE
	alpha = foreground.a;
#elif _ABLENDOP1_MULTIPLY
	alpha = background.a * foreground.a;
#elif _ABLENDOP1_ADD
	alpha = background.a + foreground.a;
#elif _ABLENDOP1_SUBSTRACT
	alpha = background.a - foreground.a;
#elif _ABLENDOP1_REVERSESUBSTRACT
	alpha = foreground.a - background.a;
#elif _ABLENDOP1_MAXIMUM
	alpha = max( background.a, foreground.a);
#endif
	return saturate( lerp( background.a, alpha, tAlpha));
}
inline half4 ColorBlend1( half4 background, half4 foreground, float tRGB, float tAlpha)
{
	half alpha = AlphaBlend1( background, foreground, tAlpha);
	
#if   _CBLENDSRC1_VALUE
#elif _CBLENDSRC1_ABLENDOP
	tRGB *= alpha;
#elif _CBLENDSRC1_ONEMINUSALPHABLENDOP
	tRGB *= 1.0 - alpha;
#elif _CBLENDSRC1_BASEALPHA
	tRGB *= background.a;
#elif _CBLENDSRC1_ONEMINUSBASEALPHA
	tRGB *= 1.0 - background.a;
#elif _CBLENDSRC1_BLENDALPHA
	tRGB *= foreground.a;
#elif _CBLENDSRC1_ONEMINUSBLENDALPHA
	tRGB *= 1.0 - foreground.a;
#elif _CBLENDSRC1_BASECOLORVALUE
	tRGB *= max( background.r, max( background.g, background.b));
#elif _CBLENDSRC1_ONEMINUSBASECOLORVALUE
	tRGB *= 1.0 - max( background.r, max( background.g, background.b));
#elif _CBLENDSRC1_BLENDCOLORVALUE
	tRGB *= max( foreground.r, max( foreground.g, foreground.b));
#elif _CBLENDSRC1_ONEMINUSBLENDCOLORVALUE
	tRGB *= 1.0 - max( foreground.r, max( foreground.g, foreground.b));
#endif

	half3 color = background.rgb;
#if   _CBLENDOP1_OVERRIDE
	color = foreground.rgb;
#elif _CBLENDOP1_MULTIPLY
	color = BelndMultiply( background.rgb, foreground.rgb);
#elif _CBLENDOP1_DARKEN
	color = BelndDarken( background.rgb, foreground.rgb);
#elif _CBLENDOP1_COLORBURN
	color = BelndColorBurn( background.rgb, foreground.rgb);
#elif _CBLENDOP1_LINEARBURN
	color = BelndLinearBurn( background.rgb, foreground.rgb);
#elif _CBLENDOP1_LIGHTEN
	color = BelndLighten( background.rgb, foreground.rgb);
#elif _CBLENDOP1_SCREEN
	color = BelndScreen( background.rgb, foreground.rgb);
#elif _CBLENDOP1_COLORDODGE
	color = BelndColorDodge( background.rgb, foreground.rgb);
#elif _CBLENDOP1_LINEARDODGE
	color = BelndLinearDodge( background.rgb, foreground.rgb);
#elif _CBLENDOP1_OVERLAY
	color = BelndOverlay( background.rgb, foreground.rgb);
#elif _CBLENDOP1_HARDLIGHT
	color = BelndHardLight( background.rgb, foreground.rgb);
#elif _CBLENDOP1_VIVIDLIGHT
	color = BelndVividLight( background.rgb, foreground.rgb);
#elif _CBLENDOP1_LINEARLIGHT
	color = BelndLinearLight( background.rgb, foreground.rgb);
#elif _CBLENDOP1_PINLIGHT
	color = BelndPinLight( background.rgb, foreground.rgb);
#elif _CBLENDOP1_HARDMIX
	color = BelndHardMix( background.rgb, foreground.rgb);
#elif _CBLENDOP1_DIFFERENCE
	color = BelndDifference( background.rgb, foreground.rgb);
#elif _CBLENDOP1_EXCLUSION
	color = BelndExclusion( background.rgb, foreground.rgb);
#elif _CBLENDOP1_SUBSTRACT
	color = BelndSubstract( background.rgb, foreground.rgb);
#elif _CBLENDOP1_DIVISION
	color = BelndDivision( background.rgb, foreground.rgb);
#endif
	return half4( clamp( lerp( background.rgb, color, tRGB), 0.0, 4.0), alpha);
}
/*
Shader
{
	Properties
	{
		[KeywordEnum(None, Override, Multiply, Darken, ColorBurn, LinearBurn, Lighten, Screen, ColorDodge, LinearDodge, Overlay, HardLight, VividLight, LinearLight, PinLight, HardMix, Difference, Exclusion, Substract, Division)]
		_CBLENDOP2( "Color blend operation", float) = 2
		[KeywordEnum(Value, AlphaBlendOp, OneMinusAlphaBlendOp, BaseAlpha, OneMinusBaseAlpha, BlendAlpha, OneMinusBlendAlpha, BaseColorValue, OneMinusBaseColorValue, BlendColorValue, OneMinusBlendColorValue)]
		_CBLENDSRC2( "Color blend RGB interpolation source", float) = 0
		_ColorBlendT2( "Color blend interpolation value", float) = 1.0
		[KeywordEnum(None, Override, Multiply, Add, Substract, ReverseSubstract, Maximum)]
		_ABLENDOP2( "Alpha blend operation", float) = 2
		_AlphaBlendT2( "Alpha blend interpolation value", float) = 1.0
	}
	SubShader
	{
		Pass
		{
			#pragma shader_feature_local _CBLENDOP2_NONE _CBLENDOP2_OVERRIDE _CBLENDOP2_MULTIPLY _CBLENDOP2_DARKEN _CBLENDOP2_COLORBURN _CBLENDOP2_LINEARBURN _CBLENDOP2_LIGHTEN _CBLENDOP2_SCREEN _CBLENDOP2_COLORDODGE _CBLENDOP2_LINEARDODGE _CBLENDOP2_OVERLAY _CBLENDOP2_HARDLIGHT _CBLENDOP2_VIVIDLIGHT _CBLENDOP2_LINEARLIGHT _CBLENDOP2_PINLIGHT _CBLENDOP2_HARDMIX _CBLENDOP2_DIFFERENCE _CBLENDOP2_EXCLUSION _CBLENDOP2_SUBSTRACT _CBLENDOP2_DIVISION
			#pragma shader_feature_local _CBLENDSRC2_VALUE _CBLENDSRC2_ABLENDOP _CBLENDSRC2_ONEMINUSALPHABLENDOP _CBLENDSRC2_BASEALPHA _CBLENDSRC2_ONEMINUSBASEALPHA _CBLENDSRC2_BLENDALPHA _CBLENDSRC2_ONEMINUSBLENDALPHA _CBLENDSRC2_BASECOLORVALUE _CBLENDSRC2_ONEMINUSBASECOLORVALUE _CBLENDSRC2_BLENDCOLORVALUE _CBLENDSRC2_ONEMINUSBLENDCOLORVALUE
			#pragma shader_feature_local _ABLENDOP2_NONE _ABLENDOP2_OVERRIDE _ABLENDOP2_MULTIPLY _ABLENDOP2_ADD _ABLENDOP2_SUBSTRACT _ABLENDOP2_REVERSESUBSTRACT _ABLENDOP2_MAXIMUM
		}
	}
}
*/
inline half AlphaBlend2( half4 background, half4 foreground, float tAlpha)
{
	half alpha = background.a;
#if   _ABLENDOP2_OVERRIDE
	alpha = foreground.a;
#elif _ABLENDOP2_MULTIPLY
	alpha = background.a * foreground.a;
#elif _ABLENDOP2_ADD
	alpha = background.a + foreground.a;
#elif _ABLENDOP2_SUBSTRACT
	alpha = background.a - foreground.a;
#elif _ABLENDOP2_REVERSESUBSTRACT
	alpha = foreground.a - background.a;
#elif _ABLENDOP2_MAXIMUM
	alpha = max( background.a, foreground.a);
#endif
	return saturate( lerp( background.a, alpha, tAlpha));
}
inline half4 ColorBlend2( half4 background, half4 foreground, float tRGB, float tAlpha)
{
	half alpha = AlphaBlend2( background, foreground, tAlpha);
	
#if   _CBLENDSRC2_VALUE
#elif _CBLENDSRC2_ABLENDOP
	tRGB *= alpha;
#elif _CBLENDSRC2_ONEMINUSALPHABLENDOP
	tRGB *= 1.0 - alpha;
#elif _CBLENDSRC2_BASEALPHA
	tRGB *= background.a;
#elif _CBLENDSRC2_ONEMINUSBASEALPHA
	tRGB *= 1.0 - background.a;
#elif _CBLENDSRC2_BLENDALPHA
	tRGB *= foreground.a;
#elif _CBLENDSRC2_ONEMINUSBLENDALPHA
	tRGB *= 1.0 - foreground.a;
#elif _CBLENDSRC2_BASECOLORVALUE
	tRGB *= max( background.r, max( background.g, background.b));
#elif _CBLENDSRC2_ONEMINUSBASECOLORVALUE
	tRGB *= 1.0 - max( background.r, max( background.g, background.b));
#elif _CBLENDSRC2_BLENDCOLORVALUE
	tRGB *= max( foreground.r, max( foreground.g, foreground.b));
#elif _CBLENDSRC2_ONEMINUSBLENDCOLORVALUE
	tRGB *= 1.0 - max( foreground.r, max( foreground.g, foreground.b));
#endif

	half3 color = background.rgb;
#if   _CBLENDOP2_OVERRIDE
	color = foreground.rgb;
#elif _CBLENDOP2_MULTIPLY
	color = BelndMultiply( background.rgb, foreground.rgb);
#elif _CBLENDOP2_DARKEN
	color = BelndDarken( background.rgb, foreground.rgb);
#elif _CBLENDOP2_COLORBURN
	color = BelndColorBurn( background.rgb, foreground.rgb);
#elif _CBLENDOP2_LINEARBURN
	color = BelndLinearBurn( background.rgb, foreground.rgb);
#elif _CBLENDOP2_LIGHTEN
	color = BelndLighten( background.rgb, foreground.rgb);
#elif _CBLENDOP2_SCREEN
	color = BelndScreen( background.rgb, foreground.rgb);
#elif _CBLENDOP2_COLORDODGE
	color = BelndColorDodge( background.rgb, foreground.rgb);
#elif _CBLENDOP2_LINEARDODGE
	color = BelndLinearDodge( background.rgb, foreground.rgb);
#elif _CBLENDOP2_OVERLAY
	color = BelndOverlay( background.rgb, foreground.rgb);
#elif _CBLENDOP2_HARDLIGHT
	color = BelndHardLight( background.rgb, foreground.rgb);
#elif _CBLENDOP2_VIVIDLIGHT
	color = BelndVividLight( background.rgb, foreground.rgb);
#elif _CBLENDOP2_LINEARLIGHT
	color = BelndLinearLight( background.rgb, foreground.rgb);
#elif _CBLENDOP2_PINLIGHT
	color = BelndPinLight( background.rgb, foreground.rgb);
#elif _CBLENDOP2_HARDMIX
	color = BelndHardMix( background.rgb, foreground.rgb);
#elif _CBLENDOP2_DIFFERENCE
	color = BelndDifference( background.rgb, foreground.rgb);
#elif _CBLENDOP2_EXCLUSION
	color = BelndExclusion( background.rgb, foreground.rgb);
#elif _CBLENDOP2_SUBSTRACT
	color = BelndSubstract( background.rgb, foreground.rgb);
#elif _CBLENDOP2_DIVISION
	color = BelndDivision( background.rgb, foreground.rgb);
#endif
	return half4( clamp( lerp( background.rgb, color, tRGB), 0.0, 4.0), alpha);
}
/**
Shader
{
	Properties
	{
		[KeywordEnum(None, Override, Multiply, Darken, ColorBurn, LinearBurn, Lighten, Screen, ColorDodge, LinearDodge, Overlay, HardLight, VividLight, LinearLight, PinLight, HardMix, Difference, Exclusion, Substract, Division)]
		_VERTEXCOLORBLENDOP( "Vertex Color Blend Op", float) = 2
		[KeywordEnum(Value, AlphaBlendResult, OneMinusAlphaBlendResult, KeepAlpha, OneMinusKeepAlpha, VertexAlpha, OneMinusVertexAlpha)]
		_VERTEXCOLORBLENDFACTOR( "Vertex Color Blend Factor", float) = 1
		_VertexColorBlendVolume( "Vertex Color Blend Volume", float) = 1.0
		[KeywordEnum(None, Override, Multiply, Add, Substract, ReverseSubstract, Maximum)]
		_VERTEXALPHABLENDOP( "Vertex Alpha Blend Op", float) = 2
		_VertexAlphaBlendVolume( "Vertex Alpha Blend Volume", float) = 1.0
	}
	SubShader
	{
		Pass
		{
			#pragma shader_feature _VERTEXALPHABLENDOP_NONE _VERTEXALPHABLENDOP_OVERRIDE _VERTEXALPHABLENDOP_MULTIPLY _VERTEXALPHABLENDOP_ADD _VERTEXALPHABLENDOP_SUBSTRACT _VERTEXALPHABLENDOP_REVERSESUBSTRACT _VERTEXALPHABLENDOP_MAXIMUM
			#pragma shader_feature _VERTEXCOLORBLENDOP_NONE _VERTEXCOLORBLENDOP_OVERRIDE _VERTEXCOLORBLENDOP_MULTIPLY _VERTEXCOLORBLENDOP_DARKEN _VERTEXCOLORBLENDOP_COLORBURN _VERTEXCOLORBLENDOP_LINEARBURN _VERTEXCOLORBLENDOP_LIGHTEN _VERTEXCOLORBLENDOP_SCREEN _VERTEXCOLORBLENDOP_COLORDODGE _VERTEXCOLORBLENDOP_LINEARDODGE _VERTEXCOLORBLENDOP_OVERLAY _VERTEXCOLORBLENDOP_HARDLIGHT _VERTEXCOLORBLENDOP_VIVIDLIGHT _VERTEXCOLORBLENDOP_LINEARLIGHT _VERTEXCOLORBLENDOP_PINLIGHT _VERTEXCOLORBLENDOP_HARDMIX _VERTEXCOLORBLENDOP_DIFFERENCE _VERTEXCOLORBLENDOP_EXCLUSION _VERTEXCOLORBLENDOP_SUBSTRACT _VERTEXCOLORBLENDOP_DIVISION
			#pragma shader_feature _VERTEXCOLORBLENDFACTOR_VALUE _VERTEXCOLORBLENDFACTOR_ALPHABLENDRESULT _VERTEXCOLORBLENDFACTOR_ONEMINUSALPHABLENDRESULT _VERTEXCOLORBLENDFACTOR_KEEPALPHA _VERTEXCOLORBLENDFACTOR_ONEMINUSKEEPALPHA _VERTEXCOLORBLENDFACTOR_VERTEXALPHA _VERTEXCOLORBLENDFACTOR_ONEMINUSVERTEXALPHA
		}
	}
}
*/
inline half VertexAlphaBlend( half4 background, half4 foreground, float tAlpha)
{
	half alpha = background.a;
#if   _VERTEXALPHABLENDOP_OVERRIDE
	alpha = foreground.a;
#elif _VERTEXALPHABLENDOP_MULTIPLY
	alpha *= foreground.a;
#elif _VERTEXALPHABLENDOP_ADD
	alpha += foreground.a;
#elif _VERTEXALPHABLENDOP_SUBSTRACT
	alpha -= foreground.a;
#elif _VERTEXALPHABLENDOP_REVERSESUBSTRACT	
	alpha = foreground.a - alpha;
#elif _VERTEXALPHABLENDOP_MAXIMUM
	alpha = max( background.a, foreground.a);
#endif
	return saturate( lerp( background.a, alpha, tAlpha));
}
inline half4 VertexColorBlend( half4 background, half4 foreground, float tRGB, float tAlpha)
{
	half alpha = VertexAlphaBlend( background, foreground, tAlpha);
	
#if   _VERTEXCOLORBLENDFACTOR_VALUE
#elif _VERTEXCOLORBLENDFACTOR_ALPHABLENDRESULT
	tRGB *= alpha;
#elif _VERTEXCOLORBLENDFACTOR_ONEMINUSALPHABLENDRESULT
	tRGB *= 1.0 - alpha;
#elif _VERTEXCOLORBLENDFACTOR_KEEPALPHA
	tRGB *= background.a;
#elif _VERTEXCOLORBLENDFACTOR_ONEMINUSKEEPALPHA
	tRGB *= 1.0 - background.a;
#elif _VERTEXCOLORBLENDFACTOR_VERTEXALPHA
	tRGB *= foreground.a;
#elif _VERTEXCOLORBLENDFACTOR_ONEMINUSVERTEXALPHA
	tRGB *= 1.0 - foreground.a;
#endif

	half3 rgb = background.rgb;
#if   _VERTEXCOLORBLENDOP_OVERRIDE
	rgb = foreground.rgb;
#elif _VERTEXCOLORBLENDOP_MULTIPLY
	rgb = BelndMultiply( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_DARKEN
	rgb = BelndDarken( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_COLORBURN
	rgb = BelndColorBurn( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_LINEARBURN
	rgb = BelndLinearBurn( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_LIGHTEN
	rgb = BelndLighten( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_SCREEN
	rgb = BelndScreen( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_COLORDODGE
	rgb = BelndColorDodge( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_LINEARDODGE
	rgb = BelndLinearDodge( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_OVERLAY
	rgb = BelndOverlay( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_HARDLIGHT
	rgb = BelndHardLight( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_VIVIDLIGHT
	rgb = BelndVividLight( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_LINEARLIGHT
	rgb = BelndLinearLight( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_PINLIGHT
	rgb = BelndPinLight( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_HARDMIX
	rgb = BelndHardMix( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_DIFFERENCE
	rgb = BelndDifference( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_EXCLUSION
	rgb = BelndExclusion( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_SUBSTRACT
	rgb = BelndSubstract( background.rgb, foreground.rgb);
#elif _VERTEXCOLORBLENDOP_DIVISION
	rgb = BelndDivision( background.rgb, foreground.rgb);
#endif
	return half4( clamp( lerp( background.rgb, rgb, tRGB), 0.0, 4.0), alpha);
}
#endif