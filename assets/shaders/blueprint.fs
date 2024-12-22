#if __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

extern bool inverted;
extern PRECISION float lightness_offset;
// 1 = linear
// 2 = sin
// 3 = exponent
extern PRECISION float mode;
extern PRECISION float expo;

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

//  Function from Iñigo Quiles
//  www.iquilezles.org/www/articles/functions/functions.htm
float parabola( float x, float k ){
    return pow( 4.0*x*(1.0-x), k );
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 tex = Texel(texture, texture_coords);

	vec3 lightest = vec3(0.776, 0.824, 0.988);
	vec3 darkest = vec3(0.243, 0.376, 0.831);

	// 62, 96, 212 (darkest blue) ---- 198, 210, 252 (lightest blue)
	//tex.rgb = palette(smoothstep(min_lightness, 1., .5 + hsl.z), vec3(0.5095,0.6000,0.9095), vec3(0.2665,0.2240,0.0785), vec3(.5,.5,.5), vec3(0.0,0.0,0.0));
	float value = smoothstep(lightness_offset, 1., lightness(tex));
	if (inverted) {
		value = 1. - value;
	}
	if (mode <= 1.) {
		tex.rgb = (1. - value) * lightest + value * darkest;
	} else if (mode <= 2.) {
		value = pow(value, expo);
		tex.rgb = (1. - value) * lightest + value * darkest;
	} else if (mode <= 3.) {
		value = 1. - parabola(value,expo);
		tex.rgb = (1. - value) * lightest + value * darkest;
	} else {
		tex.rgb = palette(value, vec3(0.5095,0.6000,0.9095), vec3(0.2665,0.2240,0.0785), vec3(.5,.5,.5), vec3(0.0,0.0,0.0));
	}
	
	return tex;
}
