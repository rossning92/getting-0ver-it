// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Custom/NormalMappedTileAnimated" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		[PerRendererData] _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MyNormalMap("My Normal map", 2D) = "white" {}
		_EmissiveMap("Emissive map", 2D) = "white" {}
		[HideInInspector] _RendererColor("RendererColor", Color) = (1,1,1,1)
			[HideInInspector] _Flip("Flip", Vector) = (1,1,1,1)
		[Toggle(EMISSIVE_TEXTURE)] _EnabledEmissive ("Use Emissive?", Float) = 0
			[Space]
		_RandOffset("Unique Offset", Range(0,1)) = 1
			[Space]
		_WindDir("Wind Direction", Range(-1,1)) = 1
			_BendScale("Bend Scale", Range(0,1)) = 1
			_SwayFreq("Sway Freq", Range(0,20)) = 1
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "DisableBatching" = "True" }
		LOD 200
		Cull Off

		CGPROGRAM
		#pragma shader_feature EMISSIVE_TEXTURE
		#pragma surface surf Standard fullforwardshadows alpha:fade vertex:vert
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MyNormalMap;
		sampler2D _EmissiveMap;

		fixed _WindDir;
		fixed _RandOffset;
		fixed _BendScale;
		fixed _SwayFreq;

		struct Input {
			float2 uv_MainTex;
			float4 screenPos;
			float3 worldPos;
			fixed4 color;
		};

		fixed4 _Color;
		fixed4 _RendererColor;
		half4 _Flip;

		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

			float _Tess;

		float4 tessFixed()
		{
			return _Tess;
		}

		float4 CubicSmooth(float4 x) {
			return x * x *(3.0 - 2.0 * x);
		}

		float4 TriangleWave(float4 x) {
			return abs(frac(x + _RandOffset + 0.5) * 2.0 - 1.0);
		}

		float4 SineApproximation(float4 x) {
			return CubicSmooth(TriangleWave(x));
		}

		void vert(inout appdata_full v, out Input o)
		{
			v.vertex.xy *= _Flip.xy;
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.color = v.color * _Color * _RendererColor;

			float3 vPos = v.vertex;
			float fLength = length(vPos);
			float fBF = vPos.y * (_BendScale) * ((SineApproximation(_Time[3] * (_SwayFreq)) + 0.5)*0.5);
			// Smooth bending factor and increase its nearby height limit.
			fBF += 1.0;
			fBF *= fBF;
			fBF = fBF * fBF - fBF;
			// Displace position
			float3 vNewPos = vPos;

			vNewPos.x += _WindDir * fBF * saturate(vPos.y);
			// Rescale
			vPos.xy = normalize(vNewPos.xy) * fLength;
			v.vertex.xy = vPos;

		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_MyNormalMap, IN.uv_MainTex));
#if EMISSIVE_TEXTURE
			o.Emission = tex2D(_EmissiveMap, IN.uv_MainTex);
#endif

			// Hack for outline: Make black pixels always black
			if(length(c.rgb)<0.001)
			{
				o.Normal = fixed3(0,0,-1);
				o.Albedo = fixed3(0,0,0);
			}
		}
		ENDCG
	}
	FallBack "Diffuse"
}
