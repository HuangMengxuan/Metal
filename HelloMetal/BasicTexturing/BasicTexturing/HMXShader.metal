//
//  HMXShader.metal
//  HelloTriangle
//
//  Created by meitu on 2018/7/24.
//  Copyright © 2018年 meitu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "HMXShaderTypes.h"

typedef struct {
    float4 clipSpacePosition [[position]];
    
    float2 textureCoordinate;
} RasterizerData;

vertex RasterizerData vertexShader(uint vertexID [[vertex_id]],
                                    constant HMXVertex *vertices [[ buffer(HMXVertexInputIndexVertices) ]],
                                    constant vector_uint2 *viewportSizePointer [[ buffer(HMXVertexInputIndexViewportSize) ]]) {
    RasterizerData out;
    
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);
    
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    out.clipSpacePosition.z = 0.0;
    
    out.clipSpacePosition.w = 1.0;
    
    out.textureCoordinate = vertices[vertexID].textureCoordinate;
    
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]],
                               texture2d<half> colorTexture [[ texture(HMXTextureIndexBaseColor) ]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    
    return float4(colorSample);
}
