//
//  Shader.metal
//  Metal01_Triangle
//
//  Created by meitu on 2018/8/8.
//  Copyright © 2018年 meitu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertexShader(device packed_float2 *vertexData[[ buffer(0) ]],
                           uint vertexID [[vertex_id]]) {
    return float4(vertexData[vertexID], 0.0, 1.0);
}

fragment float4 fragmentShader() {
    return float4(1.0);
}
