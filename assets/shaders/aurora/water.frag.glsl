#version 450

layout(set = 1, binding = 0) uniform MaterialData{   
	vec4 color_factors;
} material_data;

layout(set = 0, binding = 0) uniform SceneData {   
    mat4 view;
    mat4 proj;
    mat4 viewproj;
    mat4 shadow_viewproj[4]; // for shadow mapping
    vec4 ambient_color;
    vec4 sunlight_direction; // w = sun intensity
    vec4 sunlight_color;
    float time;
} scene_data;

layout(set = 0, binding = 1) uniform sampler2DArray shadow_map;

layout(location = 0) in vec3 frag_normal;
layout(location = 1) in vec2 frag_uv;
layout(location = 2) in float frag_wave;
layout(location = 3) in float time;

layout(location = 0) out vec4 outColor;

void main() {
    // Base water color
    vec3 water_color = vec3(0.0, 0.3, 0.6);

    // modulate alpha (wave edge shimmer)
    float alpha = 0.5 + 0.5 * frag_wave;

    // fade near surface (simulate depth fog)
    float fade = clamp(dot(normalize(frag_normal), vec3(0.0, 1.0, 0.0)), 0.2, 1.0);

    outColor = vec4(water_color * fade, alpha * 0.8);
}
