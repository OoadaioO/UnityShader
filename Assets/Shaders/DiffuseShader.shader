Shader "Unlit/DiffuseShader"
{
    Properties
    {
        _Diffuse("Diffuse Color",Color) = (1,1,1,1)
        _Specular("Specular Color",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(0.01,100)) = 1
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

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 worldPos : POSITION1;
                float3 worldNormal :NORMAL;
            };


            v2f vert (appdata_base base)
            {
                v2f o;
                // 模型空间 -> 裁剪空间
                o.vertex = UnityObjectToClipPos(base.vertex);
                // 模型空间 -> 世界空间
                o.worldPos = mul(unity_ObjectToWorld,base.vertex);
                // 模型空间 -> 世界空间 法线向量(已经标准化)
                o.worldNormal = UnityObjectToWorldNormal(base.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 环境光
                fixed4 ambient = unity_AmbientSky;
                // 漫反射 = 光源颜色 * 材质颜色 * max(0,法线向量·光线向量)
                fixed4 diffuse = _LightColor0 * _Diffuse * saturate(dot(i.worldNormal.xyz,_WorldSpaceLightPos0.xyz));
                
                // Phone高光 = 光源颜色 * 材质颜色 * max(0,视角向量·反射向量)^{Gloss}
                fixed3 v = normalize(UnityWorldSpaceViewDir(i.worldPos)); // 视角向量
                fixed3 r = normalize(reflect(-_WorldSpaceLightPos0.xyz,i.worldNormal)); // 反射向量
                fixed4 specularPhong = _LightColor0 * _Specular * pow(saturate(dot(v,r)),_Gloss);

                // 光源方向
                fixed3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // h=(v+l)/|v+l|
                fixed3 h = normalize(v+l);
               
                
                // Blinn高光 = 光源颜色 * 材质颜色 * max(0,n·h)^{Gloss}
                fixed4 specularBlinn = _LightColor0 * _Specular * pow(saturate(dot(i.worldNormal,h)),_Gloss);

                
                //fixed4 color = ambient + diffuse +specularPhong;
                fixed4 color = ambient + diffuse +specularBlinn;
                return color;
            }
            ENDCG
        }
    }
}
