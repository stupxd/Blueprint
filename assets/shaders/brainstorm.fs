#pragma language glsl3

#if __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

vec4 greyscale(vec4 col) {
    return vec4(0);
}

vec4 gaussian_blur(sampler2D jokers_sampler, ivec2 texture_coords) {
    return vec4(0);
}

vec2 sobel_filter(sampler2D jokers_sampler, ivec2 texture_coords) {
    return vec2(0);
}

vec4 canny_edges(sampler2D jokers_sampler, ivec2 texture_coords) {
    return vec4(0);
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 tex = Texel(texture, texture_coords);
	
	return vec4(0.9, 0.1, 0.3, tex.a);
}
