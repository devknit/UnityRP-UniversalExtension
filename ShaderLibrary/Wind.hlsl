#ifndef __KNIT_WIND_HLSL__
#define __KNIT_WIND_HLSL__

float3 TransformObjectToWorldWind( float3 positionOS, float3 normalOS)
{
#if defined(_WINDMODE_SIMPLE)
	positionOS += sin( _Time.yyy + positionOS * 314.1592653589) * normalOS * _WindStrength;
#endif
	float3 positionWS = TransformObjectToWorld( positionOS);
	return positionWS;
}
#endif
