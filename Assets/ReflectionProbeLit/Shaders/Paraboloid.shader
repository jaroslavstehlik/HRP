// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ReflectionProbeLit/Paraboloid"
{
	Properties
	{
		_FrontTexAlbedo("Front Paraboloid Texture", 2D) = "white" {}
		_BackTexAbledo("Back Paraboloid Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "RefProbeLit.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{				
				float4 vertex : SV_POSITION;
				float3 viewDir : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
			};

			sampler2D _FrontTexAlbedo;
			sampler2D _BackTexAbledo;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.viewDir = float3(mul(_Object2World, v.vertex) - _WorldSpaceCameraPos).xyz;
				o.worldNormal = normalize( mul(_Object2World, float4(v.normal, 1.0)).xyz);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{				
			    float4 paraboloidUV = DualParaboloidCoords(i.worldNormal);

				fixed sign = step(i.worldNormal.z, 0.0);
				float4 forward = tex2D(_FrontTexAlbedo, paraboloidUV.xy ) * (1 - sign);    // sample the front paraboloid map
				float4 backward = tex2D(_BackTexAbledo, paraboloidUV.zw ) * sign;    // sample the back paraboloid map

				return forward + backward;
			}
			ENDCG
		}
	}
}
