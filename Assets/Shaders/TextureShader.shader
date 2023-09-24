Shader "Custom/TextureShader"
{
    Properties
    {
        _Color ("Color Tint",Color) = (1,1,1,1)
        _Gloss("Glosse",Range(0.01,200)) = 1
        _Specular("Specular",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            float _Gloss;
            fixed4 _Specular;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 worldPos : POSITION1;
                float2 uv : TEXCOORD;
            };

            v2f vert(appdata_base base){
                v2f o;
                o.pos = UnityObjectToClipPos(base.vertex);
                o.worldNormal = UnityObjectToWorldNormal(base.normal);
                o.uv = TRANSFORM_TEX(base.texcoord,_MainTex);
                o.worldPos = mul(unity_WorldToObject,base.vertex);

                return o;
            }

            fixed4 frag(v2f i ):SV_TARGET{
                // 纹理漫反射颜色 = 纹理采样 * 纹理着色
                fixed4 albedo = tex2D(_MainTex,i.uv)* _Color;

                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 ambient = unity_AmbientSky*albedo;

                fixed4 diffuse = _LightColor0 * albedo * saturate(dot(i.worldNormal.xyz,lightDir.xyz));

                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 halfDir = normalize(viewDir+lightDir);
                fixed4 specular = _LightColor0 * _Specular * pow(dot(i.worldNormal,halfDir),_Gloss);

                fixed4 color = ambient + diffuse + specular;
                return color;
            }


            
            ENDCG
        }
    }
}
