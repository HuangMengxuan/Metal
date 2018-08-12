//
//  Node.swift
//  Metal05_Matrix
//
//  Created by meitu on 2018/8/9.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

import UIKit
import MetalKit

class Node {
    
    public let device: MTLDevice
    public let name: String
    public var vertexCount: Int
    public var vertexBuffer: MTLBuffer
    public var time: CFTimeInterval = 0.0
    
    
    init(device: MTLDevice, name: String, vertices: Array<Vertex>) {
        self.device = device
        self.name = name
        
        var vertexData = Array<Float>()
        for vertex in vertices {
            vertexData += vertex.floatArray()
        }
        
        self.vertexCount = vertices.count
        
        let dataSize = vertexData.count * MemoryLayout<Float>.size
        self.vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: .storageModeShared)!
    }
    
}
