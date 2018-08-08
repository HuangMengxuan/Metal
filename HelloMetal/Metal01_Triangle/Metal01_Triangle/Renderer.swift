//
//  Renderer.swift
//  Metal01_Triangle
//
//  Created by meitu on 2018/8/8.
//  Copyright © 2018年 meitu. All rights reserved.
//

import UIKit
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    internal let device: MTLDevice
    internal let commandQueue: MTLCommandQueue
    internal var renderPipelineState: MTLRenderPipelineState? = nil
    internal let vertexData:[Float] = [
        0.0, 1.0,
        -1.0, -1.0,
        1.0, -1.0,
    ]
    
    internal let vertexBuffer: MTLBuffer;
    
    init(mtkView: MTKView) {
        self.device = MTLCreateSystemDefaultDevice()!
        self.commandQueue = self.device.makeCommandQueue()!
        self.vertexBuffer = self.device.makeBuffer(bytes: vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, options: .storageModeShared)!
        mtkView.device = self.device
        
        super.init()
        
        mtkView.delegate = self
        self.loadMetal(mtkView: mtkView)
    }
    
    // MARK: Private
    func loadMetal(mtkView: MTKView) -> Void {
        
        let defaultLibrary = device.makeDefaultLibrary()
        
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
        
        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "renderPipelineDescriptor"
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }
    
    // MARK: MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.label = "commandEncoder"
        commandEncoder?.setRenderPipelineState(renderPipelineState!)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        /*
         commandEncoder?.setVertexBytes(vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, index: 0)
         导致出现如下问题，该问题尚未解决
         Vertex Function(vertexShader):Bytes are being bound at index 0 to a shader argument with write access enabled.
         */
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
}
