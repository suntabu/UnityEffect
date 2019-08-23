Shader "Unlit/TextureRepeat"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _BlendRatio("_BlendRatio",Range(0,1))=0.5

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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _BlendRatio;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float random (float2 uv)
            {
                return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
            }
			
			fixed4 texNoTileTech1(sampler2D tex, float2 uv) {
                float2 iuv = floor(uv);
                float2 fuv = frac(uv);
            
                // Generate per-tile transformation
                float4 ofa = random(iuv + float2(0, 0));
                float4 ofb = random(iuv + float2(1, 0));
                float4 ofc = random(iuv + float2(0, 1));
                float4 ofd = random(iuv + float2(1, 1));
            
                // Compute the correct derivatives
                float2 dx = ddx(uv);
                float2 dy = ddy(uv);
            
                // Mirror per-tile uvs
                ofa.zw = sign(ofa.zw - 0.5);
                ofb.zw = sign(ofb.zw - 0.5);
                ofc.zw = sign(ofc.zw - 0.5);
                ofd.zw = sign(ofd.zw - 0.5);
            
                float2 uva = uv * ofa.zw + ofa.xy, dxa = dx * ofa.zw, dya = dy * ofa.zw;
                float2 uvb = uv * ofb.zw + ofb.xy, dxb = dx * ofb.zw, dyb = dy * ofb.zw;
                float2 uvc = uv * ofc.zw + ofc.xy, dxc = dx * ofc.zw, dyc = dy * ofc.zw;
                float2 uvd = uv * ofd.zw + ofd.xy, dxd = dx * ofd.zw, dyd = dy * ofd.zw;
            
                // Fetch and blend
                float2 b = smoothstep(_BlendRatio, 1.0 - _BlendRatio, fuv);
            
                return lerp(lerp(tex2D(tex, uva, dxa, dya), tex2D(tex, uvb, dxb, dyb), b.x),
                                lerp(tex2D(tex, uvc, dxc, dyc), tex2D(tex, uvd, dxd, dyd), b.x), b.y);
            }
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = texNoTileTech1(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
