Shader "Custom/GS Billboard" 
{
	Properties 
	{
		_SpriteTex ("Base (RGB)", 2D) = "white" {}
		_Size ("Size", Range(0, 3)) = 0.5
	}

	SubShader 
	{ 
	 	Cull Off
	 	//ZTest Equal 
	    //ZWrite On

		Pass
		{  
	
			Cull  Off
			Tags { "RenderType"="Transparent" }
			LOD 200
		
			CGPROGRAM
				#pragma target 5.0
				#pragma vertex VS_Main
				#pragma fragment FS_Main
				#pragma geometry GS_Main 
				//#pragma  CullMode none
				#include "UnityCG.cginc" 

				// **************************************************************
				// Data structures												*
				// **************************************************************
				struct GS_INPUT
				{
					float4	pos		: POSITION;
					float3	normal	: NORMAL;
					float2  tex0	: TEXCOORD0;
				};

				struct FS_INPUT
				{
					float4	pos		: POSITION;
					float2  tex0	: TEXCOORD0;
					float3 normal	: NORMAL;
				};


				// **************************************************************
				// Vars															*
				// **************************************************************
				//CullMode = none;
				float _Size;
				float4x4 _VP;
				Texture2D _SpriteTex;
				SamplerState sampler_SpriteTex;

				// **************************************************************
				// Shader Programs												*
				// **************************************************************

				// Vertex Shader ------------------------------------------------
				GS_INPUT VS_Main(appdata_base v)
				{
					GS_INPUT output = (GS_INPUT)0;

					output.pos =  mul(UNITY_MATRIX_MVP, v.vertex);
					output.normal = v.normal;
					output.tex0 = float2(0, 0);

					return output;
				}



				// Geometry Shader -----------------------------------------------------
				[maxvertexcount(6)]
				void GS_Main(triangle GS_INPUT p[3], inout TriangleStream<FS_INPUT> triStream)
				{
					float3 up = float3(0, 1, 0);
					float3 look = _WorldSpaceCameraPos - p[0].pos;
					look.y = 0;
					look = normalize(look);
					float3 right = cross(up, look);
					
					float halfS = 0.5f * _Size;
							
					float4 v[4];
					v[0] = float4(p[0].pos + halfS * right - halfS * up, 1.0f);
					v[1] = float4(p[0].pos + halfS * right + halfS * up, 1.0f);
					v[2] = float4(p[0].pos - halfS * right - halfS * up, 1.0f);
					v[3] = float4(p[0].pos - halfS * right + halfS * up, 1.0f);

					//float4x4 vp = mul(UNITY_MATRIX_MVP, _World2Object);
					FS_INPUT pIn;
					
					float3 parallel1 = p[1].pos.xyz - p[0].pos.xyz;
					float3 parallel2 = p[2].pos.xyz - p[0].pos.xyz;
					float3 trinormal = normalize(cross(parallel2,parallel1));
					
					pIn.pos = float4(p[0].pos + (trinormal * _Size),p[0].pos.w);
					pIn.tex0 = float2(1.0f, 0.0f);
					pIn.normal = p[0].normal;
					triStream.Append(pIn);

					pIn.pos =  float4(p[1].pos + (trinormal * _Size),p[1].pos.w);
					pIn.tex0 = float2(1.0f, 1.0f);
					pIn.normal = p[1].normal;
					triStream.Append(pIn);

					pIn.pos = float4(p[2].pos +  (trinormal * _Size),p[2].pos.w);
					pIn.tex0 = float2(0.0f, 0.0f);
					pIn.normal = p[2].normal;
					triStream.Append(pIn); 
					triStream.RestartStrip();
					 
					pIn.pos = float4(p[0].pos +  (trinormal * _Size + .1),p[0].pos.w);
					pIn.tex0 = float2(0.0f, 0.0f);
					pIn.normal = -1 * p[0].normal; 
					triStream.Append(pIn); 
				
					pIn.pos = float4(p[2].pos +  (trinormal * _Size + .1),p[2].pos.w);
					pIn.tex0 = float2(0.0f, 0.0f); 
					pIn.normal = -1 * p[2].normal;
					triStream.Append(pIn); 
					
					pIn.pos = float4(p[1].pos +  (trinormal * _Size +.1),p[1].pos.w);
					pIn.tex0 = float2(0.0f, 0.0f);
					pIn.normal = -1 * p[1].normal;
					triStream.Append(pIn); 
					 
					 
					//pIn.pos =  mul(vp, v[3]);
					//pIn.tex0 = float2(0.0f, 1.0f);
					//triStream.Append(pIn);
				}



				// Fragment Shader -----------------------------------------------
				float4 FS_Main(FS_INPUT input) : COLOR
				{
					return float4 (input.normal * 0.5 + 0.5,1);//_SpriteTex.Sample(sampler_SpriteTex, input.tex0);
				}

			ENDCG
		}
	} 
}
