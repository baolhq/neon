extern number threshold=1.;

extern number canvas_w=600;
extern number canvas_h=800;

const number offset_1=1.5;
const number offset_2=3.5;

const number alpha_0=.23;
const number alpha_1=.32;
const number alpha_2=.07;

float luminance(vec3 color)
{
    // numbers make 'true grey' on most monitors, apparently
    return((.212671*color.r)+(.715160*color.g)+(.072169*color.b));
}

vec4 effect(vec4 color,Image tex,vec2 tc,vec2 sc)
{
    vec4 texcolor=Texel(tex,tc);
    
    // Vertical blur
    vec3 tc_v=texcolor.rgb*alpha_0;
    
    tc_v+=Texel(tex,tc+vec2(0.,offset_1)/canvas_h).rgb*alpha_1;
    tc_v+=Texel(tex,tc-vec2(0.,offset_1)/canvas_h).rgb*alpha_1;
    
    tc_v+=Texel(tex,tc+vec2(0.,offset_2)/canvas_h).rgb*alpha_2;
    tc_v+=Texel(tex,tc-vec2(0.,offset_2)/canvas_h).rgb*alpha_2;
    
    // Horizontal blur
    vec3 tc_h=texcolor.rgb*alpha_0;
    
    tc_h+=Texel(tex,tc+vec2(offset_1,0.)/canvas_w).rgb*alpha_1;
    tc_h+=Texel(tex,tc-vec2(offset_1,0.)/canvas_w).rgb*alpha_1;
    
    tc_h+=Texel(tex,tc+vec2(offset_2,0.)/canvas_w).rgb*alpha_2;
    tc_h+=Texel(tex,tc-vec2(offset_2,0.)/canvas_w).rgb*alpha_2;
    
    // Smooth
    vec3 extract=smoothstep(threshold*.7,threshold,luminance(texcolor.rgb))*texcolor.rgb;
    return vec4(extract+tc_v*.8+tc_h*.8,1.);
}
