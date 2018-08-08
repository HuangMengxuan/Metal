//
//  Shader.metal
//  Metal02_meetTexture
//
//  Created by 黄梦轩 on 2018/8/8.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 vertexPosition;
    float2 textureCoordinate;
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinate;
};

vertex VertexOut vertexShader(constant VertexIn *vertexData[[ buffer(0) ]],
                              uint vertexID [[ vertex_id ]]) {
    VertexOut out;

    VertexIn in = vertexData[vertexID];

    out.position = float4(in.vertexPosition, 0.0, 1.0);
    out.textureCoordinate = in.textureCoordinate;

    return out;
}

fragment float4 fragmentShader(VertexOut in [[ stage_in ]],
                               texture2d<float> texture [[ texture(0) ]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    const float4 colorSample = texture.sample(textureSampler, in.textureCoordinate);

    return colorSample;
}
