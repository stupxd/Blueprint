#pragma language glsl3

#if __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

#define blurAmount 1

float greyscale(vec4 col) {
    return 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
}

float gaussian_blur(sampler2D jokers_sampler, ivec2 texture_coords) {
	float col = 0.0;
    float total = 0.0;
    for (int x = -blurAmount; x <= blurAmount; x++) {
        for (int y = -blurAmount; y <= blurAmount; y++) {
            vec2 offset = vec2(float(x), float(y));
            float factor;
            if (blurAmount == 0)
                factor = 1.0;
            else {
                factor = exp(-dot(offset, offset) / float(blurAmount * blurAmount));
            }
            col += greyscale(texelFetch(jokers_sampler, ivec2(texture_coords + offset), 0)) * factor;
            total += factor;
        }
    }
    col /= total;
	return col;
}

#define sobel_kernelLength 6

vec3 sobel_kernelx[sobel_kernelLength] = vec3[sobel_kernelLength] (
    vec3(-1, -1, -1),
    vec3(-1, 0, -2),
    vec3(-1, 1, -1),
    vec3(1, -1, 1),
    vec3(1, 0, 2),
    vec3(1, 1, 1)
);

vec3 sobel_kernely[sobel_kernelLength] = vec3[sobel_kernelLength] (
    vec3(-1, -1, -1),
    vec3(0, -1, -2),
    vec3(1, -1, -1),
    vec3(-1, 1, 1),
    vec3(0, 1, 2),
    vec3(1, 1, 1)
);

vec2 sobel_filter(sampler2D jokers_sampler, ivec2 texture_coords) {
    vec2 d = vec2(0);
    for (int i = 0; i < sobel_kernelLength; i++) {
        d.x += gaussian_blur(jokers_sampler, ivec2(texture_coords + sobel_kernelx[i].xy)) * sobel_kernelx[i].z;
        d.y += gaussian_blur(jokers_sampler, ivec2(texture_coords + sobel_kernely[i].xy)) * sobel_kernely[i].z;
    }
    return d;
}

#define pi 3.14159265359

float canny_edges(sampler2D jokers_sampler, ivec2 texture_coords) {
    vec2 d = sobel_filter(jokers_sampler, texture_coords);
    float g = length(d);
    float t = atan(d.y / d.x);
    
    // determine where to sample from the direction of the gradient
    ivec2 offset1;
    ivec2 offset2;
    if (t < -0.375 * pi) {
        offset1 = ivec2(0, -1);
        offset2 = ivec2(0, 1);
    } else if (t < -0.125 * pi) {
        offset1 = ivec2(1, -1);
        offset2 = ivec2(-1, 1);
    } else if (t < 0.125 * pi) {
        offset1 = ivec2(-1, 0);
        offset2 = ivec2(1, 0);
    }
     else if (t < 0.375 * pi) {
        offset1 = ivec2(-1, -1);
        offset2 = ivec2(1, 1);
    } else {
        offset1 = ivec2(0, -1);
        offset2 = ivec2(0, 1);
    }
    // sample
    float g1 = length(sobel_filter(jokers_sampler, texture_coords + offset1));
    float g2 = length(sobel_filter(jokers_sampler, texture_coords + offset2));
    // if this is a local maximum
    if (g1 < g && g2 < g) {
        return g;
    } else {
        return 0.0;
    }
}

vec4 mapcol(float v) {
    if (v > 0.75) {
        return vec4(0, 0, 1, 0.4);
    }
    else if (v > 0.5) {
        return vec4(1, 0, 0, 0.4);
    } else {
        return vec4(0, 0, 0, 0);
    }
}

vec4 effect( vec4 colour, sampler2D jokers_sampler, vec2 texture_coords, vec2 screen_coords )
{
    // float col = greyscale(texture(jokers_sampler, texture_coords));

	ivec2 absolute_texture_coords = ivec2(texture_coords * textureSize(jokers_sampler, 0));
    // float col = gaussian_blur(jokers_sampler, absolute_texture_coords);
    // vec2 d = sobel_filter(jokers_sampler, absolute_texture_coords);
    float canny = canny_edges(jokers_sampler, absolute_texture_coords);

    vec4 cannycol = mapcol(canny);
    // if (fc.x % 71 < 5 || fc.x % 71 >= 66) {
    //     cannycol = vec4(0, 0, 0, 0);
    // }
    // if (fc.y % 95 < 5 || fc.y % 95 >= 90) {
    //     cannycol = vec4(0, 0, 0, 0);
    // }
	
	return texelFetch(jokers_sampler, absolute_texture_coords, 0);
	// return texture(jokers_sampler, texture_coords);
}
