//
//  Shader.metal
//  Metal05_Matrix
//
//  Created by 黄梦轩 on 2018/8/8.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float3 position; // packed_float3 和 float3 不一样
    packed_float4 color;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
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
    out.position = proj_Matrix * mv_Matrix * float4(in.position,1);
    out.color = in.color;

    return out;
}

fragment half4 fragmentShader(VertexOut in [[stage_in]]) {  //1
    return half4(in.color[0], in.color[1], in.color[2], in.color[3]); //2
}
