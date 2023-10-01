Shader "Custom/ReflectionShader"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _Cubemap ("Refraction Cubemap", Cube) = "_Skybox" {}
        _ReflectionColor("Reflection Color",Color) = (1,1,1,1)
        _ReflectionFraction("Reflection Fraction",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

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
                fixed3 worldNormal:TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
                fixed3 worldViewDir:TEXCOORD2;
                fixed3 worldRefDir : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            fixed4 _ReflectionColor;
            fixed _ReflectionFraction;
            fixed4 _Color;
            fixed _ReflectRatio;

            samplerCUBE _Cubemap;



            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefDir = reflect(-normalize(o.worldViewDir),normalize(o.worldNormal));
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir =normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = unity_AmbientSky.rgb;

                fixed3 diffuse = _LightColor0.rgb * _Color * saturate(dot(worldNormal,worldLightDir));

                fixed3 reflection = texCUBE(_Cubemap,i.worldRefDir).rgb*_ReflectionColor.rgb;

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 color = ambient + lerp(diffuse,reflection,_ReflectionFraction)*atten;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
