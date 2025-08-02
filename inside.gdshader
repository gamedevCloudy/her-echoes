shader_type canvas_item;

// 👇 This is required in Godot 4 to use screen texture!
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float red_boost_power : hint_range(0,3) = 1.5;
uniform float contrast : hint_range(0,2) = 1.1;
uniform float vignette_strength : hint_range(0,1) = 0.5;

void fragment() {
    vec4 col = texture(SCREEN_TEXTURE, UV);

    // Desaturate using luminance
    float lum = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    vec3 base = vec3(lum);

    // Boost reds
    float mask = smoothstep(0.2, 0.6, col.r);
    vec3 red_accent = vec3(col.r, 0.0, 0.0) * red_boost_power;
    vec3 mixed = mix(base, red_accent, mask);

    // Apply contrast
    mixed = ((mixed - 0.5) * contrast) + 0.5;

    // Vignette
    vec2 uv = UV * 2.0 - 1.0;
    float vignette = 1.0 - clamp(length(uv) / sqrt(2.0), 0.0, 1.0);
    mixed *= mix(1.0, vignette, vignette_strength);

    COLOR = vec4(mixed, col.a);
}
