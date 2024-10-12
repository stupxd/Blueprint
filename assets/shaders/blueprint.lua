return [[#if __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
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


float hue(float s, float t, float h)
{
	float hs = mod(h, 1.)*6.;
	if (hs < 1.) return (t-s) * hs + s;
	if (hs < 3.) return t;
	if (hs < 4.) return (t-s) * (4.-hs) + s;
	return s;
}

vec4 RGB(vec4 c)
{
	if (c.y < 0.0001)
		return vec4(vec3(c.z), c.a);

	float t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	float s = 2.0 * c.z - t;
	return vec4(hue(s,t,c.x + 1./3.), hue(s,t,c.x), hue(s,t,c.x - 1./3.), c.w);
}

vec4 HSL(vec4 c)
{
	float low = min(c.r, min(c.g, c.b));
	float high = max(c.r, max(c.g, c.b));
	float delta = high - low;
	float sum = high+low;

	vec4 hsl = vec4(.0, .0, .5 * sum, c.a);
	if (delta == .0)
		return hsl;

	hsl.y = (hsl.z < .5) ? delta / sum : delta / (2.0 - sum);

	if (high == c.r)
		hsl.x = (c.g - c.b) / delta;
	else if (high == c.g)
		hsl.x = (c.b - c.r) / delta + 2.0;
	else
		hsl.x = (c.r - c.g) / delta + 4.0;

	hsl.x = mod(hsl.x / 6., 1.);
	return hsl;
}

//  Function from Iñigo Quiles
//  www.iquilezles.org/www/articles/functions/functions.htm
float parabola( float x, float k ){
    return pow( 4.0*x*(1.0-x), k );
}

vec4 custom(float saturation, float normalized_lightness) {
	// max lightness = 98/100
	// min lightness = 86/100

	float min_light = 69.;

	float custom_lightness = min_light/100. + normalized_lightness * (98. - min_light)/100.;

	vec4 hslResult = vec4(
		226./360., // balatro blue hue
		1.,//0.55 + smoothstep(0., 0.85, saturation) * 0.15, 
		custom_lightness,
		1.
	);

	return hslResult;
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 tex = Texel(texture, texture_coords);

	vec4 hsl = HSL(tex);

	vec3 border = vec3(1., 1., 1.);
	vec3 lightest = vec3(0.776, 0.824, 0.988); // blueprint joker outline

	//vec3 background_line = vec3(0.490, 0.576, 0.886);
	vec3 background = vec3(0.294, 0.412, 0.812);

	vec3 darkest = vec3(0.243, 0.376, 0.831); // blueprint hat and smile`

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
		// This sucks ass
		//value = 1. - parabola(value,expo);
		//tex.rgb = (1. - value) * lightest + value * darkest;

		tex.rgb = RGB(custom(hsl.y, value)).xyz;
	} else if (mode <= 4.) {
		// This sucks ass
		//value = 1. - parabola(value,expo);
		//tex.rgb = (1. - value) * lightest + value * darkest;

		//tex.rgb = RGB(custom(hsl.xyz), value).xyz;
	} else {
		tex.rgb = palette(value, vec3(0.5095,0.6000,0.9095), vec3(0.2665,0.2240,0.0785), vec3(.5,.5,.5), vec3(0.0,0.0,0.0));
	}
	
	return tex;
}
]]
