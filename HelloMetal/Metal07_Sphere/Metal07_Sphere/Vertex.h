//
//  Vertex.h
//  Metal07_Sphere
//
//  Created by meitu on 2018/8/15.
//  Copyright © 2018年 meitu. All rights reserved.
//

#ifndef Vertex_h
#define Vertex_h

#include <metal_stdlib>

struct VertexIn {
    packed_float3 position; // packed_float3 和 float3 不一样
    packed_float2 textureCoordinate;
};


#endif /* Vertex_h */
