//
//  CubeNode.swift
//  Metal05_Matrix
//
//  Created by meitu on 2018/8/9.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

import UIKit

class CubeNode: Node {

    init(device: MTLDevice) {
        
        let A = Vertex(x: -1.0, y:  1.0, z:  1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let B = Vertex(x: -1.0, y: -1.0, z:  1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let C = Vertex(x:  1.0, y: -1.0, z:  1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        let D = Vertex(x:  1.0, y:  1.0, z:  1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0)
        
        let Q = Vertex(x: -1.0, y:  1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let R = Vertex(x:  1.0, y:  1.0, z: -1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let S = Vertex(x: -1.0, y: -1.0, z: -1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        let T = Vertex(x:  1.0, y: -1.0, z: -1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0)
        
        let vertexArray:Array<Vertex> = [
            A,B,C ,A,C,D,   //Front
            R,T,S ,Q,R,S,   //Back
            
            Q,S,B ,Q,B,A,   //Left
            D,C,T ,D,T,R,   //Right
            
            Q,A,D ,Q,D,R,   //Top
            B,S,T ,B,T,C    //Bot
        ]
        
        super.init(device: device, name: "Cube", vertices: vertexArray)
    }
}
