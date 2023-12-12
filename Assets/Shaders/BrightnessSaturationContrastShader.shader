Shader "Custom/BrightnessSaturationContrastShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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



            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed _Brightness;
            fixed _Saturation;
            fixed _Contrast;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 color = tex2D(_MainTex, i.uv);
                
                // apply brightness
                fixed3 col = color.rgb * _Brightness;

                // apply saturation
                fixed luminance = 0.0627 + 0.183 * col.r + 0.614 * col.g + 0.062 * col.b;
                fixed3 luminanceColor = fixed3(luminance,luminance,luminance);

                col = lerp(luminanceColor,col.rgb,_Saturation);

                fixed3 avgColor = fixed3(0.5,0.5,0.5);

                col = lerp(avgColor,col,_Contrast);

                return fixed4(col.rgb,1.0);
            }
            ENDCG
        }
    }
}
