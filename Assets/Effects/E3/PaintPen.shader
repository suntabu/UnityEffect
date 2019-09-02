Shader "Painter/Pen"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_BrushTex ("Brush Texture", 2D) = "white" {}
		_Color("Color",Color)=(1,1,1,1)
		_Alpha("Alpha",Range(0,1))=1
		_BlendRatio("_BlendRatio",Range(0,1))=0.5
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc("Src Factor",float)=5
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst("Dst Factor",float)=10
		[Enum(UnityEngine.Rendering.BlendMode)] _FactorA("Factor A",float)=1
		[Enum(UnityEngine.Rendering.BlendMode)] _FactorB("Factor B",float)=10
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode",float)=0
		_TileX("Tile x",Range(0,100))=1
		_TileY("Tile y",Range(0,100))=1
		_rect("Rect", Vector) = (0,0,0,0)
		_canvas("Canvas", Vector) = (0,0,0,0) 
		
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}
		LOD 100
		Cull [_CullMode]
		ZTest Always
		ZWrite off
		Blend [_BlendSrc] [_BlendDst] , [_FactorA] [_FactorB]
	
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BrushTex;
			float4 _BrushTex_ST;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			fixed4 _Color;
			fixed _Alpha;
			float _TileX;
			float _TileY;
			float4 _rect;
			float4 _canvas;
			float _BlendRatio;
			
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
            
            float2 calcUV2(float4 canvas, float4 rect, float2 uv)
            {
                float x = uv.x * rect.z + rect.x ;//- rect.z * 0.5;
                float y = ( uv.y * rect.w + canvas.w - rect.y - rect.w);
                float tileX = canvas.z / _TileX;
                float tileY = canvas.w / _TileY;
            
                float2 result = float2(x/tileX, y/tileY);
                
                return result;
            }

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv1 = TRANSFORM_TEX(v.uv, _MaskTex);
				
				o.uv2 = calcUV2(_canvas,_rect,v.uv);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				fixed4 brush;
				if(_TileX == 1 && _TileY == 1)
				{
				    brush = tex2D(_BrushTex, i.uv2 );
				}else
				{
				    brush = texNoTileTech1(_BrushTex, i.uv2 );
				}

				brush.a = col.a;

				fixed maskA = tex2D(_MaskTex, i.uv1).a*_Alpha;
				brush *= maskA;

				return brush;
			}
			ENDCG
		}
	}
}
