
#define PI2 6.28318530718
#define pi 3.14159265358979
#define halfpi (pi * 0.5)
#define oneoverpi (1.0 / pi)
 

float rand(float2 co){
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float rand(float n){
    return frac(sin(n)*753.5453123);
}

float rand_range(float seed, float low, float high) {
	return low + (high - low) * rand(seed);
}

float3 rand_color(float seed, float3 col, float3 variation) {
    return float3(
        col.x + rand_range(seed,-variation.x, +variation.x),
        col.y + rand_range(seed,-variation.y, +variation.y),
        col.z + rand_range(seed,-variation.z, +variation.z));
}

float noise(in float2 x )
{
    float2 p = floor(x);
    float2 f = frac(x);
    f = f*f*(3.0-2.0*f);
	
    float n = p.x + p.y*157.0;
    return lerp(lerp( rand(n+  0.0), rand(n+  1.0),f.x),
                   lerp( rand(n+157.0), rand(n+158.0),f.x),f.y);
}

float softEdge(float edge, float amt){
    return clamp(1.0 / (clamp(edge, 1.0/amt, 1.0)*amt), 0.,1.);
}

float3 particleColor(float2 uv, float2 pos, float radius, float3 color) {
	float dist = radius / distance(uv, pos);
    return color * pow(dist, 3.0);
}

// particle is described by a superellipse
// https://en.wikipedia.org/wiki/Superellipse
float3 particleColor2(float2 uv, float2 pos, float radius, float3 color) {
    pos = abs(uv - pos) / radius;
    pos = pow(pos, .5);
    return color * clamp(1 - (pos.x + pos.y),0,1);
}

float4 permute(in float4 x)
{
    return fmod ((34.0 * x + 1.0) * x , 289.0);   
}

float2 celluar2x2( float2 P) {
    
    float pp =  7.0; 
 	float K = 1.0/pp;
	float K2 = 0.5/pp;
	float jitter = 0.8 ; // jitter 1.0 makes F1 wrong more often
	float2 Pi = fmod(floor(P), 289.0) ;
	float2 Pf = frac(P);
	float4 Pfx = Pf.x + float4(-0.5, -1.5, -0.5, -1.5);
	float4 Pfy = Pf.y + float4(-0.5, -0.5, -1.5, -1.5);
	float4 p = permute (Pi.x + float4(0.0 , 1.0, 0.0, 1.0));
	p = permute (p + Pi.y + float4(0.0 , 0.0, 1.0, 1.0));
	float4 ox = fmod(p, pp) * K + K2;
	float4 oy = fmod(floor(p * K) ,pp) * K + K2;
	float4 dx = Pfx + jitter * ox;
	float4 dy = Pfy + jitter * oy;
	float4 d = dx * dx + dy * dy; // distances squared
	// Cheat and pick only F1 for the return value
	d.xy = min(d.xy, d.zw);
	d.x = min(d.x, d.y);
	return d.xx; // F1 duplicated , F2 not computed
 
    
}

float4 DrawAParticleSet(float2 uv, float size, float3 colorTint, float dampSpeed ){
   float aCellLenght = size;
   float randomSeed01 = rand(floor (uv /aCellLenght));
   float randomSeed02 = rand(floor (uv /aCellLenght) + 5.0);
   float randomSeed03 = rand(floor (uv /aCellLenght) + 10.0);
    
   //float circleLenght =abs(sin(_Time.y * randomSeed03 + randomSeed02))  * randomSeed01 * aCellLenght;
   float circleLenght =abs(sin(_Time.y * dampSpeed)) * aCellLenght;
   
   float jitterFreedom = 0.5 - circleLenght;
   float jitterAmountX =  jitterFreedom * (randomSeed03 *2.0 -1.0);
   float jitterAmounty =  jitterFreedom * (randomSeed01 *2.0 -1.0); 
   float2 coord =  frac(uv / aCellLenght);
    
    
   coord -= 0.5;
   float z = 0.0;
   float3 toReturn; 
   for(int i=0; i < 3; i++) {
       z += 0.015 * celluar2x2(coord + _Time.y * 0.1).x  /*abs(sin(_Time.y * randomSeed01 + randomSeed01))*/;
		coord += z;
		toReturn[i] = 1.0 - smoothstep(circleLenght- 30.5/_ScreenParams.y,
                                       circleLenght, distance(coord, float2(jitterAmountX, jitterAmounty)));
	}
   float4 color = float4(0,0,0,0);
   toReturn = lerp(color.xyz, colorTint *toReturn, length(toReturn));
   color = float4(toReturn.xyz, 0.1);
   return color;
}

float4 DrawParticles1(float2 uv,int nParticles,float softness, float4 colorTint, float size, float speed, float duration){
    float2 tc = uv;
    //float aspect = _ScreenParams.x / _ScreenParams.y;
	//uv.x *= aspect;
    
    float4 fragColor = float4(0,0,0,0);
    
    //float4 tex = texture(iChannel0, tc);

    for(int i = 0; i< nParticles; i++){
        float r  = rand(i);
        float r2 = rand(i+nParticles);
        float r3 = rand(i+nParticles*2);
        float pSize = r * size * (1 - clamp(sin((_Time.y + r3 * halfpi) / duration), 0, 1) * step(0.01,duration));
 
        tc.x -= sin(_Time.y * speed +r*30.0)*r;
        tc.y -= cos(_Time.y * speed +r*40.0)*r2*0.5;
        float l = length(tc - float2(0.5, 0.5)) - pSize;
        
        //tc -= float2(0.5, 0.5)*1.0;
        //tc = tc * 2.0 - 1.0;
        //tc *= 1.0;
        //tc = tc * 0.5 + 0.5;
        
        //l = dot(tc, tc);
        //l = softEdge(l, softness);
        //l /= float(nParticles)*0.15;
        float gap = step(0.1, colorTint.rgb);
        float3 randColor = float3(r,r2,r3);
        
        float4 orb = float4(1,1,1, softEdge(l, softness) * colorTint.a * step(0.001, pSize));
        orb.rgb = gap * colorTint.rgb + (1 - gap) * randColor;
        
        orb.rgb *= 1.5; // boost it
        
        fragColor = lerp(fragColor, orb, orb.a);
        
    }
    return fragColor;
}

/*
float4 DrawParticles2(float2 uv,int nParticles,float softness, float4 colorTint, float size, float speed, float duration){
    float2 tc = uv;
    float4 fragColor = float4(0,0,0,0);
    
    for(int i = 0; i< nParticles; i++){
        float t =  i * 0.05;
    	//float2 pos = float2(16.0 * pow(sin(t), 3.0), 
        //                13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t));//pow((y * y + x * x - 1.0), 3.0) - x * x * y * y * y);
        //pos *= 0.06;
        //pos.y *= 1.1;
        //pos.y += 0.15;
        float2 pos = float2(1,1);
        pos.x = rand(t);
        pos.y = rand(t + 0.2);
        
        
        fragColor.rgb += particleColor(uv, 
                                 pos, 
                                 size * (0.5 + abs(sin(4.0*_Time.y * 0.2)*0.5)),// * (n_particles - i), 
                                 colorTint.rgb) * colorTint.a;
    }
    return fragColor;
}*/

float3 DrawParticles3(float2 uv,int nParticles,float softness, float4 colorTint, float size, float speed, float duration){
    float2 tc = float2(0,0);
    
    float3 fragColor = float3(0,0,0);
    float durationGap = step(0.01,duration);
    float sizeGap = size * durationGap;
    //float gap = step(0.1, colorTint.rgb);
    float pColor = 2 * colorTint;
    for(int i = 0; i< nParticles; i++){
        float r  = rand(i);
        float r2 = rand(i+nParticles);
        float r3 = rand(i+nParticles*2);
        float pSize = sizeGap * (1 - clamp(sin((_Time.y + r2 * pi) / duration), 0, 1));
        
        if(speed <=0.01){
            tc.x = r;
            tc.y = r3;
        }else{
            tc.x = sin(_Time.y * speed +r*30.0)*r;
            tc.y = cos(_Time.y * speed +r*40.0)*r2;
        }
        
        //float3 pColor =  gap * colorTint.rgb + (1 - gap) *float3(r,r2,r3);
        
        fragColor += particleColor2(uv,tc, pSize,pColor);  
    }
    
    return fragColor;
}

 