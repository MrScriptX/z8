layout(set = 0, binding = 0) uniform  SceneData{   
	mat4 view;
	mat4 proj;
	mat4 viewproj;
	vec4 ambientColor;
	vec4 sunlightDirection; //w for sun power
	vec4 sunlightColor;
} sceneData;

layout(set = 1, binding = 0) uniform MaterialData{   
	vec4 color_factors;
} materialData;

layout(set = 1, binding = 1) uniform sampler2D colorTex;