RWTexture2D<float4> image : register(u0);

[numthreads(16, 16, 1)]
void main(uint3 dispatchThreadID : SV_DispatchThreadID, uint3 groupThreadID : SV_GroupThreadID, uint3 groupID : SV_GroupID)
{
    uint2 texelCoord = dispatchThreadID.xy;
    uint2 size;
    image.GetDimensions(size.x, size.y);

    if (texelCoord.x < size.x && texelCoord.y < size.y)
    {
        float4 color = float4(0.0, 0.0, 0.0, 1.0);

        if (groupThreadID.x != 0 && groupThreadID.y != 0)
        {
            color.x = float(texelCoord.x) / size.x;
            color.y = float(texelCoord.y) / size.y;
        }

        image[texelCoord] = color;
    }
}