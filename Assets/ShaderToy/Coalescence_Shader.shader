
Shader "BJL/Coalescence"
	{

	Properties{
	//Properties
	}

	SubShader
	{
	Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

	Pass
	{
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

	struct VertexInput {
    fixed4 vertex : POSITION;
	fixed2 uv:TEXCOORD0;
    fixed4 tangent : TANGENT;
    fixed3 normal : NORMAL;
	//VertexInput
	};


	struct VertexOutput {
	fixed4 pos : SV_POSITION;
	fixed2 uv:TEXCOORD0;
	//VertexOutput
	};

	//Variables

	#define _Smooth(p,r,s) smoothstep(-s, s, p-(r))
#define PI 3.141592
#define TPI 6.2831
#define HPI 1.570796

fixed GetBias(fixed x,fixed bias)
{
  return (x / ((((1.0/bias) - 2.0)*(1.0 - x))+1.0));
}
fixed GetGain(fixed x,fixed gain)
{
  if(x < 0.5)
    return GetBias(x * 2.0,gain)/2.0;
  else
    return GetBias(x * 2.0 - 1.0,1.0 - gain)/2.0 + 0.5;
}

// from http://iquilezles.org/www/articles/smin/smin.htm
// polynomial smooth min (k = 0.1);
fixed smin( fixed a, fixed b, fixed k )
{
    fixed h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return lerp( b, a, h ) - k*h*(1.0-h);
}

fixed smax(fixed a, fixed b, fixed k)
{
    return (-smin(-a,-b,k));
}

fixed sclamp(fixed f,fixed k)
{
    return smin(1.,smax(0.,f,k),k);
}



fixed hex(fixed2 pos)
{
    const fixed corner = .015;
    fixed2 q = abs(pos);
	return smax(
        smax((q.x * 0.866025 +pos.y*0.5),q.y,corner),
        smax((q.x * 0.866025 -pos.y*0.5),q.y,corner),corner);
}

fixed hexRadiusFactor(fixed time)
{
    time *= 2.;
    fixed s = sclamp(sin(time )+.65,.25);
	
    return s;
}

void hexFest(inout fixed3 col,in fixed2 uv, in fixed time)
{
    fixed3 hexColor = fixed3(0.294,0.360,0.478);
    
    fixed a =- PI / 3.;
    fixed sa = sin(a);
    fixed ca = cos(a);
    uv = mul(uv, float2x2(sa,ca,ca,-sa));
    
     //hexagones
    fixed deltaTime = 1./8. * 1.2;
    fixed baseHexRadius = .1;
    fixed2 hexDelta = fixed2(.195,.21);
    
    fixed timeAccu = 1.;
    
    fixed rf,radius,f = 0.;
    
    
    
    //hex1
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv);
    f = _Smooth(radius,f,.0025);

    col = lerp(col,hexColor,f * rf);
    
    //hex2
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * fixed2(1.,.5));
    f = _Smooth(radius,f,.0025);

    col = lerp(col,hexColor,f * rf);
    
    //hex3
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * fixed2(1.,-.5));
    f = _Smooth(radius,f,.0025);

    col = lerp(col,hexColor,f * rf);
    
    //hex4
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * fixed2(.0,-1.));
    f = _Smooth(radius,f,.0025);

    col = lerp(col,hexColor,f * rf);
    
    //hex5
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * fixed2(-1.,-.5));
    f = _Smooth(radius,f,.0025);

    col = lerp(col,hexColor,f * rf);
    
    //hex6
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * fixed2(-1.,.5));
    f = _Smooth(radius,f,.0025);

    col = lerp(col,hexColor,f * rf);
    
    
    //hex7
    timeAccu += 1.;
    rf = hexRadiusFactor(time + deltaTime * timeAccu);
    radius = baseHexRadius * rf;
    
    f = hex(uv - hexDelta * fixed2(0.,1.));
    f = _Smooth(radius,f,.0025);

    col = lerp(col,hexColor,f * rf);
}


#define _Circle(l,r,ht,s) _Smooth(len,r-ht,s) - _Smooth(len,r+ht,s) 

void circleFest(inout fixed3 col,in fixed2 uv, in fixed time)
{
	fixed len = length(uv);
    fixed ang = atan2(uv.x,uv.y);
    
    fixed3 circleCol = fixed3(0.,0.,0.);
    
    fixed f = (_Circle(len,.45,.003,.013)) * .15;
    col = lerp(col,circleCol,f);
    
    time = -1.485 + time*2.;// * 2. + 1.4;
    
    fixed a = (ang + time) / TPI;
    a = (a - floor(a));
    
    f = (_Circle(len,.45,.006,.013)) *.05;
    
    fixed startTime = max(fmod(time + HPI,TPI),PI) + HPI;
    
    fixed start = sin(startTime) * .5 + .5;
    
    fixed endTime = min(fmod(time + HPI,TPI),PI) + HPI;
    
    fixed end = sin(endTime)*.5+.5;
    
    f *= step(a,1.-start) - step(a,end);
    col = lerp(col,circleCol,f*3.5);
    
    f = (_Circle(len,.45,.003,.013)) ;
    f *= step(a,.04 + sin(time) * .01) - step(a,0.);
   
    col = lerp(col,circleCol,f);
   
    f = (_Circle(len,.62,.003,.013)) ;
    col = lerp(col,circleCol,f*.25);
    
    f = (_Circle(len,.62,.003,.013)) ;
    
    time += 1.;
    time = GetGain(frac(time/TPI),.25) * TPI;
    a = (ang - time - 1.5) / TPI;
    a += sin(time) * .15;
    a = (a - floor(a)) ;
    //a = GetBias(a,.65);
    f *= step(a,.03 ) - step(a,0.);
    col = lerp(col,circleCol,f);
    
}
    




	VertexOutput vert (VertexInput v)
	{
	VertexOutput o;
	o.pos = UnityObjectToClipPos (v.vertex);
	o.uv = v.uv;
	//VertexFactory
	return o;
	}
	fixed4 frag(VertexOutput i) : SV_Target
	{
	
	fixed2 uv = (i.uv / 1) - fixed2(1 / 1 * .5,.5);
    uv *= 1.6;
    fixed3 uvMapper = pow(1.-length(uv*.25),.4);
    fixed3 col = fixed3(.1,.0,.4) + uvMapper;
    
    fixed time = _Time.y + 1.1;
    
    hexFest(col,uv,time);
    circleFest(col,uv,time);
   
    
	return fixed4(col,1.0);

	}
	ENDCG
	}
  }
}

