[200~Shader "Unlit/SwitchImage"
{
	Properties
		{
				_MainTex ("Texture", 2D) = "white" {}
						_ToTex("Switch to",2D) = "white" {}
								_Color ("Tint", Color) = (1,1,1,1)
										_Progress ("Progress", Range (0.0, 1)) = 0
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
																																				
																																				        Cull Off
																																							Lighting Off
																																									ZWrite Off
																																											Blend One OneMinusSrcAlpha
																																													ZTest [unity_GUIZTestMode]
																																															
																																																	Pass
																																																			{
																																																						CGPROGRAM
																																																									#pragma vertex vert
																																																												#pragma fragment frag
																																																															// make fog work
																																																																		#pragma multi_compile_fog
																																																																					
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

																																																																																																																																		fixed4 _Color;
																																																																																																																																					float _Progress;

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
																																																																																																																																																																																										            sampler2D _ToTex;
																																																																																																																																																																																											                
																																																																																																																																																																																																fixed4 frag (VertexOutput IN) : SV_Target
																																																																																																																																																																																																			{
																																																																																																																																																																																																						    float p = clamp(_Progress,0,1);
																																																																																																																																																																																																						    			
																																																																																																																																																																																																												    fixed4 from = tex2D(_MainTex, IN.texcoord);
																																																																																																																																																																																																												    			    fixed4 to = tex2D(_ToTex, IN.texcoord);
																																																																																																																																																																																																															    			    
																																																																																																																																																																																																																		    			    float pwidth = length(float2(ddx(IN.texcoord.x), ddy(IN.texcoord.y))) * 40;
																																																																																																																																																																																																																					                    
																																																																																																																																																																																																																							                    float v = smoothstep(p - pwidth, p + pwidth, IN.texcoord.y);
																																																																																																																																																																																																																									    			    fixed4 finalPixel;
																																																																																																																																																																																																																												    			    finalPixel.a = clamp((to.a + from.a) * _Color.a,0,1);
																																																																																																																																																																																																																															    			    finalPixel.rgb = v * to.rgb + (1-  v) * from.rgb;
																																																																																																																																																																																																																																		                    finalPixel.rgb = (finalPixel.rgb  * _Color.rgb) * finalPixel.a;
																																																																																																																																																																																																																																				    				return finalPixel;
																																																																																																																																																																																																																																											}
																																																																																																																																																																																																																																														ENDCG
																																																																																																																																																																																																																																																}
																																																																																																																																																																																																																																																	}
																																																																																																																																																																																																																																																	}
