Shader "Custom/AlphaBlendWithShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Diffuse Color",Color) = (1,1,1,1)
        _AlphaScale("Alpha Scale",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"  "IgnoreProjector"="True"}

        LOD 100

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldPos:POSITION1;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed _AlphaScale;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 textColor = tex2D(_MainTex,i.uv);

                fixed3 albedo = textColor.rgb * _Diffuse.rgb;
                fixed3 ambient = unity_AmbientSky.rgb * albedo;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 color = ambient + diffuse*atten;
                return fixed4(color,textColor.a*_AlphaScale);
            }
            ENDCG
        }
    }

    //Fallback "Transparent/VertexLit"
    // 强制投射阴影
    FallBack "VertexLit"
}
