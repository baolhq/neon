extern number time;

vec4 effect(vec4 color,Image tex,vec2 tc,vec2 sc)
{
    float wave=sin(tc.y*50.+time*4.)*.001;// smaller distortion
    vec2 distortedCoords=vec2(tc.x+wave,tc.y);
    return Texel(tex,distortedCoords)*color;
}
