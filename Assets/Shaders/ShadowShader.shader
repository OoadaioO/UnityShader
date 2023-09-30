
Shader "Custom/ShadowShader"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Glosse",Range(0,200)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags  {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase


            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"


            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos: TEXCOORD;
                float3 worldNormal : TEXCOORD1; 
                SHADOW_COORDS(2)
            };

            fixed4 _Specular;
            fixed4 _Diffuse;
            fixed _Gloss;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = unity_AmbientSky.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,lightDir));

                fixed3 viewDir = normalize(UnityWorldToViewPos(i.worldPos));
                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
                
                // fixed atten = 1.0;
                //fixed shadow= SHADOW_ATTENUATION(i);
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 color = ambient + (diffuse + specular) * atten;
                return fixed4(color,1);
            }
            ENDCG
        }

        Pass
        {
            Tags  {"LightMode" = "ForwardAdd"}

            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd


            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos: TEXCOORD;
                float3 worldNormal : TEXCOORD1; 
            };

            fixed4 _Specular;
            fixed4 _Diffuse;
            fixed _Gloss;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,lightDir));

                fixed3 viewDir = normalize(UnityWorldToViewPos(i.worldPos));
                fixed3 halfDir = normalize(viewDir + lightDir);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                fixed3 color = diffuse + specular;
                
                return fixed4(color*atten,1);
            }
            ENDCG
        }
        
    }

    Fallback "Specular"
}
