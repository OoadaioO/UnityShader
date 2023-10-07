Shader "Custom/GrabPassRefraction"
{
    Properties
    {
        _MainTex("Main Texture",2D) = "white"{}
        _Bumpmap("BumpMap",2D) = "white" {}
        _Cubemap("CubeMap",Cube) = "_Skybox" {}
        _Distribution("Distribution",Range(0,100)) = 10
        _FractionAmount("Fraction Amount",Range(0,1))  = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Opaque" }
        LOD 100
        GrabPass { "_RefractionTex"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"



            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 scPos:POSITION1;
                fixed4 otw0:TEXCOORD1;
                fixed4 otw1:TEXCOORD2;
                fixed4 otw2:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bumpmap;
            float4 _Bumpmap_ST;
            samplerCUBE _Cubemap;
            fixed _Distribution;
            fixed _FractionAmount;
            sampler2D _RefractionTex;
            fixed4 _RefractionTex_TexelSize;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_Bumpmap);
                o.scPos = ComputeGrabScreenPos(o.pos);

                fixed3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 worldTangent = normalize(mul(unity_ObjectToWorld,v.tangent));
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.otw0 = fixed4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.otw1 = fixed4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.otw2 = fixed4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);



                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldPos = fixed3(i.otw0.z,i.otw1.z,i.otw2.z);
                fixed3 worldViewDir  = normalize(UnityWorldSpaceViewDir(worldPos)); 

                fixed3 bump =UnpackNormal( tex2D(_Bumpmap,i.uv.zw));

                fixed2 offset = bump.xy * _Distribution * _RefractionTex_TexelSize.xy;
                fixed2 refrPos = i.scPos.xy + offset;
                
                fixed3 refrColor = tex2D(_RefractionTex, refrPos / i.scPos.w).rgb;

                bump = fixed3(dot(bump,i.otw0.xyz),dot(bump,i.otw1.xyz),dot(bump,i.otw2.xyz));
                
                fixed3 refDir = reflect(-worldViewDir,bump);
                fixed3 textColor = tex2D(_MainTex,i.uv.xy);
                fixed3 reflColor  = texCUBE(_Cubemap,refDir) * textColor;
                
                fixed3 color = reflColor * (1-_FractionAmount) + refrColor * _FractionAmount;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
