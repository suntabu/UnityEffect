// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/ParticleMask"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BrushTex ("Brush Texture", 2D) = "white" {}
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_canvas("Canvas", Vector) = (0,0,0,0) 
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}
		LOD 100
		ZTest Always
		ZWrite off
		Blend One OneMinusSrcAlpha
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
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
			uniform float4x4 _O2W;
			uniform float2 _Pos;
			uniform float2 _Scale;
			float2 calcUV2(float4 canvas, float4 pos)
            {
                float width = canvas.z * _Scale;
                float height = canvas.w * _Scale;
            
                float2 xdir = normalize(mul(_O2W, float3(10,0,0)).xy);
                float2 ydir = normalize(mul(_O2W, float3(0,10,0)).xy);
                
                
               float4 ori = float4(_Pos.x,_Pos.y,0,0);
                
                float4 vec = (pos - ori) * 100;
//                vec.xy /= vec.w;
                float u = (dot(vec.xy, xdir) + 0.5 * width) / width;
                float v = (dot(vec.xy, ydir) + 0.5 * height) / height;
            
                float2 result = float2(u,v);
                
                return result;
            }

            sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BrushTex;
			float4 _BrushTex_ST;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
		
			float4 _canvas;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv1 = TRANSFORM_TEX(v.uv, _MaskTex);
				
				o.uv2 = calcUV2(_canvas,v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				
				fixed4 brush;
				brush = tex2D(_BrushTex, i.uv2 );

				fixed maskA = tex2D(_MaskTex, i.uv1).a;
				brush *= maskA;
                brush *= col.a;
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col * brush.a;
			}
			ENDCG
		}
	}
}
