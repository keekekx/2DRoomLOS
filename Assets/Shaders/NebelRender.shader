﻿// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "POS/NebelDesKrieg" {
Properties {
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    _NebelTex ("Base (RGB) Trans (A)", 2D) = "black" {}
    _MaskTex ("Base (RGB) Trans (A)", 2D) = "black" {}
}

SubShader {
    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 100


	Cull Off
	Lighting Off
    ZWrite Off
    Blend SrcAlpha OneMinusSrcAlpha

    Pass {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex 	: POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex 	: SV_POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _NebelTex;
            sampler2D _MaskTex;

            v2f vert (appdata_t v) {
                v2f OUT;
                //UNITY_SETUP_INSTANCE_ID(v);
                //UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.vertex = UnityObjectToClipPos(v.vertex);
				//float3 vert = UnityObjectToViewPos(v.vertex);
				//OUT.vertex =  float4(vert.x,vert.y,vert.z,0);
                //OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				OUT.texcoord = v.texcoord;
                //UNITY_TRANSFER_FOG(OUT,OUT.vertex);
                return OUT;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.texcoord);
                fixed3 sepia;
                sepia.r = dot(col.rgb, half3(0.393, 0.769, 0.189));
                sepia.g = dot(col.rgb, half3(0.349, 0.686, 0.168));   
                sepia.b = dot(col.rgb, half3(0.272, 0.534, 0.131));

                return lerp(fixed4(sepia.r, sepia.g, sepia.b, col.a), tex2D(_NebelTex, IN.texcoord), 1-tex2D(_MaskTex, IN.texcoord).x) ;
            }
        ENDCG
    }
}

}