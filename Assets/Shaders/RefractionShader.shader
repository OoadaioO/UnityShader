Shader "Custom/RefractionShader"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _Cubemap ("Cubemap", Cube) = "_Skybox" {}
        _RefractionFraction("Refactino Fraction",Range(0,1)) = 1
        _RefractionColor("Refraction Color",Color) = (1,1,1,1)
        _RefractionRatio("Refraction Ratio" ,Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            
            
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
                fixed3 worldPos:TEXCOORD0;
                fixed3 worldNormal:TEXCOORD1;
                fixed3 worldViewDir:TEXCOORD2;
                float3 worldRefDir:TEXCOORD3;
                SHADOW_COORDS(4)
            };

            samplerCUBE _Cubemap;
            fixed4 _Color;
            fixed4 _RefractionColor;
            fixed _RefractionFraction;
            fixed _RefractionRatio;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefDir = refract(-normalize(o.worldViewDir),normalize(o.worldNormal),_RefractionRatio);
                UnityObjectToViewPos()
                UnityWorldToViewPos()
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = _LightColor0.rgb;


                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 refraction = texCUBE(_Cubemap,i.worldRefDir).rgb * _RefractionColor.rgb;

                
                
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal , worldLightDir));
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 color = ambient + lerp(diffuse,refraction,_RefractionFraction)*atten;
                return fixed4(color,1);
            }
            ENDCG
        }
    }

    FallBack "Reflective/VertexLit"
}
