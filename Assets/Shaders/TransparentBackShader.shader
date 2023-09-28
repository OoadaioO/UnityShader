Shader "Custom/TransparentBackShader"
{
    Properties
    {
        _Color ("Color",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale("Alpha Scale",Range(0,1))=0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        LOD 100
         Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex:SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed3 worldNormal:TEXCOORD1;
                fixed3 worldPos: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;
            fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord , _MainTex);
                o.worldNormal = mul(v.normal,unity_WorldToObject).xyz;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 m = tex2D(_MainTex,i.uv);

                
                fixed3 ambient = unity_AmbientSky.xyz;
                fixed3 diffuse = _LightColor0 * m * saturate(dot(worldNormal,lightDir))*_Color; 
                fixed3 color =  ambient + diffuse;
                return fixed4(color.rgb,m.a*_AlphaScale);
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex:SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed3 worldNormal:TEXCOORD1;
                fixed3 worldPos: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;
            fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord , _MainTex);
                o.worldNormal = mul(v.normal,unity_WorldToObject).xyz;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 m = tex2D(_MainTex,i.uv);

                
                fixed3 ambient = unity_AmbientSky.xyz;
                fixed3 diffuse = _LightColor0 * m * saturate(dot(worldNormal,lightDir))*_Color; 
                fixed3 color =  ambient + diffuse;
                return fixed4(color.rgb,m.a*_AlphaScale);
            }
            ENDCG
        }
    }
}
