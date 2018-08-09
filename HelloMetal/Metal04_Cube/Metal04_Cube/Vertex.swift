//
//  Vertex.swift
//  Metal04_Cube
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
