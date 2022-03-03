// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Flora Flash"
{
	Properties
	{
		_FlashUV("Flash UV", Vector) = (0.5,0.7,0,0)
		_FlashRadius("Flash Radius", Float) = 500
		_StartAnimationTime("Start Animation Time", Float) = 0
		_FlashDuration("Flash Duration", Float) = 2
		_FlashColor("Flash Color", Color) = (1,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float4 screenPos;
		};

		uniform float4 _FlashColor;
		uniform float2 _FlashUV;
		uniform float _FlashRadius;
		uniform float _StartAnimationTime;
		uniform float _FlashDuration;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 hsvTorgb81 = RGBToHSV( _FlashColor.rgb );
			float2 appendResult33 = (float2(_ScreenParams.x , _ScreenParams.y));
			float2 temp_output_32_0 = ( _FlashUV * appendResult33 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 appendResult34 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
			float2 temp_output_35_0 = ( appendResult33 * appendResult34 );
			float t45 = ( ( _Time.y - _StartAnimationTime ) / _FlashDuration );
			float lerpResult23 = lerp( 0.0 , _FlashRadius , t45);
			float clampResult10 = clamp( ( distance( temp_output_32_0 , temp_output_35_0 ) / lerpResult23 ) , 0.0 , 1.0 );
			float distance47 = clampResult10;
			float lerpResult84 = lerp( 0.5 , hsvTorgb81.y , distance47);
			float3 hsvTorgb85 = HSVToRGB( float3(hsvTorgb81.x,lerpResult84,hsvTorgb81.z) );
			o.Emission = hsvTorgb85;
			float2 normalizeResult60 = normalize( ( temp_output_35_0 - temp_output_32_0 ) );
			float2 break64 = normalizeResult60;
			float angle62 = ( atan2( break64.x , break64.y ) + UNITY_PI );
			float lerpResult80 = lerp( 0.5 , 1.5 , ( angle62 / ( 2.0 * UNITY_PI ) ));
			float lerpResult56 = lerp( ( 4.0 * UNITY_PI ) , ( 50.0 * UNITY_PI ) , pow( t45 , 2.0 ));
			o.Alpha = pow( ( ( 1.0 - clampResult10 ) * (0.0 + (sin( ( lerpResult80 * ( distance47 * lerpResult56 ) ) ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) , 0.5 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
187;295;1438;846;1058.833;524.6988;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;40;-3322.82,-951.1948;Inherit;False;2471.847;823.1868;Calculate Flash Point Distznce;22;26;1;33;32;5;31;34;35;9;24;23;8;10;47;59;60;61;62;64;65;78;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-3122.68,80.58549;Inherit;False;1103.183;409.0968;Flash Clock;6;16;13;15;12;44;45;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;31;-2171.558,-511.5468;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenParams;26;-2012.492,-740.286;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;13;-2806.747,96.7321;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2830.68,228.5855;Inherit;False;Property;_StartAnimationTime;Start Animation Time;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-1965.145,-503.4968;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-1787.142,-710.2261;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;1;-1805.33,-901.1947;Inherit;False;Property;_FlashUV;Flash UV;0;0;Create;True;0;0;0;False;0;False;0.5,0.7;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1701.176,-497.4615;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1600.753,-700.5563;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2850.497,354.6823;Inherit;False;Property;_FlashDuration;Flash Duration;3;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;44;-2598.667,159.8988;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;59;-1475.304,-784.8378;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-2388.191,225.9325;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-2246.667,239.8988;Inherit;False;t;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;60;-1374.158,-878.5512;Inherit;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1986.503,-338.6337;Inherit;False;Property;_FlashRadius;Flash Radius;1;0;Create;True;0;0;0;False;0;False;500;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1572.839,-268.0533;Inherit;False;45;t;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;64;-1315.203,-762.7329;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DistanceOpNode;5;-1396.35,-510.5591;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;65;-1175.203,-790.7329;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;79;-1153.833,-687.6988;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;23;-1360.63,-348.0058;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-1033.833,-793.6988;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;-1183.127,-430.0182;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;10;-1021.972,-436.8234;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-2039.595,476.0402;Inherit;False;45;t;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-886.7261,-715.694;Inherit;False;angle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-1750.942,-16.90147;Inherit;False;62;angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;53;-1948.167,247.466;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;58;-1856.737,473.1835;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1099.582,-623.9781;Inherit;False;distance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;57;-1965.31,354.61;Inherit;False;1;0;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;70;-1762.718,60.05733;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-1705.306,207.4649;Inherit;False;47;distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-1679.591,320.3238;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;69;-1532.942,20.09853;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1459.588,296.0378;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;80;-1373.833,74.30121;Inherit;False;3;0;FLOAT;0.5;False;1;FLOAT;1.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1208.942,221.0985;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;51;-1133.869,384.6109;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-608.8104,-507.0985;Inherit;False;Property;_FlashColor;Flash Color;4;0;Create;True;0;0;0;False;0;False;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RGBToHSVNode;81;-381.8328,-477.6988;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;82;-745.8328,-255.6988;Inherit;False;47;distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;11;-639.237,155.2732;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;54;-922.4374,356.0389;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-445.286,213.1794;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;84;-375.8328,-207.6988;Inherit;False;3;0;FLOAT;0.5;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-1141.012,-887.1248;Inherit;False;dir;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;42;-233.8495,192.7697;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;85;-153.8328,-177.6988;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;156.8329,-106.3919;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Flora Flash;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;31;1
WireConnection;34;1;31;2
WireConnection;33;0;26;1
WireConnection;33;1;26;2
WireConnection;35;0;33;0
WireConnection;35;1;34;0
WireConnection;32;0;1;0
WireConnection;32;1;33;0
WireConnection;44;0;13;0
WireConnection;44;1;12;0
WireConnection;59;0;35;0
WireConnection;59;1;32;0
WireConnection;15;0;44;0
WireConnection;15;1;16;0
WireConnection;45;0;15;0
WireConnection;60;0;59;0
WireConnection;64;0;60;0
WireConnection;5;0;32;0
WireConnection;5;1;35;0
WireConnection;65;0;64;0
WireConnection;65;1;64;1
WireConnection;23;1;9;0
WireConnection;23;2;24;0
WireConnection;78;0;65;0
WireConnection;78;1;79;0
WireConnection;8;0;5;0
WireConnection;8;1;23;0
WireConnection;10;0;8;0
WireConnection;62;0;78;0
WireConnection;58;0;46;0
WireConnection;47;0;10;0
WireConnection;56;0;53;0
WireConnection;56;1;57;0
WireConnection;56;2;58;0
WireConnection;69;0;66;0
WireConnection;69;1;70;0
WireConnection;52;0;49;0
WireConnection;52;1;56;0
WireConnection;80;2;69;0
WireConnection;68;0;80;0
WireConnection;68;1;52;0
WireConnection;51;0;68;0
WireConnection;81;0;37;0
WireConnection;11;0;10;0
WireConnection;54;0;51;0
WireConnection;55;0;11;0
WireConnection;55;1;54;0
WireConnection;84;1;81;2
WireConnection;84;2;82;0
WireConnection;61;0;60;0
WireConnection;42;0;55;0
WireConnection;85;0;81;1
WireConnection;85;1;84;0
WireConnection;85;2;81;3
WireConnection;0;2;85;0
WireConnection;0;9;42;0
ASEEND*/
//CHKSM=934B40AA0E2DDF85637D9E66B4EA407470B7D66C