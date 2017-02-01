// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "BlueEffect/Enemy/Enemy" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MetallicGlossMap("Metallic", 2D) = "white" {}
		_BumpScale("Normal Scale", Float) = 1.0
		[Normal]
		_BumpMap("Normal Map", 2D) = "white" {}		
		[HDR]
		_EmissionColor("Emission Color", Color) = (1,1,1,1)
		_EmissionMap("Emission Map", 2D) = "white" {}

		_HitMap("Hit Map", 2D) = "white" {}
		
		_HitPosition01("Hit Position01 XYZ, scale", Vector) = (0,0,0,1)
		[HDR]
		_HitColor01("Color", Color) = (1,1,1,1)

		_HitPosition02("Hit Position02 XYZ, scale", Vector) = (0,0,0,1)
		[HDR]
		_HitColor02("Color", Color) = (1,1,1,1)
			
		_HitPosition03("Hit Position03 XYZ, scale", Vector) = (0,0,0,1)
		[HDR]
		_HitColor03("Color", Color) = (1,1,1,1)
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			Cull Back

			CGPROGRAM
			//#include "UnityCG.cginc"
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows vertex:vert

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

		float emissionPower;

		sampler2D _MainTex;
		sampler2D _MetallicGlossMap;
		sampler2D _BumpMap;
		sampler2D _EmissionMap;
		sampler2D _HitMap;
		
		half _BumpScale;
		fixed4 _Color;				
		half4 _EmissionColor;
		
		float4 _HitPosition01;
		float4 _HitPosition02;
		float4 _HitPosition03;
		half4 _HitColor01;
		half4 _HitColor02;
		half4 _HitColor03;

		struct Input {
			float2 uv_MainTex;
			float2 uv_HitMap;
			float4 distance;
		};

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float3 worldPos = mul(_Object2World, v.vertex);
			o.distance.x = pow(saturate(1.0 - length(worldPos.xyz - _HitPosition01.xyz) / _HitPosition01.w), 4.0);
			o.distance.y = pow(saturate(1.0 - length(worldPos.xyz - _HitPosition02.xyz) / _HitPosition02.w), 4.0);
			o.distance.z = pow(saturate(1.0 - length(worldPos.xyz - _HitPosition03.xyz) / _HitPosition03.w), 4.0);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{			
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			fixed4 metallicGloss = tex2D(_MetallicGlossMap, IN.uv_MainTex);
			o.Metallic = metallicGloss.r;
			o.Smoothness = metallicGloss.a;
			o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_MainTex), _BumpScale);
			o.Emission = tex2D(_EmissionMap, IN.uv_MainTex).rgb * _EmissionColor.rgb + emissionPower;

			fixed4 hitTex = tex2D(_HitMap, IN.uv_HitMap);
			o.Emission.rgb += hitTex.rgb * _HitColor01.rgb * IN.distance.x;
			o.Emission.rgb += hitTex.rgb * _HitColor02.rgb * IN.distance.y;
			o.Emission.rgb += hitTex.rgb * _HitColor03.rgb * IN.distance.z;

			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
