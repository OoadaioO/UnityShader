// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shadertoy/Template" { 
    Properties{
        iMouse ("Mouse Pos", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100, 100, 0, 0)
    }

    CGINCLUDE    
    #include "UnityCG.cginc"   
    #pragma target 3.0      

    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define mat2 float2x2
    #define mat3 float3x3
    #define mat4 float4x4
    #define iGlobalTime _Time.y
    #define mod fmod
    #define mix lerp
    #define fract frac
    #define texture2D tex2D
    #define iResolution _ScreenParams
    #define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

    #define PI2 6.28318530718
    #define pi 3.14159265358979
    #define halfpi (pi * 0.5)
    #define oneoverpi (1.0 / pi)

    fixed4 iMouse;
    sampler2D iChannel0;
    fixed4 iChannelResolution0;

    struct v2f {    
        float4 pos : SV_POSITION;    
        float4 scrPos : TEXCOORD0;   
    };              

    v2f vert(appdata_base v) {  
        v2f o;
        o.pos = UnityObjectToClipPos (v.vertex);
        o.scrPos = ComputeScreenPos(o.pos);
        return o;
    }  

    vec4 main(vec2 fragCoord);

    fixed4 frag(v2f _iParam) : COLOR0 { 
        vec2 fragCoord = gl_FragCoord;
        return main(gl_FragCoord);
    }  

    vec3 palette( float t ) {
        vec3 a = vec3(0.5, 0.5, 0.5);
        vec3 b = vec3(0.5, 0.5, 0.5);
        vec3 c = vec3(1.0, 1.0, 1.0);
        vec3 d = vec3(0.263,0.416,0.557);

        return a + b*cos( 6.28318*(c*t+d) );
    }


    vec4 main(vec2 fragCoord) {
        
        vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
        vec2 uv0 = uv;
        vec3 finalColor = vec3(0,0,0);
        
        for (float i = 0.0; i < 4.0; i++) {
            uv = fract(uv * 1.5) - 0.5;

            float d = length(uv) * exp(-length(uv0));

            vec3 col = palette(length(uv0) + i*.4 + _Time.y*.4);

            d = sin(d*8. + _Time.y)/8.;
            d = abs(d);

            d = pow(0.01 / d, 1.2);

            finalColor += col * d;
        }
        
        vec4 fragColor = vec4(finalColor, 1.0);
        return fragColor;
    }

    

    ENDCG    

    SubShader {    
        Pass {    
            CGPROGRAM    

            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            

            ENDCG    
        }    
    }     
    FallBack Off    
}
