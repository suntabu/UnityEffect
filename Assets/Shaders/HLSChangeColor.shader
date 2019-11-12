// This is a premultiply-alpha adaptation of the built-in Unity shader "UI/Default" in Unity 5.6.2 to allow Unity UI stencil masking.

Shader "UI/HLSChangeColor"
{
	Properties
	{
	    _HairColorTex("Hair Color",2D) = "black"{}
	    _ShinyColor("Shiny Color", Color) = (1,1,1,1)
	    _Progress("Progress", Range(0,1)) = 0
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255
		_Boost ("Lighting Up Ratio", Range(0,0.5)) = 0.15

        uH("Hue", Range(-180,180)) = 0.0
        uS("Saturation", Range(-100,100)) = 1.0   
        uL("Brightness", Range(-100,100)) = 1.0

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
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
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct VertexInput {
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput {
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
            float _Progress;
			float _Boost;
            float4 _ShinyColor;
            
			VertexOutput vert (VertexInput IN) {
				VertexOutput OUT;

				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.texcoord = IN.texcoord;

				#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1);
				#endif

				OUT.color = IN.color;  
				return OUT;
			}

			sampler2D _MainTex;
			sampler2D _HairColorTex;
			float uH;			//[-180~+180]
            float uS;			//[-100~+100]
            float uL;			//[-100~+100]
			 
                   
            float3 rgb2hsl(float3 color)
            {
                float3 hsl;
                float fmin = min(min(color.r, color.g), color.b);
                float fmax = max(max(color.r, color.g), color.b);
                float delta = fmax - fmin;
                
                hsl.z = (fmax + fmin) / 2.0;
                if (delta == 0.0)
                {
                    hsl.x = 0.0;
                    hsl.y = 0.0;
                }
                else
                {
                    if (hsl.z < 0.5)
                        hsl.y = delta / (fmax + fmin);
                    else
                        hsl.y = delta / (2.0 - fmax - fmin);
                    
                    float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
                    float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
                    float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;
                    
                    if (color.r == fmax )
                        hsl.x = deltaB - deltaG;
                    else if (color.g == fmax)
                        hsl.x = (1.0 / 3.0) + deltaR - deltaB;
                    else if (color.b == fmax)
                        hsl.x = (2.0 / 3.0) + deltaG - deltaR;
                    
                    if (hsl.x < 0.0)
                        hsl.x += 1.0;
                    else if (hsl.x > 1.0)
                        hsl.x -= 1.0;
                }
                
                return hsl;
            }
            
            float hue2rgb(float f1, float f2, float hue)
            {
                if (hue < 0.0)
                    hue += 1.0;
                else if (hue > 1.0)
                    hue -= 1.0;
                float res;
                if ((6.0 * hue) < 1.0)
                    res = f1 + (f2 - f1) * 6.0 * hue;
                else if ((2.0 * hue) < 1.0)
                    res = f2;
                else if ((3.0 * hue) < 2.0)
                    res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
                else
                    res = f1;
                return res;
            }
            
            float3 hsl2rgb(float3 hsl)
            {
                float3 rgb;
                if (hsl.y == 0.0)
                    rgb = hsl.zzz;
                else
                {
                    float f2;
                    if (hsl.z < 0.5)
                        f2 = hsl.z * (1.0 + hsl.y);
                    else
                        f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
                    float f1 = 2.0 * hsl.z - f2;
                    rgb.r = hue2rgb(f1, f2, hsl.x + (1.0/3.0));
                    rgb.g = hue2rgb(f1, f2, hsl.x);
                    rgb.b= hue2rgb(f1, f2, hsl.x - (1.0/3.0));
                }
                return rgb;
            }
                   
          
			

			fixed4 frag (VertexOutput IN) : SV_Target
			{
			    float2 uv = float2(IN.texcoord.x, IN.texcoord.y + _Progress);
			    fixed4 hair = (tex2D(_MainTex, IN.texcoord));
			    fixed4 color = tex2D(_HairColorTex, uv);
			    
			    float gap = step(0.02, color.rgb);
			    float gap1 = step(0, abs(uH * uS * uL));
			    
			    fixed4 finalPixel;
			    fixed4 coloredHair = hair;
                
                if(hair.a != 0.0)
                {
                    float r=hair.r;///hair.a;
                    float g=hair.g;///hair.a;
                    float b=hair.b;///hair.a;
                    float a=hair.a;
                    
                    //convert rgb to hsl
                    float h=0.0;
                    float s=0.0;
                    float l=0.0;
                    
                    float3 hslresult=rgb2hsl(float3(r,g,b));
                    h=hslresult.x;
                    s=hslresult.y;
                    l=hslresult.z;
                    
                    //(h,s,l)+(dH,dS,dL) -> (h,s,l)
                    h=h+uH/360.0;
                    s=s+uS*0.01;
                    l=l;
                    
                    if (h < 0.0)
                        h += 1.0;
                    else if (h > 1.0)
                        h -= 1.0;
                    
                  
                    
                    h = clamp(h, 0.0, 1.0);
                    s = clamp(s, 0.0, 1.0);
                    l = clamp(l, 0.0, 1.0);
                    
                    float3 inputcolor = hsl2rgb(float3(h,s,l));
                    
                    coloredHair = fixed4(inputcolor.rgb, a);
                    coloredHair.rgb += float3(uL * 0.01 * 0.4, uL * 0.01 * 0.4, uL * 0.01 * 0.4);
                    coloredHair.rgb = clamp(coloredHair.rgb, 0.0, 1.0);
                
                }
                
//                float gap = step(_Progress, IN.texcoord.y);
                
                finalPixel.rgb = lerp(hair.rgb, color.rgb, 0.5) * gap + (1 - gap) * (coloredHair.rgb * gap1+ hair.rgb * (1-gap1))  ;
                finalPixel.a = hair.a * IN.color.a;
                
				#ifdef UNITY_UI_ALPHACLIP
				finalPixel.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				clip (finalPixel.a - 0.001);
				#endif
		
				finalPixel.rgb = clamp(finalPixel.rgb * _ShinyColor.rgb * finalPixel.a, 0.0, 1.0);
				return finalPixel;
			}
		ENDCG
		}
	}
}
