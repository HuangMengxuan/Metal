//
//  Renderer.swift
//  Metal02_meetTexture
//
//  Created by 黄梦轩 on 2018/8/8.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

import UIKit
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    internal let device: MTLDevice
    internal let commandQueue: MTLCommandQueue
    internal var renderPipelineState: MTLRenderPipelineState? = nil
    internal var vertexBuffer: MTLBuffer? = nil
    internal var indexBuffer: MTLBuffer? = nil
    internal var texture: MTLTexture? = nil
    
    internal let vertexData:[Float] = [
        -0.5, -0.5,  0, 1,
        0.5, -0.5,  1, 1,
        0.5,  0.5,  1, 0,
        -0.5,  0.5,  0, 0
    ]
    
    internal let indices:[UInt32] = [
        0, 1, 2,
        2, 3, 0
    ]

    init(mtkView: MTKView) {
        self.device = MTLCreateSystemDefaultDevice()!
        self.commandQueue = self.device.makeCommandQueue()!
        
        super.init()
        
        mtkView.device = self.device
        mtkView.delegate = self
        
        self.vertexBuffer = self.device.makeBuffer(bytes: vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, options: .storageModeShared)
        self.indexBuffer = self.device.makeBuffer(bytes: indices, length: MemoryLayout.size(ofValue: indices[0]) * indices.count, options: .storageModeShared)
        
        self.loadMetal(mtkView: mtkView)
    }
    
    internal func loadMetal(mtkView: MTKView) {
        // 加载着色器
        let defaultLibrary = device.makeDefaultLibrary()
        
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
        
        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        // 创建渲染管线状态
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor.init()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        if renderPipelineState == nil {
            print("Failed to create Pipeline State")
        }
        
        // 加载纹理
        let textureLoader = MTKTextureLoader.init(device: device)
        texture = try? textureLoader.newTexture(name: "lena", scaleFactor: mtkView.contentScaleFactor, bundle: nil, options: nil)
        if texture == nil {
            print("Failed to load the texture.")
        }
    }
    
    // MARK: MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(renderPipelineState!)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint32, indexBuffer: indexBuffer!, indexBufferOffset: 0)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
