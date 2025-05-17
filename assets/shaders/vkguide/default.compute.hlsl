RWTexture2D<float4> image : register(u0); // image2D bound at set=0, binding=0

struct PushConstants
{
    float4 data1;
    float4 data2;
    float4 data3;
    float4 data4;
};

[[vk::push_constant]]
PushConstants pushConstants;

[numthreads(16, 16, 1)]
void main(uint3 DTid : SV_DispatchThreadID)
{
    int2 texelCoord = int2(DTid.xy);

    uint2 size;
    image.GetDimensions(size.x, size.y);

    float4 topColor = pushConstants.data1;
    float4 bottomColor = pushConstants.data2;

    if (texelCoord.x < size.x && texelCoord.y < size.y)
    {
        float blend = float(texelCoord.y) / float(size.y);
        float4 result = lerp(topColor, bottomColor, blend);
        image[texelCoord] = result;
    }
}
