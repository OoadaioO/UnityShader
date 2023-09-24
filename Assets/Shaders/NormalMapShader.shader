Shader "Custom/NormalMapShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color Tint",Color) = (1,1,1,1)
        _BumpMap ("BumpMap",2D) = "white"{}
        _BumpScale ("Bump Scale",Range(0,1)) = 1
        _Gloss ("Gloss",Range(0.01,200)) = 1
        _Specular("Specular Color" ,Color) = (1,1,1,1)

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
            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            struct v2f
            {
                float4 texcoord : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 lightDir : POSITION1;
                float3 viewDir : POSITION2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Color;
            fixed _Gloss;
            fixed4 _Specular;
            float _BumpScale;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
                o.texcoord.zw = TRANSFORM_TEX(v.texcoord.xy,_BumpMap);
                TANGENT_SPACE_ROTATION;

                // 模型空间光照，转换到切线空间
                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                // 模型空间视角，转换到切线空间
                o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 tangLightDir = normalize(i.lightDir);
                float3 tangViewDir = normalize(i.viewDir);

                float4 packedNormal = tex2D(_BumpMap,i.texcoord.zw);
                fixed3 tangNormal = UnpackNormal(packedNormal);
                tangNormal.xy *= _BumpScale;
                tangNormal.z = sqrt(1-saturate(dot(tangNormal.xy,tangNormal.xy)));

                float3 halfDir = normalize(tangViewDir+tangLightDir);

                fixed4 albedo = tex2D(_MainTex,i.texcoord.xy);

                fixed4 ambient = unity_AmbientSky * albedo;
                
                fixed4 diffuse = _LightColor0 * albedo * saturate(dot(tangNormal,tangLightDir));

                fixed4 specular = _LightColor0 * _Specular * pow(saturate(dot(tangNormal,halfDir)),_Gloss);

                fixed4 color = ambient + diffuse+specular;
                return fixed4(color.rgb,1);
            }
            ENDCG
        }
    }
}
