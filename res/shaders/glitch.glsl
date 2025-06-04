extern number time;
extern number glitch=.3;

vec3 spectrum_offset(float t){
    float lo=step(t,.5);
    float hi=1.-lo;
    float w=clamp(1.-abs(2.*clamp((t-1./6.)/(5./6.-1./6.),0.,1.)-1.),0.,1.);
    float neg_w=1.-w;
    vec3 ret=vec3(lo,1.,hi)*vec3(neg_w,w,neg_w);
    return pow(ret,vec3(1./2.2));
}

float rand(vec2 n){
    return fract(sin(dot(n,vec2(12.9898,78.233)))*43758.5453);
}

float mytrunc(float x,float num_levels){
    return floor(x*num_levels)/num_levels;
}

vec2 mytrunc(vec2 x,float num_levels){
    return floor(x*num_levels)/num_levels;
}

vec4 effect(vec4 color,Image tex,vec2 texCoord,vec2 screenCoord){
    vec2 uv=texCoord;
    float t=mod(time,32.)/220.;
    float GLITCH=glitch;
    
    float rnd0=rand(mytrunc(vec2(t,t),6.));
    float r0=clamp((1.-GLITCH)*.7+rnd0,0.,1.);
    float rnd1=rand(vec2(mytrunc(uv.x,10.*r0),t));
    float r1=1.-max(0.,((.5-.5*GLITCH+rnd1)<1.?(.5-.5*GLITCH+rnd1):.9999999));
    float r2=clamp(rand(vec2(mytrunc(uv.y,40.*r1),t)),0.,1.);
    float r3=(1.-clamp(rand(vec2(mytrunc(uv.y,10.*r0),t))+.8,0.,1.))-.1;
    
    float pxrnd=rand(uv+t);
    float ofs=.05*r2*GLITCH*(rnd0<.5?1.:-1.);
    ofs+=.5*pxrnd*ofs;
    
    const int NUM_SAMPLES=20;
    float RCP_NUM_SAMPLES_F=1./float(NUM_SAMPLES);
    vec4 sum=vec4(0.);
    vec3 wsum=vec3(0.);
    
    for(int i=0;i<NUM_SAMPLES;++i){
        float tt=float(i)*RCP_NUM_SAMPLES_F;
        float x=clamp(uv.x+ofs*tt,0.,1.);
        vec4 samplecol=Texel(tex,vec2(x,uv.y));
        vec3 s=spectrum_offset(tt);
        samplecol.rgb*=s;
        sum+=samplecol;
        wsum+=s;
    }
    
    sum.rgb/=wsum;
    sum.a*=RCP_NUM_SAMPLES_F;
    
    return vec4(sum.rgb,sum.a)*color;
}
