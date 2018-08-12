//
//  Vertex.swift
//  Metal06_Compute
//
//  Created by meitu on 2018/8/9.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

struct Vertex {
    var x, y, z: Float
    var r, g, b, a: Float
    
    func floatArray() -> [Float] {
        return [x, y, z, r, g, b, a]
    }
}

enum VertexInputIndex: Int {
    case VertexInputIndexVertices = 0
    case VertexInputIndexMatrix = 1
}

enum FragmentInputIndex: Int {
    case FragmentIndexTexture = 0
}
