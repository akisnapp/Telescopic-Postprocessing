// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Aaron Lanterman, July 22, 2021
// Modified example from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects

Shader "Hidden/Custom/AlexanderSnappStackShader"
{
    
    HLSLINCLUDE
        
        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);
        TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

        float _Speed;
        //sampler2D _MainTex;
        sampler2D _FadeTex;
        float4 _MainTex_ST;
        float _Radius;
        float _Horizontal;
        float _Vertical;
        float _RadiusSpeed;
        float4 _FadeColour;
        float4 _Offset;
        
        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float4 original = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
			float4 dn_enc = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, i.texcoord);
            // float4 d_enc = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord);            
            // float depth = Linear01Depth(d_enc);
            float depth = dot(float2(1.0, 1/255.0),dn_enc.zw);
            float3 n = DecodeViewNormalStereo(dn_enc);
			float3 display_n = 0.5 * (1 + n);

            //here
            float4 original_left = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - float2(1.0 / _ScreenParams.x,0));
            float4 original_right = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(1.0 / _ScreenParams.x,0));
            float4 original_up = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - float2(0,1.0 / _ScreenParams.y));
            float4 original_down = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(0,1.0 / _ScreenParams.y));
            float3 horiz_diff = original_left.rgb - original_right.rgb;
            float3 vert_diff = original_up.rgb - original_down.rgb;
            float3 outline = abs(horiz_diff) + abs(vert_diff);

            //here

            //telescope outline (aka the circle view thing)
            float4 fadeCol = _FadeColour * tex2D(_FadeTex, i.texcoord);
            float3 pos = float3((i.texcoord.x - _Offset.x - 0.5) / _Vertical,
                                (i.texcoord.y - _Offset.y - 0.5) / _Horizontal, 0);

            //more outline parameters
            float4 normalVal = float4(lerp(outline, original,0.5*(sin(original_left + original_right) + pos)), 1);
            //blur effect calculations
            float4 blur = original;
            float3 blurHorizontal = original.rgb;
            float3 blurVertical = original.rgb;

            float randOffsetHorizontal[] = { -1.5, -0.82, -0.12, 1.0, 1.67 };
            float randOffsetVertical[] = { -1.22, -0.974, -.1543, 0.34, 1.22 };

            float tempX = i.texcoord.x;
            float tempY = i.texcoord.y;
            for (int i = 0; i < 5; i++) {
                float horizontalOffset = randOffsetHorizontal[i] * pow(_ScreenParams.x, -1) * 1.5;
                float verticalOffset = randOffsetVertical[i] * pow(_ScreenParams.y, -1) * 1.5;
                blur += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, float2(tempX + horizontalOffset, tempY + verticalOffset));
            }
            blur = blur * 0.5; 
            
            if (length(pos) > (_Radius / 50)) {
                return fadeCol;
            } else {
                float4 newVal = float4(lerp(blur, float4(depth/100, depth/100, depth/100, 1), dn_enc.z * 0.55));
                return lerp(newVal, normalVal, 0.7);
            }
    		//return(float4(lerp(display_n,depth.xxx,0.5*(cos(_Speed * _Time.y) + 1)),1));
        }
        
        
    ENDHLSL

    
    SubShader {
        Cull Off ZWrite Off ZTest Always

        Pass {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
    


    
}
