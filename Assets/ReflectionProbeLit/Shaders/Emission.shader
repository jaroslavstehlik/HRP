Shader "ReflectionProbeLit/Albedo"
{
	Properties
	{
		[HDR]
		_EmissionColor ("Emission Color", Color) = (1,1,1,1)
		_EmissionMap ("Emission", 2D) = "white" {}
	}

	SubShader
	{
		Tags { "RenderType"="Background" }
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{				
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D  _EmissionMap;
			float4  _EmissionColor;
			float4  _EmissionMap_ST;			

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = DualParaboloid(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,  _EmissionMap);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return tex2D( _EmissionMap, i.uv) * _EmissionColor;
			}
			ENDCG
		}
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{				
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D  _EmissionMap;
			float4  _EmissionColor;
			float4  _EmissionMap_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = DualParaboloid(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,  _EmissionMap);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Near clipping
				return tex2D( _EmissionMap, i.uv) * _EmissionColor;
			}
			ENDCG
		}
	}
}
