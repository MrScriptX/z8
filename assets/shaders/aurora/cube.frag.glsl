#version 450

layout(set = 1, binding = 0) uniform MaterialData{   
	vec4 color_factors;
} material_data;

layout(location = 0) in vec3 fragNormal;
layout(location = 1) in vec2 fragUV;

layout(location = 0) out vec4 outColor;

void main() {
    vec3 color = fragNormal * 0.5 + 0.5; // Simple shading based on normal
    outColor = vec4(color, 1.0);
}
