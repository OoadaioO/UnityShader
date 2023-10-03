Shader "Custom/FresleShader"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Cubemap("Cubemap",Cube) = "_Skybox" {}
        _FresnelScale("Fresnel Scale",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        LOD 100

        Pass
        {

            Tags {"LightMode"="ForwardBase"}
            
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldPos:TEXCOORD0;
                fixed3 worldNormal:TEXCOORD1;
                fixed3 worldRefDir:TEXCOORD2;
                fixed3 worldViewDir:TEXCOORD3;
                SHADOW_COORDS(4)
            };

            samplerCUBE _Cubemap;
            fixed _FresnelScale;
            fixed3 _Diffuse;


            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefDir = reflect(-normalize(o.worldViewDir),normalize(o.worldNormal));

                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = unity_AmbientSky.xyz;

                fixed3 diffuse = _LightColor0.xyz * _Diffuse * saturate(dot(worldNormal,worldLightDir));

                fixed fresnel = _FresnelScale +(1-_FresnelScale)*pow((1-dot(normalize(i.worldViewDir),worldNormal)),5);

                fixed3 reflection = texCUBE(_Cubemap,i.worldRefDir);

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos)

                fixed3 color = ambient + lerp(diffuse,reflection,fresnel)*atten;
                
                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
}
