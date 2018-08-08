//
//  HMXRenderer.swift
//  Metal01_Triangle
//
//  Created by meitu on 2018/7/31.
//  Copyright © 2018年 meitu. All rights reserved.
//

import UIKit
import MetalKit

class HMXRenderer: NSObject, MTKViewDelegate {
    var device:MTLDevice? = nil
    var vertextBuffer:MTLBuffer? = nil
    var indexBuffer:MTLBuffer? = nil
    var commandQueue:MTLCommandQueue? = nil
    var renderPipelineState:MTLRenderPipelineState? = nil
    var texture:MTLTexture? = nil
    var vertexNum = 0
    
    let vertexData:[Float] = [
        -0.5, -0.5,  0, 1,
        0.5, -0.5,  1, 1,
        0.5,  0.5,  1, 0,
        -0.5,  0.5,  0, 0
    ]
    
    let indices:[Int32] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    init(mtkView:MTKView) {
        super.init()
        
        mtkView.delegate = self as MTKViewDelegate
        device = mtkView.device
        
        self.loadMetal(mtkView: mtkView)
    }
    
    // MARK: Private
    private func loadMetal(mtkView:MTKView) {
        
        do {
            texture = try loadTexture(device: self.device!, textureName: "lena")
        } catch {
            print("Failed to load the texture. Error info: \(error)")
        }
        
        vertextBuffer = device?.makeBuffer(bytes: vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, options: .storageModeShared)
        
        indexBuffer = device?.makeBuffer(bytes: indices, length: MemoryLayout.size(ofValue: indices[0]) * indices.count, options: .storageModeShared)
        
        let defaultLibrary = self.device?.makeDefaultLibrary()
        
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
        
        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor.init()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        renderPipelineState = try! device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        if renderPipelineState == nil {
            print("Failed to create Pipeline State")
        }
        
        commandQueue = device?.makeCommandQueue()
    }
    
    func loadTexture(device: MTLDevice, textureName: String) throws -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: device)
        return try textureLoader.newTexture(name: textureName, scaleFactor: 1.0, bundle: nil, options: nil)
    }

    // MARK: MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(renderPipelineState!)
//        commandEncoder?.setVertexBytes(vertexData, length: vertexData.count * MemoryLayout.size(ofValue: vertexData[0]), index: 0)
        commandEncoder?.setVertexBuffer(vertextBuffer, offset: 0, index: 0)
        
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
//        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint32, indexBuffer: indexBuffer!, indexBufferOffset: 0)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
}
