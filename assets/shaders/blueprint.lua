return [[#if __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

extern bool inverted;
extern PRECISION float lightness_offset;

// cosine based palette, 4 vec3 params
vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d )
{
    return a + b*cos( 6.283185*(c*t+d) );
}

float lightness(vec4 c)
{
	float low = min(c.r, min(c.g, c.b));
	float high = max(c.r, max(c.g, c.b));
	float delta = high - low;
	float sum = high+low;

	return .5 * sum;
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 tex = Texel(texture, texture_coords);

	// 62, 96, 212 (darkest blue) ---- 198, 210, 252 (lightest blue)
	//tex.rgb = palette(inverted? lightness(tex) : .5+lightness(tex), vec3(0.5095,0.6000,0.9095), vec3(0.2665,0.2240,0.0785), vec3(.5,.5,.5), vec3(0.0,0.0,0.0));
	tex.rgb = palette(smoothstep(lightness_offset, 1., inverted? lightness(tex) : 1.+lightness(tex)), vec3(0.5095,0.6000,0.9095), vec3(0.2665,0.2240,0.0785), vec3(.5,.5,.5), vec3(0.0,0.0,0.0));
	
	return tex;
}
]]
