#pragma language glsl3

#if __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

float greyscale(vec4 col) {
    return 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
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

vec4 effect( vec4 colour, sampler2D jokers_sampler, vec2 texture_coords, vec2 screen_coords )
{
    vec4 col = texture(jokers_sampler, texture_coords);
	
	return vec4(vec3(greyscale(col)), col.a);
}
