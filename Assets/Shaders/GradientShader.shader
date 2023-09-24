Shader "Custom/GradientShader"
{
    Properties
    {
        _Color ("Color",Color) = (1,1,1,1)
        _Specular ("Specular",Color) = (1,1,1,1)
        _Gloss ("Gloss",Range(0.01,200)) = 1
        _RampTex("RampTex",2D) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{ "LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            fixed _Gloss;
            sampler2D _RampTex;
            fixed4 _RampTex_ST;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal:POSITION1;
                float3 worldPos:POSITION2;
            };


            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityViewToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord,_RampTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float3 worldNormal = normalize(i.worldNormal);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 halfDir = normalize(viewDir+lightDir);

                fixed4 ambient = unity_AmbientSky;

                fixed halfLambert = 0.5*dot(worldNormal,lightDir)+0.5;
                fixed4 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)) * _Color;
                fixed4 diffuse = _LightColor0 * diffuseColor;

                
                fixed4 specular = _LightColor0 * _Specular * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                fixed4 color = ambient + diffuse + specular;
                return fixed4(color.rgb,1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
