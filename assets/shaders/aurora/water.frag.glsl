#version 450

layout(set = 1, binding = 0) uniform MaterialData{   
	vec4 color_factors;
} material_data;

layout(location = 0) in vec3 fragNormal;
layout(location = 1) in vec2 fragUV;

layout(location = 0) out vec4 outColor;

void main() {
    // Base water color (you can make this dynamic)
    vec3 waterColor = vec3(0.0, 0.3, 0.6);

    // modulate alpha (wave edge shimmer)
    const uint fragWave = 2;
    float alpha = 0.5 + 0.5 * fragWave;

    // fade near surface (simulate depth fog)
    float fade = clamp(dot(normalize(fragNormal), vec3(0.0, 1.0, 0.0)), 0.2, 1.0);

    outColor = vec4(waterColor * fade, alpha * 0.6); // tune transparency
}
