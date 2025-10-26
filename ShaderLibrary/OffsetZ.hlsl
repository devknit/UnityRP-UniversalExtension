#ifndef __KNIT_OFFSET_Z_HLSL__
#define __KNIT_OFFSET_Z_HLSL__

float4 GetClipPositionWithZOffset( float4 originalPositionCS, float viewSpaceZOffsetAmount)
{
	// Perspective camera case
	if( unity_OrthoParams.w == 0)
	{
		float2 ProjM_ZRow_ZW = UNITY_MATRIX_P[ 2].zw;
		float modifiedPositionVS_Z = -originalPositionCS.w + -viewSpaceZOffsetAmount; // push imaginary vertex
		float modifiedPositionCS_Z = modifiedPositionVS_Z * ProjM_ZRow_ZW[ 0] + ProjM_ZRow_ZW[ 1];
		originalPositionCS.z = modifiedPositionCS_Z * originalPositionCS.w / (-modifiedPositionVS_Z); // overwrite positionCS.z
		return originalPositionCS;    
	}
	// Orthographic camera case
	originalPositionCS.z += -viewSpaceZOffsetAmount / _ProjectionParams.z; // push imaginary vertex and overwrite positionCS.z
	return originalPositionCS;
}
#endif
