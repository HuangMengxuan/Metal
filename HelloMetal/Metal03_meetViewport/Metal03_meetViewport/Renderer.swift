//
//  Renderer.swift
//  Metal03_meetViewport
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
    internal var viewportSize: [Float] = [0.0, 0.0];
    
    internal let vertexData:[Float] = [
        -250.0, -250.0,  0, 1,
        250.0, -250.0,  1, 1,
        250.0,  250.0,  1, 0,
        -250.0,  250.0,  0, 0
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
        
        // 创建顶点缓存
        vertexBuffer = self.device.makeBuffer(bytes: vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, options: .storageModeShared)
        
        
        // 创建索引缓存
        indexBuffer = self.device.makeBuffer(bytes: indices, length: MemoryLayout.size(ofValue: indices[0]) * indices.count, options: .storageModeShared)
        
        // 初始化视口大小
        viewportSize = [Float(mtkView.drawableSize.width), Float(mtkView.drawableSize.height)]
    }
    
    // MARK: MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize[0] = Float(size.width * 2.0 / 3.0);
        viewportSize[1] = Float(size.height * 2.0 / 3.0);
    }
    
    func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(renderPipelineState!)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        let viewport = MTLViewport.init(originX: 0.0, originY: 0.0, width: Double(viewportSize[0]), height: Double(viewportSize[1]), znear: -1.0, zfar: 1.0)
        commandEncoder?.setViewport(viewport)
        commandEncoder?.setVertexBytes(viewportSize, length: MemoryLayout.size(ofValue: viewportSize[0]) * 2, index: 1)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint32, indexBuffer: indexBuffer!, indexBufferOffset: 0)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
