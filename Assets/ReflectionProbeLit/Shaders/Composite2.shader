// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ReflectionProbeLit/Composite2" 
{
	Properties
	{
		_FrontTexAlbedo ("Front Albedo", 2D) = "white" {}
		_BackTexAbledo ("Back Albedo", 2D) = "white" {}
		_FrontTexNormal ("Front Normal", 2D) = "white" {}
		_BackTexNormal ("Back Normal", 2D) = "white" {}
		_FrontTexDepth ("Front Depth", 2D) = "white" {}
		_BackTexDepth ("Back Depth", 2D) = "white" {}
		_FrontTexEmission("Front Emission", 2D) = "white" {}
		_BackTexEmission("Back Emission", 2D) = "white" {}
	}
	SubShader
	{
		
		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
		LOD 300
		Cull Front

		Pass
		{
			Name "FORWARD" 
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma target 3.0
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
				float4 worldNormal : TEXCOORD0;
				float4 paraboloidUV : TEXCOORD1;
			};
			
			sampler2D _FrontTexDepth;
			sampler2D _BackTexDepth;

			float4 _DP_Params;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldNormal.xyz = UnityObjectToWorldNormal(v.normal);
				o.worldNormal.w = step(o.worldNormal.z, 0.0);
				o.paraboloidUV = DualParaboloidCoords(o.worldNormal);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{			
				fixed4 output;
				fixed pSign = i.worldNormal.w;
				fixed nSign = 1 - pSign;

				float4 depthPacked = tex2D(_FrontTexDepth, i.paraboloidUV.xy) * nSign + tex2D(_BackTexDepth, i.paraboloidUV.zw) * pSign;
				float depth = DecodeFloatRGBA(depthPacked) * _DP_Params.y * _DP_Params.y;

				clip(1.0 - depth * 0.0009);
			    return 0;
			}
			ENDCG
		}

		Pass
		{
			Name "FORWARD_BASE"
			Tags{ "LightMode" = "ForwardBase" }
			Blend One One

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#define POINT
			#include "UnityCG.cginc"
			#include "RefProbeLit.cginc"
			#include "AutoLight.cginc"
			#include "UnityPBSLighting.cginc"
			#include "UnityStandardUtils.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD0;
				float4 worldNormal : TEXCOORD1;
				float4 paraboloidUV : TEXCOORD2;
			};

			sampler2D _FrontTexAlbedo;
			sampler2D _BackTexAbledo;
			sampler2D _FrontTexNormal;
			sampler2D _BackTexNormal;
			sampler2D _FrontTexDepth;
			sampler2D _BackTexDepth;
			sampler2D _FrontTexEmission;
			sampler2D _BackTexEmission;

			float4 _DP_Params;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normal = v.normal;

				o.viewDir = float3(mul(_Object2World, v.vertex) - _WorldSpaceCameraPos).xyz;
				o.worldNormal.xyz = UnityObjectToWorldNormal(v.normal);
				o.worldNormal.w = step(o.worldNormal.z, 0.0);
				o.paraboloidUV = DualParaboloidCoords(o.worldNormal);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 output;
				fixed pSign = i.worldNormal.w;
				fixed nSign = 1 - pSign;

				float4 depthPacked = tex2D(_FrontTexDepth, i.paraboloidUV.xy) * nSign + tex2D(_BackTexDepth, i.paraboloidUV.zw) * pSign;
				float depth = DecodeFloatRGBA(depthPacked) * _DP_Params.y * _DP_Params.y;
				clip(1.0 - depth * 0.0009);

				fixed4 albedo = tex2D(_FrontTexAlbedo, i.paraboloidUV.xy) * nSign + tex2D(_BackTexAbledo, i.paraboloidUV.zw) * pSign;

				fixed4 normalTex = tex2D(_FrontTexNormal, i.paraboloidUV.xy) * nSign + tex2D(_BackTexNormal, i.paraboloidUV.zw) * pSign;
				fixed3 normal = -1 + normalTex.rgb * 2;

				float3 worldPos = mul(_Object2World, float4(0, 0, 0, 1)) + i.worldNormal.xyz * depth;
				float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);

				float3 lightVec = _WorldSpaceLightPos0.xyz;
				float lightDist = length(lightVec);
				float3 lightDir = lightVec / lightDist;

				fixed4 emission = tex2D(_FrontTexEmission, i.paraboloidUV.xy) * nSign + tex2D(_BackTexEmission, i.paraboloidUV.zw) * pSign;

				float3 specularTint;
				float oneMinusReflectivity;

				fixed3 diffuse = DiffuseAndSpecularFromMetallic(
					albedo.rgb, albedo.a, /*out*/specularTint, /*out*/oneMinusReflectivity
				);

				UnityLight light;
				light.color = _LightColor0.rgb;
				light.dir = lightDir;
				light.ndotl = DotClamped(normal, lightDir);
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

				output = UNITY_BRDF_PBS(
					diffuse, specularTint,
					oneMinusReflectivity, normalTex.a,
					normal, viewDir,
					light, indirectLight
				) + emission;

				return clamp(output, 0, 100000);
				}
				ENDCG
			}

	}
}
