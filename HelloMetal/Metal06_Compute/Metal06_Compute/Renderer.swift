//
//  Renderer.swift
//  Metal06_Compute
//
//  Created by 黄梦轩 on 2018/8/8.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

import UIKit
import MetalKit
import GLKit

class Renderer: NSObject, MTKViewDelegate {
    
    internal let device: MTLDevice
    internal let commandQueue: MTLCommandQueue
    internal var renderPipelineState: MTLRenderPipelineState? = nil
    internal var computePipelineState: MTLComputePipelineState? = nil
    internal let vertexBuffer: MTLBuffer
    internal let indexBuffer: MTLBuffer
    internal var inTexture: MTLTexture? = nil
    internal var outTexture: MTLTexture? = nil
    internal var threadgrounpSize: MTLSize = MTLSizeMake(0, 0, 0)
    internal var threadgrounpCount: MTLSize = MTLSizeMake(0, 0, 0)
    
    internal let vertexData:[Float] = [
        -0.75, -0.75, 0.0, 0, 1,
        0.75, -0.75, 0.0, 1, 1,
        0.75, 0.75, 0.0, 1, 0,
        -0.75, 0.75, 0.0, 0, 0
    ]
    
    internal let indices:[UInt32] = [
        0, 1, 2,
        2, 3, 0
    ]

    init(mtkView: MTKView) {
        self.device = MTLCreateSystemDefaultDevice()!
        self.commandQueue = self.device.makeCommandQueue()!
        self.vertexBuffer = self.device.makeBuffer(bytes: vertexData, length: MemoryLayout<Float>.size * vertexData.count, options: [])!
        self.indexBuffer = self.device.makeBuffer(bytes: indices, length: MemoryLayout<UInt32>.size * indices.count, options: [])!
        
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
            print("Failed to create render Pipeline State")
        }
        
        let kernelFunction = defaultLibrary?.makeFunction(name: "grayKernel")
        
        computePipelineState = try? device.makeComputePipelineState(function: kernelFunction!)
        if renderPipelineState == nil {
            print("Failed to create compute Pipeline State")
        }
        
        // 加载纹理
        inTexture = loadTexture()
        if inTexture == nil {
            print("Failed to load texture")
            return
        }
        
        let textureDescriptor = MTLTextureDescriptor.init()
        textureDescriptor.pixelFormat = inTexture!.pixelFormat
        textureDescriptor.width = inTexture!.width
        textureDescriptor.height = inTexture!.height
        // 用于读写的纹理，使用属性必须是shaderWrite和shaderRead
        textureDescriptor.usage = MTLTextureUsage.shaderRead.union(.shaderWrite)
        
        outTexture = device.makeTexture(descriptor: textureDescriptor)
        
        // 初始化threadgroup参数
        threadgrounpSize = MTLSizeMake(16, 16, 1)
        
        threadgrounpCount.width = (inTexture!.width + threadgrounpSize.width - 1) / threadgrounpSize.width
        threadgrounpCount.height = (inTexture!.height + threadgrounpSize.height - 1) / threadgrounpSize.height
        threadgrounpCount.depth = 1
    }
    
    internal func loadTexture() -> MTLTexture? {
        let image = UIImage.init(named: "lena")
        let textureLoader = MTKTextureLoader.init(device: device)
        let textureLoaderOption:[MTKTextureLoader.Option: UInt] = [MTKTextureLoader.Option.textureUsage : MTLTextureUsage.shaderRead.rawValue]
        let texture = try? textureLoader.newTexture(cgImage: (image?.cgImage)!, options: textureLoaderOption)
        
        return texture
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
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let computeEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(computePipelineState!)
        computeEncoder?.setTexture(inTexture, index: 0)
        computeEncoder?.setTexture(outTexture, index: 1)
        computeEncoder?.dispatchThreadgroups(threadgrounpCount, threadsPerThreadgroup: threadgrounpSize)
        computeEncoder?.endEncoding()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(renderPipelineState!)
        
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        commandEncoder?.setFragmentTexture(outTexture, index: 1)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
