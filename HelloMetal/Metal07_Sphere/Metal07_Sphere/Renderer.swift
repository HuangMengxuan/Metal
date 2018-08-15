//
//  Renderer.swift
//  Metal07_Sphere
//
//  Created by meitu on 2018/8/15.
//  Copyright © 2018年 meitu. All rights reserved.
//

import Foundation
import MetalKit
import GLKit

let vertexNumPerLayer: Int = 80 // 球体每层的顶点数

class Renderer: NSObject, MTKViewDelegate {
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var renderPipelineState: MTLRenderPipelineState? = nil
    private var texture: MTLTexture? = nil
    private lazy var vertexData: [Float] = {
        return getSphereVertexData(num: vertexNumPerLayer)
    }()
    private lazy var indices: [UInt32] = {
        return getSphereIndices(num: vertexNumPerLayer)
    }()
    private lazy var vertexBuffer: MTLBuffer = {
        return device.makeBuffer(bytes: vertexData, length: MemoryLayout<Float>.size * vertexData.count, options: .storageModeShared)!
    }()
    private lazy var indexBuffer: MTLBuffer = {
        return device.makeBuffer(bytes: indices, length: MemoryLayout<UInt32>.size * indices.count, options: .storageModeShared)!
    }()
    
    private var rotationX: Float = 0.0
    private var rotationY: Float = 0.0
    private var rotationZ: Float = 0.0
    
    var needRotateX: Bool = false // 是否沿X方向旋转
    var needRotateY: Bool = false // 是否沿Y方向旋转
    var needRotateZ: Bool = false // 是否沿Z方向旋转
    
    init(mtkView: MTKView) {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        
        super.init()
        
        mtkView.device = device
        mtkView.delegate = self
        
        self.loadMetal(mtkView: mtkView)
    }
    
    
    //MARK: Private
    private func loadMetal(mtkView: MTKView) {
        
        // 加载纹理
        texture = loadTexture(name: "006.jpg")
        if texture == nil {
            print("Failed to load texture")
            return
        }
        
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
            return
        }
    }
    
    private func loadTexture(name: String) -> MTLTexture? {
        let image = UIImage.init(named: name)
        if image == nil {
            print("Failed to load image")
            return nil
        }
        
        let textureLoader = MTKTextureLoader.init(device: device)
        let textureLoaderOption:[MTKTextureLoader.Option: UInt] = [MTKTextureLoader.Option.textureUsage : MTLTextureUsage.shaderRead.rawValue]
        let texture = try? textureLoader.newTexture(cgImage: (image?.cgImage)!, options: textureLoaderOption)
        
        return texture
    }
    
    private func getSphereVertexData(num vertexNumPerLayer: Int) -> [Float] {
        if vertexNumPerLayer % 2 == 1 {
            return []
        }
        
        var vertexData: [Float] = []
        
        
        let delta: Float = 2 * Float.pi / Float(vertexNumPerLayer) // 每一份的弧度
        let sphereRadius: Float = 1.0 // 球体的半径
        let textureXDelta: Float = 1.0 / Float(vertexNumPerLayer) //
        let textureYDelta: Float = 1.0 / (Float(vertexNumPerLayer) / 2) //
        let layerNum: Int = vertexNumPerLayer / 2 + 1 // 层数
        let perLayerNum: Int = vertexNumPerLayer + 1 // 从起点再到起点，多以需要+1
        
        var pointX: Float = 0.0
        var pointY: Float = 0.0
        var pointZ: Float = 0.0
        var textureX: Float = 0.0
        var textureY: Float = 0.0
        
        for i in 0..<layerNum {
            pointY = -sphereRadius * cos(delta * Float(i))
            
            let layerRadius: Float = sphereRadius * sin(delta * Float(i))
            
            for j in 0..<perLayerNum {
                pointX = layerRadius * cos(delta * Float(j))
                pointZ = layerRadius * sin(delta * Float(j))
                
                textureX = 1.0 - textureXDelta * Float(j)
                textureY = 1.0 - textureYDelta * Float(i)
                
                vertexData += [pointX, pointY, pointZ, textureX, textureY]
            }
        }
        
        return vertexData
    }
    
    private func getSphereIndices(num vertexNumPerLayer: Int) -> [UInt32] {
        
        let indicesCount = (vertexNumPerLayer + 1) * (vertexNumPerLayer + 1)
        
        var indices = Array<UInt32>(repeating: 0, count: indicesCount)
        
        let layerNum: Int = vertexNumPerLayer / 2 + 1 // 层数
        let perLayerNum: Int = vertexNumPerLayer + 1 // 从起点再到起点，多以需要+1
        
        for i in 0..<layerNum {
            if i + 1 < layerNum {
                for j in 0..<perLayerNum {
                    // i * perLayerNum * 2每层的下标是原来的2倍
                    indices[i * perLayerNum * 2 + j * 2] = UInt32(i * perLayerNum + j)
                    // 后一层数据
                    indices[i * perLayerNum * 2 + j * 2 + 1] = UInt32((i + 1) * perLayerNum + j)
                }
            } else {
                for j in 0..<perLayerNum {
                    // 后最一层数据单独处理
                    indices[i * perLayerNum * 2 + j] = UInt32(i * perLayerNum + j)
                }
            }
        }
        
        return indices
    }
    
    func setupMatrixWithEncoder(view: MTKView, encoder: MTLRenderCommandEncoder) -> Void {
        let aspect = fabsf(Float(view.drawableSize.width) / Float(view.drawableSize.height))
        
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.01, 10.0)
        
        var modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, 0.0)
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
        let anglePerMove: Float = 2.0 * Float.pi / 60 / 6.0
        
        if needRotateX {
            rotationX += anglePerMove
        }
        
        if needRotateY {
            rotationY += anglePerMove
        }
        
        if needRotateZ {
            rotationZ += anglePerMove
        }
    }
    
    //MARK: MTKViewDelegate
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
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(renderPipelineState!)
        
        commandEncoder?.setCullMode(.back)
        
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        updateRotateAngle()
        setupMatrixWithEncoder(view: view, encoder: commandEncoder!)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangleStrip, indexCount: indices.count, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
