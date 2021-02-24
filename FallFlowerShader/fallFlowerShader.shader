Shader "Custom/fallFlowerShader"
{
    Properties
    {
        _BaseColor ("BaseColor", Color) = (1,1,1,1)
		_FlowerColor ("FlowerColor", Color) = (0,0,0,0)
		_FallSpeed("FallSpeed",range(0,1)) = 0.4
		_RotationSpeed("RotationSpeed",range(0,1)) = 0.4
		_Size("Size",range(1,10)) = 5
		_FlowerSize("FlowerSize",range(0,1)) = 1.0
		_Threshold("Threshold",range(0,1)) = 0.5
		_Random("Randam do", range(1,3)) = 2.1
		_GradColor("GradColor", Color) = (1,1,1,1)
    
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

		Pass{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		//ランダムノイズ発生器
		float rand(float2 co) {
			return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
		}

		v2f vert(appdata v) { //vertexシェーダー
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			return o;
		}


		//プロパティ変数初期化
		fixed4 _BaseColor;
		fixed4 _FlowerColor;
		float _RotationSpeed;
		float _FallSpeed;
		float _Size;
		float _FlowerSize;
		float _Threshold;
		float _Random;
		fixed4 _GradColor;

		
		fixed4 frag (v2f i) :SV_Target //fragmentシェーダー
		{
			float2 uv = (i.uv-0.5)*2.0; //uvがオブジェクトの真ん中に行くように移動

			uv *= _Size; //uvをn倍することで，結果1つぶんの花のサイズが小さくなってたくさん表示される

			float xpoint = -uv.x + _Time.y * _FallSpeed;
			float ypoint = -uv.y + _Time.y * _FallSpeed * 0.75f; //倍率を少し減らして45度よりも斜めにスライドするようにする
			float2 center = float2(floor(xpoint), floor(ypoint));
			uv = float2(frac(xpoint)*2.0 - 1.0, frac(ypoint)*2.0 - 1.0);
			

			float theta = atan2(uv.y, uv.x); //現在の位置(uv)から，アークタンジェントで角度thetaを求める
			theta += _Time.y*_RotationSpeed; //角度そのものを時間で回転させることで，花をくるくる回らせる
			float flowerLine = sin(3.0f*theta)+0.25f*sin(9.0f*theta); //正葉曲線で角度thetaにおける原点からの距離rを求める(極座標)
			flowerLine *= _FlowerSize; //曲線に倍率を書ければ花のサイズを小さく出来る(大きくしようとすると見切れるので無理)
			flowerLine *= rand(center);
			
			fixed4 backColorGrad = lerp(_BaseColor, _GradColor, i.uv.x*0.2f); //グラデーション背景色

			//花の中心から現在の位置(uv)までの距離が，正葉曲線(r)のラインよりも内側にある時は花の色を付ける．大きい場合は背景色を付ける．
			if(step(abs(length(uv)),abs(flowerLine))==1){
				//return _FlowerColor; //そのまま描画

				//rand(center)が閾値以上になったときだけ描画
				//return (step(rand(center*_Size), _Threshold) == 1) ? _BaseColor : _FlowerColor;
				return (step(rand(center*_Size), _Threshold) == 1) ? backColorGrad+0.05f : _FlowerColor;
				//return (step(rand(center*_Size*_Random), _Threshold) == 1) ? _BaseColor : _FlowerColor;
				//return (step(fBm(center), _Threshold) == 1) ? _BaseColor : _FlowerColor;
			}
			//return _BaseColor;
			return backColorGrad;

			//UVスクロール
			//i.uv.x = i.uv.x + _FallSpeed * _Time;
			//i.uv.y = i.uv.y + _FallSpeed * _Time;
		}

		ENDCG
		}
    }
}
