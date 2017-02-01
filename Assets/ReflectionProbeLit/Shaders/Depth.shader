Shader "ReflectionProbeLit/Depth"
{	
	Properties
	{
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
			};

			struct v2f
			{				
				float4 vertex : SV_POSITION;
				float2 depth : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = DualParaboloid(v.vertex);
				o.depth = o.vertex.z;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				return EncodeFloatRGBA(i.depth);
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
			};

			struct v2f
			{				
				float4 vertex : SV_POSITION;
				float2 depth : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = DualParaboloid(v.vertex);
				o.depth = o.vertex.z;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				return EncodeFloatRGBA(i.depth);
			}
			ENDCG
		}
	}
}
