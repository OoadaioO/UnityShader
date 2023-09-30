Shader "Custom/AlphaTestWithShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(1,200)) = 1
        _Cutoff("Cut Off",Range(0,1)) = 0.5
        _Color("Diffuse",Color) = (1,1,1,1)
    }

    SubShader
    {
        
        Tags{"Queue" = "AlphaTest" "IgnoreProjector"="True" "RenderType" = "TransparentCutout"}

        LOD 100

        Pass
        {

            Tags { "LightMode"="ForwardBase" }


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"


            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed3 worldNormal:TEXCOORD1;
                fixed3 worldPos: POSITION1;
                float4 pos : SV_POSITION;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            fixed _Gloss;
            fixed _Cutoff;
            fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

                
                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex,i.uv);

                clip(texColor.a - _Cutoff);
                
                fixed4 albedo = texColor * _Color;
                
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

        // 手动实现
        Pass{
            // 1. 声明 ShadowCaster LightMode
            Tags{"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 2. 设置阴影投射关键字
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;

            struct v2f{
                fixed2 uv:TEXCOORD1;
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v){
                v2f o;
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                
                fixed4 textColor = tex2D(_MainTex,i.uv);
                clip(textColor.a-_Cutoff);

                SHADOW_CASTER_FRAGMENT(i);
            }

            ENDCG
        }
        
    }

    //FallBack "Transparent/Cutout/VertexLit"
}
