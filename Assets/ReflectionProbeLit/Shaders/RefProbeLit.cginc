float3 DualParaboloid(float3 position)
{
	position = mul(UNITY_MATRIX_MVP, position);
	float len = length(position.xyz);
	position /= len;
	position.z += 1;
	position.x /= position.z;
	position.y /= position.z;
	position.z = (len - _ProjectionParams.y * position.z) / (_ProjectionParams.z - _ProjectionParams.y);

	#ifdef NO_DEPTH_SHADER
	position.z = 1;
	#endif

	return position;
}

float4 DualParaboloid(float4 position)
{
	position = mul(UNITY_MATRIX_MVP, position);
	float len = length(position.xyz);
	position /= len;
	position.z += 1;
	position.x /= position.z;
	position.y /= position.z;
	position.z = (len - _ProjectionParams.y * position.z) / (_ProjectionParams.z - _ProjectionParams.y);

#ifdef NO_DEPTH_SHADER
	position.z = 1;
#endif

	position.w = 1;

	return position;
}

float4 DualParaboloidCoords(float3 R)
{
	// calculate the front paraboloid map texture coordinates
	float2 front;
	front.xy = R.xy / (1 - R.z);
	front.x = -.5f * front.x + .5f; //bias and scale to correctly sample a d3d texture
	front.y = .5f * front.y + .5f;

	// calculate the back paraboloid map texture coordinates
	float2 back;
	back.xy = R.xy / (R.z + 1);
	back.x = .5f * back.x + .5f; //bias and scale to correctly sample a d3d texture
	back.y = .5f * back.y + .5f;

	return float4(back, front);
}