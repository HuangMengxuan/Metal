//
//  Renderer.swift
//  Metal04_Cube
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
    
    public var triangleNode: TriangleNode
    public var cubeNode: CubeNode
    
    internal let projectionMatrix: Matrix4
    
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
        self.projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(mtkView.drawableSize.width / mtkView.drawableSize.height), nearZ: 0.01, farZ: 100.0)
        
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
        
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setCullMode(.front)
        commandEncoder?.setRenderPipelineState(renderPipelineState!)
        commandEncoder?.setVertexBuffer(cubeNode.vertexBuffer, offset: 0, index: 0)
        
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        updateRotateAngle()
        
        // 1
        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiplyLeft(worldModelMatrix)
        // 2
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2, options: [])
        // 3
        let bufferPointer = uniformBuffer?.contents()
        // 4
        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer! + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        // 5
        commandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
//        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: cubeNode.vertexCount)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: cubeNode.vertexCount, instanceCount: cubeNode.vertexCount / 3)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
    func updateRotateAngle() {
        let secsPerMove: Float = 6.0
        rotationY = sinf( Float(time / 60) * 2.0 * Float(Double.pi) / secsPerMove)
        rotationX = sinf( Float(time / 60) * 2.0 * Float(Double.pi) / secsPerMove)
        time += 1
    }
}
