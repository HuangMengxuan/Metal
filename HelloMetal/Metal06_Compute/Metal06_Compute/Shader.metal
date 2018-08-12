//
//  Shader.metal
//  Metal06_Compute
//
//  Created by 黄梦轩 on 2018/8/8.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float3 position; // packed_float3 和 float3 不一样
    packed_float2 textureCoordinate;
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinate;
};

vertex VertexOut vertexShader(constant VertexIn *vertexData[[ buffer(0) ]],
                              uint vertexID [[ vertex_id ]]) {
    
    VertexIn in = vertexData[vertexID];

    VertexOut out;
    out.position = float4(in.position,1);
    out.textureCoordinate = float2(in.textureCoordinate);

    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                              texture2d<float> texture [[ texture(1) ]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    const float4 colorSample = texture.sample(textureSampler, in.textureCoordinate);
    
    return colorSample;
}

//constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);
//
//void grayKernel(texture2d<half, access::read> textureIn [[ texture(0) ]],
//                texture2d<half, access::read> textureOut [[ texture(1) ]],
//                uint2 gid [[ thread_position_in_grid ]]) {
//    if ((gid.x >= textureOut.get_width()) || (gid.y >= textureOut.get_height())) {
//        return;
//    }
//
//    half4 inColor = textureIn.read(gid);
//    half gray = dot(inColor.rgb, kRec709Luma);
//    textureOut.write(half4(gray, gray, gray, 1.0), gid);
//}

// Rec. 709 luma values for grayscale image conversion
constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

// Grayscale compute kernel
kernel void grayKernel(texture2d<half, access::read>  inTexture  [[ texture(0) ]],
                            texture2d<half, access::write> outTexture [[ texture(1) ]],
                            uint2                          gid         [[ thread_position_in_grid ]])
{
    // Check if the pixel is within the bounds of the output texture
    if((gid.x >= outTexture.get_width()) || (gid.y >= outTexture.get_height()))
    {
        // Return early if the pixel is out of bounds
        return;
    }
    
    half4 inColor  = inTexture.read(gid);
    half  gray     = dot(inColor.rgb, kRec709Luma);
    outTexture.write(half4(gray, gray, gray, 1.0), gid);
}
