#ifndef __KNIT_COLORPREMULTIPLY_HLSL__
#define __KNIT_COLORPREMULTIPLY_HLSL__

half4 ColorPremultiply( half4 color, half2 premultiply)
{
	half3 multiply = lerp( color.rgb, color.rgb * color.a, saturate( premultiply.x));
	half3 blend = lerp( color.rgb, color.rgb * color.a + premultiply.xxx * (1.0 - color.a), abs( premultiply.y));
	color.rgb = lerp( blend, multiply, step( 0, premultiply.y));
	color.a = color.a * saturate( premultiply.y);
	return color;
}
#endif
