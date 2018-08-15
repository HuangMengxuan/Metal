//
//  Shader.metal
//  Metal07_Sphere
//
//  Created by meitu on 2018/8/15.
//  Copyright © 2018年 meitu. All rights reserved.
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

struct Uniforms{
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut vertexShader(constant VertexIn *vertexData[[ buffer(0) ]],
                              constant Uniforms &uniforms[[ buffer(1) ]],
                              uint vertexID [[ vertex_id ]]) {
    
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    VertexIn in = vertexData[vertexID];
    
    VertexOut out;
    out.position = proj_Matrix * mv_Matrix * float4(in.position, 1);
    out.textureCoordinate = float2(in.textureCoordinate);
    
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> texture [[ texture(0) ]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    const float4 colorSample = texture.sample(textureSampler, in.textureCoordinate);
    
    return colorSample;
}
