// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ReflectionProbeLit/Normal"
{	
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}

		_BumpScale("Bump Scale", Float) = 1
		[Normal] _BumpMap("Bump Map", 2D) = "bump" {}				
		
		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		_MetallicGlossMap("Metallic", 2D) = "white" {}
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
			#include "UnityStandardInput.cginc"
			#include "RefProbeLit.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{				
				float4 vertex : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float3 worldNormal : NORMAL;
			};

			float4 _BumpMap_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = DualParaboloid(v.vertex);
				o.texcoord0 = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoord1 = TRANSFORM_TEX(v.texcoord, _BumpMap);
				o.worldNormal.xyz = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 normalTex = tex2D(_BumpMap, i.texcoord1);
				float3 normal = normalize(i.worldNormal) - (-1 + normalTex * 2.0) * _BumpScale;				
				return fixed4(0.5 + normalize(normal) * 0.5, MetallicGloss(i.texcoord0).g);
			}
			ENDCG
		}
	}
}
