Shader "Unlit/LightFlow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColor ("Light", Color) = (1,1,1,1)
        _LightWidth ("Light width", float) = 0.2
        _LightAngle ("Light angle", float) = 45
        _LightRange("Light range", float) = 0
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha

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
            uniform float4 _LightColor;
            float _LightWidth;
            float _LightAngle;
            float _LightRange;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
 

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                float angle = radians(_LightAngle);
                float halfWidth = _LightWidth / 2 / cos(angle);
                
                float base = tan(angle) * i.uv.x + _LightRange;
                float up = base + halfWidth;
                float down = base - halfWidth ;
                float pwidth = length(float2(ddx(i.uv.x), ddy(i.uv.y))) * 30;
                
                float4 light = (smoothstep(up, up + pwidth, i.uv.y) - smoothstep(down - pwidth, down , i.uv.y)) *  _LightColor;
                col.rgb = col.rgb + light.rgb * light.a;
                
             
                return col;
            }
            ENDCG
        }
    }
}