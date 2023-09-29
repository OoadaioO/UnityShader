// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Unlit/FowardLightShader"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(0,200)) = 1 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal:POSITION1;
                float3 worldPos:POSITION2;
                SHADOW_COORDS(1)
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            fixed _Gloss;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                
                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 ambient = unity_AmbientSky;

                fixed4 diffuse = _LightColor0*_Diffuse*saturate(dot(worldNormal,lightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(viewDir+lightDir);
                fixed4 specular =_LightColor0* _Specular * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                fixed atten = 1.0;
                fixed shadow= SHADOW_ATTENUATION(i);

                fixed4 color = ambient + (diffuse + specular)*atten*shadow;
                return color;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal:POSITION1;
                float3 worldPos:POSITION2;
                
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            fixed _Gloss;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));


                fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,lightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(viewDir+lightDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
                
                
                fixed3 color = (diffuse + specular);
                color.rgb += Shade4PointLights(unity_4LightPosX0,
                unity_4LightPosY0,
                unity_4LightPosZ0,
                unity_LightColor[0],
                unity_LightColor[1],
                unity_LightColor[2],
                unity_LightColor[3],
                unity_4LightAtten0,
                i.worldPos,
                worldNormal);

                return fixed4(color,1);
            }
            ENDCG
        }

        Pass{
            Tags{"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f{
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v){
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                SHADOW_CASTER_FRAGMENT(i);
            }

            ENDCG
        }

    }
    //Fallback "Specular"
    
}



