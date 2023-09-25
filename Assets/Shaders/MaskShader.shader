Shader "Custom/MaskShader"
{
    Properties
    {
        _Color ("Color Tint" , Color) = (1,1,1,1)
        _MainTex("Main Tex",2D) = "white" {}
        _BumpMap("Bump Map" ,2D) = "white" {}
        _BumpScale("Bump Scale",Range(0,1)) = 1
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(0,100)) = 1
        _SpecularMask("Specular Mask", 2D) = "white" {}
        _SpecularScale("Specular Scalke",Range(0,1)) = 1
        
    }


    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            fixed _Gloss;
            sampler2D _BumpMap;
            fixed4 _BumpMap_ST;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed _BumpScale;
            sampler2D _SpecularMask;
            fixed _SpecularScale;


            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 tangentLightDir:TEXCOORD0;
                fixed3 tangentViewDir:TEXCOORD1;
                fixed2 uv:TEXCOORD2;
            };


            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed4 worldPos = mul(unity_ObjectToWorld,v.vertex);

                fixed3 normal = normalize(v.normal);
                fixed3 tangent = normalize(v.tangent);
                fixed3 binormal = cross(normal,tangent) * v.tangent.w;
                fixed3x3 rotation = fixed3x3(tangent.xyz,binormal.xyz,normal.xyz);

                o.tangentLightDir = mul(rotation,ObjSpaceLightDir(worldPos));
                o.tangentViewDir = mul(rotation,ObjSpaceViewDir(v.vertex));

                o.uv.xy = TRANSFORM_TEX(v.texcoord,_BumpMap);


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex,i.uv.xy);
                
                fixed4 packedNormal = tex2D(_BumpMap,i.uv.xy);
                fixed3 bump = UnpackNormal(packedNormal);
                bump.xy *= _BumpScale;
                bump.z = sqrt(1-saturate(dot(bump.xy,bump.xy)));

                fixed3 lightDir = normalize(i.tangentLightDir);
                fixed3 viewDir = normalize(i.tangentViewDir);
                fixed3 normal = bump;

                fixed4 ambient = unity_AmbientSky * albedo;
                fixed4 diffuse = _LightColor0 *albedo * _Color * saturate(dot(normal,lightDir));

                
                fixed cmask = tex2D(_SpecularMask,i.uv.xy) * _SpecularScale;

                fixed3 halfDir = normalize(viewDir+lightDir);
                fixed4 specular = _LightColor0 * _Specular * pow(saturate(dot(normal,halfDir)),_Gloss) *cmask;

                fixed4 color = ambient + diffuse + specular;
                return color;
            }
            ENDCG
        }
    }
}
