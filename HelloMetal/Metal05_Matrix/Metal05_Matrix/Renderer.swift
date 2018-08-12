//
//  Renderer.swift
//  Metal05_Matrix
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
    internal var vertexBuffer: MTLBuffer? = nil
    
    public var triangleNode: TriangleNode
    public var cubeNode: CubeNode
    
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    var time:Float = 0.0
    

    init(mtkView: MTKView) {
        self.device = MTLCreateSystemDefaultDevice()!
        self.commandQueue = self.device.makeCommandQueue()!
        self.triangleNode = TriangleNode.init(device: device)
        self.cubeNode = CubeNode.init(device: device)
        
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
        commandEncoder?.setCullMode(.front)
        commandEncoder?.setRenderPipelineState(renderPipelineState!)
        commandEncoder?.setVertexBuffer(cubeNode.vertexBuffer, offset: 0, index: 0)
        
        updateRotateAngle()
        
        setupMatrixWithEncoder(view: view, encoder: commandEncoder!)
        
        let width = view.drawableSize.width
        let height = view.drawableSize.height
        commandEncoder?.setViewport(MTLViewport.init(originX: 0.0, originY: 0.0, width: Double(width / 2), height: Double(height / 2), znear: -1.0, zfar: 1.0))
        
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: cubeNode.vertexCount)
        
        
        commandEncoder?.setViewport(MTLViewport.init(originX: Double(width / 2), originY: 0.0, width: Double(width / 2), height: Double(height / 2), znear: 0.0, zfar: 1.0))
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: cubeNode.vertexCount)
        
        
        commandEncoder?.setViewport(MTLViewport.init(originX: 0.0, originY: Double(height / 2), width: Double(width), height: Double(height / 2), znear: 0.0, zfar: 1.0))
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: cubeNode.vertexCount)
        
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    
    func setupMatrixWithEncoder(view: MTKView, encoder: MTLRenderCommandEncoder) -> Void {
        let aspect = fabsf(Float(view.drawableSize.width) / Float(view.drawableSize.height))
        
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.01, 10.0)
        var modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -1.0)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotationX, 1, 0, 0)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotationY, 0, 1, 0)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotationZ, 0, 0, 1)
        
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<float4x4>.size * 2, options: .storageModeShared)
        let bufferPointer = uniformBuffer?.contents()
        bufferPointer?.copyMemory(from: [metalMatrixFromGLKMatrix(glkMatrix: modelViewMatrix)], byteCount: MemoryLayout<float4x4>.size)
        let bufferPointer1 = bufferPointer! + MemoryLayout<float4x4>.size
        bufferPointer1.copyMemory(from: [metalMatrixFromGLKMatrix(glkMatrix: projectionMatrix)], byteCount: MemoryLayout<float4x4>.size)
        
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
    }
    
    func metalMatrixFromGLKMatrix(glkMatrix: GLKMatrix4) -> float4x4 {
        return float4x4.init([
            float4.init(glkMatrix.m00, glkMatrix.m01, glkMatrix.m02, glkMatrix.m03),
            float4.init(glkMatrix.m10, glkMatrix.m11, glkMatrix.m12, glkMatrix.m13),
            float4.init(glkMatrix.m20, glkMatrix.m21, glkMatrix.m22, glkMatrix.m23),
            float4.init(glkMatrix.m30, glkMatrix.m31, glkMatrix.m32, glkMatrix.m33)
            ])
    }
    
    func updateRotateAngle() {
        let secsPerMove: Float = 6.0
        rotationY = sinf( Float(time / 60) * 2.0 * Float(Double.pi) / secsPerMove)
        rotationX = sinf( Float(time / 60) * 2.0 * Float(Double.pi) / secsPerMove)
        time += 1
    }
}
