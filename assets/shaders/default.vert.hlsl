#pragma version 6.0

cbuffer UniformBufferObject : register(b0) {
    float3 position;
    float4x4 model;
    float4x4 view;
    float4x4 proj;
};

struct Input {
    float3 position : POSITION;
    float3 normal : NORMAL;
    float3 color : COLOR;
    float2 texCoord : TEXCOORD0;
};

struct Output {
    float4 position: SV_POSITION;
    float3 fragNormal : NORMAL;
    float3 fragPosition : POSITION;
    float3 fragColor : COLOR;
    float2 fragTexCoord : TEXCOORD0;
    float3 viewPos : TEXCOORD1;
};

Output main(Input input) {
    Output output;

    output.position = proj * view * model * float4(input.position, 1.0);
    
    output.fragPosition = float4(model * float4(input.position, 1.0));
    output.fragNormal = input.normal;
    // INPUTS(float3): color
    output.fragColor = input.color;
    output.fragTexCoord = input.texCoord;
    output.viewPos = position;

    return output;
}
