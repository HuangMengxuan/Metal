//
//  HMXShaderTypes.h
//  HelloTriangle
//
//  Created by meitu on 2018/7/24.
//  Copyright © 2018年 meitu. All rights reserved.
//


#ifndef HMXShaderTypes_h
#define HMXShaderTypes_h

#import <simd/simd.h>

typedef enum HMXVertexInputIndex {
    HMXVertexInputIndexVertices     = 0,
    HMXVertexInputIndexViewportSize = 1,
} HMXVertexInputIndex;

typedef enum HMXTextureIndex {
    HMXTextureIndexInput = 0,
    HMXTextureIndexOutput = 1,
} HMXTextureIndex;

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} HMXVertex;

#endif
