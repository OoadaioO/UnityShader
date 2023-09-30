Shader "Custom/AlphaTestWithShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(1,200)) = 1
        _CutOff("CutOff",Range(0,1)) = 0
        _Color("Diffuse",Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" "IgnoreProjector"="True" }

        LOD 100

        Pass
        {

            Tags { "LightMode" = "ForwardBase"}

            Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                fixed3 worldPos: POSITION1;
                fixed3 worldNormal:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            fixed _Gloss;
            fixed _CutOff;
            fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal).xyz;
                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 text = tex2D(_MainTex,i.uv);

                clip(text.a - _CutOff);
                
                fixed4 albedo = text * _Color;
                
                fixed4 ambient = unity_AmbientSky * albedo;

                fixed4 diffuse = _LightColor0 * albedo * saturate(dot(worldNormal,lightDir));
                
                fixed3 viewDir = normalize(UnityWorldToViewPos(i.worldPos));
                fixed3 halfDir = normalize(lightDir+viewDir);
                fixed4 specular = _LightColor0 * _Specular * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                fixed4 color = ambient + (diffuse + specular)*atten;
                return color;
            }
            ENDCG
        }

       
    }

    FallBack "Transparent/Cutout/VertexLit"
}
