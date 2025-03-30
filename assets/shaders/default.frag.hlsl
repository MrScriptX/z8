#pragma target 6.0

struct Input {
    float3 fragNormal : NORMAL;
    float4 fragPosition: SV_POSITION;
    float3 fragColor: COLOR;
};

float4 main(Input input) : SV_TARGET
{
    float ambientStrength = 0.100000001490116119384765625;
    float3 ambient = float3(1.0) * ambientStrength;
    float3 light_pos = float3(0.0);
    float3 light_dir = normalize(light_pos - input.fragPosition);
    float diff = max(dot(input.fragNormal, light_dir), 0.0);
    float3 diffuse = float3(1.0) * diff;
    float3 viewDir = normalize(float3(0.0) - input.fragPosition);
    float3 reflectDir = reflect(-light_dir, input.fragNormal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 256.0);
    float3 specular = float3(1.0) * (1.0 * spec);
    float3 result = ((ambient + diffuse) + specular) * input.fragColor;

    return float4(result, 1.0);
}
