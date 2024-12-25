#if __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

// extern int dpi;
extern vec3 greyscale_weights;
extern int blur_amount;
extern ivec2 card_size;
extern ivec2 margin;
extern vec4 blue_low;
extern vec4 blue_high;
extern vec4 red_low;
extern vec4 red_high;
extern float blue_threshold;
extern float red_threshold;
// extern bool floating;
extern vec2 texture_size;

float greyscale(vec4 col) {
    return dot(greyscale_weights, col.rgb);
}

vec4 myTexelFetch(Image s, ivec2 c) {
    // return texelFetch(s, c * dpi, l);
    vec2 uv = (vec2(c) + vec2(0.5)) / texture_size;
    return Texel(s, uv);
}

float gaussian_blur(Image jokers_sampler, ivec2 texture_coords) {
	float col = 0.0;
    float total = 0.0;
    for (int x = -blur_amount; x <= blur_amount; x++) {
        for (int y = -blur_amount; y <= blur_amount; y++) {
            ivec2 offset = ivec2(x, y);
            float factor;
            if (blur_amount == 0)
                factor = 1.0;
            else {
                factor = exp(-dot(offset, offset) / float(blur_amount * blur_amount));
            }
            col += greyscale(myTexelFetch(jokers_sampler, texture_coords + offset)) * factor;
            total += factor;
        }
    }
    col /= total;
	return col;
}

#define sobel_kernel_length 6

vec3 sobel_kernelx[sobel_kernel_length] = vec3[sobel_kernel_length] (
    vec3(-1, -1, -1),
    vec3(-1, 0, -2),
    vec3(-1, 1, -1),
    vec3(1, -1, 1),
    vec3(1, 0, 2),
    vec3(1, 1, 1)
);

vec3 sobel_kernely[sobel_kernel_length] = vec3[sobel_kernel_length] (
    vec3(-1, -1, -1),
    vec3(0, -1, -2),
    vec3(1, -1, -1),
    vec3(-1, 1, 1),
    vec3(0, 1, 2),
    vec3(1, 1, 1)
);

vec2 sobel_filter(Image jokers_sampler, ivec2 texture_coords) {
    vec2 d = vec2(0);
    for (int i = 0; i < sobel_kernel_length; i++) {
        d.x += gaussian_blur(jokers_sampler, texture_coords + ivec2(sobel_kernelx[i].xy)) * sobel_kernelx[i].z;
        d.y += gaussian_blur(jokers_sampler, texture_coords + ivec2(sobel_kernely[i].xy)) * sobel_kernely[i].z;
    }
    return d;
}

#define pi 3.14159265359

float canny_edges(Image jokers_sampler, ivec2 texture_coords) {
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

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}


vec4 mapcol(float v, ivec2 coords) {
    if (v > blue_threshold) {
        return mix(blue_low, blue_high, hash12(coords));
    }
    else if (v > red_threshold) {
        return mix(red_low, red_high, hash12(coords));
    } else {
        return vec4(0, 0, 0, 0);
    }
}

// bool is_floating_edge(Image jokers_sampler, ivec2 texture_coords) {
//     if (myTexelFetch(jokers_sampler, texture_coords, 0).a < 1.0) {
//         return false;
//     }
//     for (int x = -1; x <= 1; x++) {
//         for (int y = -1; y <= 1; y++) {
//             if (myTexelFetch(jokers_sampler, texture_coords + ivec2(x, y), 0).a < 1.0) {
//                 return true;
//             }
//         }
//     }
//     return false;
// }

vec4 effect( vec4 colour, Image jokers_sampler, vec2 texture_coords, vec2 screen_coords )
{
    // float col = greyscale(texture(jokers_sampler, texture_coords));

	ivec2 absolute_texture_coords = ivec2(texture_coords * texture_size);
    // float col = gaussian_blur(jokers_sampler, absolute_texture_coords);
    // vec2 d = sobel_filter(jokers_sampler, absolute_texture_coords);
    float canny = canny_edges(jokers_sampler, absolute_texture_coords);
    // if (floating && is_floating_edge(jokers_sampler, absolute_texture_coords)) {
        // canny = 100.0;
    // }

    vec4 cannycol = mapcol(canny, absolute_texture_coords);
    if (mod(absolute_texture_coords.x, card_size.x) < margin.x || mod(absolute_texture_coords.x, card_size.x) >= card_size.x - margin.x) {
        cannycol = vec4(0, 0, 0, 0);
    }
    if (mod(absolute_texture_coords.y, card_size.y) < margin.y || mod(absolute_texture_coords.y, card_size.y) >= card_size.y - margin.y) {
        cannycol = vec4(0, 0, 0, 0);
    }
    
    // if (floating) {
    return cannycol;
        // return vec4(cannycol.rgb, min(cannycol.a, myTexelFetch(jokers_sampler, absolute_texture_coords, 0).a));
    // } else {
    //     return cannycol;
    // }
	// return texelFetch(jokers_sampler, absolute_texture_coords, 0);
	// return texture(jokers_sampler, texture_coords);
}
