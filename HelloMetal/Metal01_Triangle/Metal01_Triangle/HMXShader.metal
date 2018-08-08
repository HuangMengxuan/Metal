//
//  HMXShader.metal
//  Metal01_Triangle
//
//  Created by meitu on 2018/8/6.
//  Copyright © 2018年 meitu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position;
    float2 textureCoordinate;
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinate;
};

typedef struct {
    float4 vertexPosition [[position]];
    float2 textureCoordinate;
} RasterizerData;

vertex VertexOut vertexShader(constant VertexIn *vertex_array[[ buffer(0) ]],
                                   unsigned int vertexID [[vertex_id]]) {
    VertexOut out;
    
    VertexIn in = vertex_array[vertexID];
    
    out.position = vector_float4(in.position, 0.0, 1.0);
    
    out.textureCoordinate = in.textureCoordinate;
    
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                              texture2d<float> texture2D [[ texture(0) ]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    
    const float4 colorSample = texture2D.sample(textureSampler, in.textureCoordinate);
    
    return float4(colorSample);
}
