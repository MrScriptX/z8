#version 450

layout(set = 1, binding = 0) uniform MaterialData{   
	vec4 color_factors;
} material_data;

layout(set = 0, binding = 0) uniform SceneData {   
    mat4 view;
    mat4 proj;
    mat4 viewproj;
    vec4 ambient_color;
    vec4 sunlight_direction; // w = sun intensity
    vec4 sunlight_color;
    float time;
} scene_data;

layout(location = 0) in vec3 frag_normal;
layout(location = 1) in vec2 frag_uv;
layout(location = 2) in vec4 in_color;

layout(location = 0) out vec4 out_color;

void main() {
    vec3 normal = normalize(frag_normal);
    vec3 lightDir = normalize(scene_data.sunlight_direction.xyz);
    
    // Simple Lambertian diffuse
    float NdotL = max(dot(normal, lightDir), 0.0);
    
    // Lighting contribution
    vec3 ambient = scene_data.ambient_color.rgb;
    vec3 diffuse = scene_data.sunlight_color.rgb * NdotL * scene_data.sunlight_direction.w;
    
    vec3 base_color = in_color.xyz;
    float alpha = in_color.w;
    
    vec3 final_color = base_color * (ambient + diffuse);

    // Optional: Gamma correction
    // final_color = pow(final_color, vec3(1.0 / 2.2));

    out_color = vec4(final_color, alpha);
}
