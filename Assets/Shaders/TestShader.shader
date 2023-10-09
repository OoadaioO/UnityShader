Shader "Custom/TestShader"
{
    Properties
    {
        _MainColor("Main Color",Color) = (1,1,1,1)
        _SecondColor("Seconds Color",Color) = (1,1,1,1)
        _Offset("Offset",vector) = (0,0,0,0)
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
                float4 vertex : SV_POSITION;
            };

            fixed4 _SecondColor;
            fixed4 _Offset;


            v2f vert (appdata_base v)
            {
                v2f o;
                fixed3 move = mul(_Offset,UNITY_MATRIX_IT_MV).xyz;

                o.vertex = UnityObjectToClipPos(fixed4(v.vertex.xyz+move,v.vertex.w));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _SecondColor;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            fixed4 _MainColor;
            fixed4 _Offset;


            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _MainColor;
            }
            ENDCG
        }
    }
}
