Shader "Unlit/NormalMapWrodShader"
{
    Properties
    {
        _Color("Tint Color",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpScale("Bunmp Scale",Range(0,1)) = 1
        _BumpMap("Bump Map",2D) = "white" {}
        _Gloss("Glosse",Range(0.01,200)) = 1
        _Specular("Specular",Color) = (1,1,1,1)
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


            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 w2t0:TEXCOORD1;
                fixed4 w2t1:TEXCOORD2;
                fixed4 w2t2:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed _Gloss;
            fixed _BumpScale;
            fixed4 _Specular;
            

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy= TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord.xy,_BumpMap);

                fixed3 worldPos = mul(unity_WorldToObject,v.vertex).xyz;
                fixed3 worldNormal = normalize(mul(unity_WorldToObject,v.normal));
                fixed3 worldTangent = normalize(mul(unity_WorldToObject,v.tangent.xyz));
                fixed3 worldBinormal = cross(worldTangent,worldNormal) * v.tangent.w;
                o.w2t0 = fixed4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.w2t1 = fixed4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.w2t2 = fixed4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 顶点位置
                fixed3 worldPos = fixed3(i.w2t0.w,i.w2t1.w,i.w2t2.w);


                // 切线空间法线
                fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
                fixed3 bump = UnpackNormal(packedNormal);
                bump.xy *= _BumpScale;
                bump.z = 1-sqrt(dot(bump.xy,bump.xy));

                fixed3x3 mword = fixed3x3(fixed3(i.w2t0.x,i.w2t1.x,i.w2t2.x),fixed3(i.w2t0.y,i.w2t1.y,i.w2t2.y),fixed3(i.w2t0.z,i.w2t1.z,i.w2t2.z));

                // 切线空间法线，转变成世界空间法线
                //fixed3 newNormal = normalize(fixed3(dot(i.w2t0.xyz,bump),dot(i.w2t1.xyz,bump),dot(i.w2t2.xyz,bump)));
                fixed3 newNormal = normalize(mul(transpose(mword),bump));

                fixed4 albedo = tex2D(_MainTex,i.uv.xy);
                fixed4 ambient = unity_AmbientSky * albedo;

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed4 diffuse = _LightColor0 * albedo * saturate(dot(newNormal,lightDir));
                fixed3 halfDir = normalize(lightDir+viewDir);
                fixed4 specular = _LightColor0 * albedo * pow(saturate(dot(newNormal,halfDir)),_Gloss);
                
                fixed4 color =ambient + diffuse + specular;
                return color;
            }
            ENDCG
        }
    }
}
