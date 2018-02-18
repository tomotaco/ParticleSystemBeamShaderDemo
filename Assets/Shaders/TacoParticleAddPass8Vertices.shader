// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "TacoParticles/AdditivePass8Vertices" {
Properties {
    _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("Particle Texture", 2D) = "white" {}
    _InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend SrcAlpha One
    ColorMask RGB
    Cull Off Lighting Off ZWrite Off

    SubShader {
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_particles
            #pragma multi_compile_fog
            #pragma enable_d3d11_debug_symbols

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _TintColor;

            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float4 texcood0 : TEXCOORD0; // uv = texcood0.xy, size = texcood0.zw
                float4 texcood1 : TEXCOORD1; // velocity = texcood1.xyz
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                #ifdef SOFTPARTICLES_ON
                float4 projPos : TEXCOORD2;
                #endif
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _MainTex_ST;

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float3 velocity = normalize(v.texcood1.xyz);
                float3 viewDir0Org = WorldSpaceViewDir(v.vertex);
                float3 viewDir0 = normalize(viewDir0Org);
		float3 vertex0ModelView = UnityObjectToViewPos(v.vertex);
		float  length0 = length(viewDir0Org);
                float3 offsetU0 = normalize(cross(viewDir0, velocity));
                float3 offsetV0 = normalize(cross(viewDir0, offsetU0));
                float2 uv = v.texcood0.xy;
		float2 size = v.texcood0.zw;
		float sgn = sign(dot(viewDir0, velocity));

		float3 vertex0ClipPos = UnityObjectToClipPos(v.vertex);
		float3 vertex1 = v.vertex + velocity * size.y;
		float3 vertex1ModelView = UnityObjectToViewPos(vertex1);
                float3 viewDir1Org = WorldSpaceViewDir(float4(vertex1, 1.0));
		float  length1 = length(viewDir1Org);
		float3 viewDir1 = normalize(viewDir1Org);
                float3 offsetU1 = normalize(cross(viewDir1, velocity));
                float3 offsetV1 = normalize(cross(viewDir1, offsetU1));

		float3 vertex1ClipPos = UnityObjectToClipPos(vertex1);

		float4 rv0 = mul(UNITY_MATRIX_P, float4(size.x, 0, vertex0ModelView.z, 1.0));
		float r0 = rv0.x / rv0.w;
		float4 rv1 = mul(UNITY_MATRIX_P, float4(size.x, 0, vertex1ModelView.z, 1.0));
		float r1 = rv1.x / rv1.w;
		float len = max(distance(vertex0ModelView.xy / length0, vertex1ModelView.xy / length1) - abs(r0 - r1), 0.0);

		float ratioSide =  0.5 + sgn *  clamp(abs(r0 - r1) / len, 0.0, 1.0) * 0.5;

/*
0	-> 0
0.25	-> ratioSide (0.5)
0.75	-> ratioSide (0.5)
1.0	-> 1.0
*/
// 0 1 3 4
		float mod2 = fmod(uv.y * 4.0, 2.0);
		float textureV  = (1.0 - mod2) * uv.y + mod2 * ratioSide;
/*
0	-> 0
0.25	-> 0.0
0.75	-> 1.0
1.0	-> 1.0
*/
		float positionV = step(uv.y, 0.5) * 2.0;


 
                float3 vert = v.vertex +
		                      offsetU0 * (uv.x - 0.5) * size.x +
		                      velocity * size.y * positionV +
		                      offsetV0 * clamp(textureV - 0.5, 0, 0.5) * size.x +
		                      offsetV1 * clamp(textureV - 0.5, -0.5, 0) * size.x;

                o.vertex = UnityObjectToClipPos(vert);
                #ifdef SOFTPARTICLES_ON
                o.projPos = ComputeScreenPos (o.vertex);
                COMPUTE_EYEDEPTH(o.projPos.z);
                #endif
                o.color = v.color;
                o.texcoord = TRANSFORM_TEX(float2(uv.x, textureV), _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            float _InvFade;

            fixed4 frag (v2f i) : SV_Target
            {
                #ifdef SOFTPARTICLES_ON
                float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
                float partZ = i.projPos.z;
                float fade = saturate (_InvFade * (sceneZ-partZ));
                i.color.a *= fade;
                #endif

                fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
                UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
                return col;
            }
            ENDCG
        }
    }
}
}
