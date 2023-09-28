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

                fixed4 ambient = unity_AmbientSky;

                fixed4 diffuse = _LightColor0*_Diffuse*saturate(dot(worldNormal,lightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(viewDir+lightDir);
                fixed4 specular =_LightColor0* _Specular * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                fixed atten = 1.0;

                fixed4 color = ambient + (diffuse + specular)*atten;
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

                //fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz-i.worldPos.xyz);
                #endif

                fixed4 ambient = unity_AmbientSky;

                fixed4 diffuse = _LightColor0*_Diffuse*saturate(dot(worldNormal,lightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(viewDir+lightDir);
                fixed4 specular = _LightColor0*_Specular * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed atten = 1.0;
                #else
                    #if defined(POINT)
                        fixed3 lightCoord = mul(unity_WorldToLight,fixed4(i.worldPos,1)).xyz;
                        fixed atten = UNITY_SAMPLE_TEX2D(unity_Lightmap,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #elif defined(SPOT)
                        fixed4 lightCoord = mul(unity_WorldToLight,fixed4(i.worldPos,1));
                        fixed atten = (lightCoord.z > 0) * UNITY_SAMPLE_TEX2D(unity_Lightmap,lightCoord.xy / lightCoord.w +0.5).w * UNITY_SAMPLE_TEX2D(unity_Lightmap,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #endif
                #endif

                fixed4 color = ambient + (diffuse + specular)*atten;
                return color;
            }
            ENDCG
        }
    }
}



