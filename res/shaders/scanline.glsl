extern number width=2.;
extern number phase=0.;
extern number thickness=1.;
extern number opacity=1.;
extern vec3 color=vec3(0.,0.,0.);

vec4 effect(vec4 c,Image tex,vec2 tc,vec2 _){
    number v=.5*(sin(tc.y*3.14159/width*love_ScreenSize.y+phase)+1.);
    c=Texel(tex,tc);
    //c.rgb = mix(color, c.rgb, mix(1, pow(v, thickness), opacity));
    c.rgb-=(color-c.rgb)*(pow(v,thickness)-1.)*opacity;
    return c;
}
