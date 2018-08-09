//
//  TriangleNode.swift
//  Metal04_Cube
//
//  Created by meitu on 2018/8/9.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

import UIKit

class TriangleNode: Node {

    init(device: MTLDevice) {
        
        let V0 = Vertex(x: 0.0, y: 0.5, z: 0.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let V1 = Vertex(x: -0.5, y: -0.5, z: 0.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let V2 = Vertex(x: 0.5, y: -0.5, z: 0.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        
        let vertexArray = [V0, V1, V2]
        super.init(device: device, name: "Traingle", vertices: vertexArray)
    }
}
