Shader "Unlit/particlebg"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
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
                float2 uv1: TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1: TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float4x4 _O2W;
            uniform float2 _Pos;
            uniform float2 _Scale;
            v2f vert (appdata ve)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(ve.vertex);
                o.uv = TRANSFORM_TEX(ve.uv, _MainTex);

                float width = 512 * _Scale;
                float height = 512 * _Scale;
                
                float2 xdir = normalize(mul(_O2W, float3(10,0,0)).xy);
                float2 ydir = normalize(mul(_O2W, float3(0,10,0)).xy);
                
                float4 ori = float4(_Pos.x,_Pos.y,0,0);
                
                float4 vec = (ve.vertex - ori) * 100;
//                vec.xy /= vec.w;
                float u = (dot(vec.xy, xdir) + 0.5 * width) / width;
                float v = (dot(vec.xy, ydir) + 0.5 * height) / height;

                o.uv1 = float2(u,v);

                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv1);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
//                return float4(i.uv1.x,i.uv1.y,0,1);
                return col;
            }
            ENDCG
        }
    }
}
