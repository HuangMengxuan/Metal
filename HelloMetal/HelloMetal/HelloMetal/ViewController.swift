//
//  ViewController.swift
//  HelloMetal
//
//  Created by meitu on 2018/7/19.
//  Copyright © 2018年 meitu. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    
    var vertexBuffer: MTLBuffer! = nil
    
    let vertexData: [Float] = [
        0.0,  1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var commonQueue: MTLCommandQueue! = nil
    
    var timer: CADisplayLink! = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDevice()
        initMetalLayer()
        createVertexBuffer()
        createRenderPipeline()
        createCommandQueue()
        createTimer()
    }
    
    func initDevice() -> Void {
        device = MTLCreateSystemDefaultDevice()
    }
    
    func initMetalLayer() -> Void {
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        
        var drawableSize = view.bounds.size
        drawableSize.width *= view.contentScaleFactor
        drawableSize.height *= view.contentScaleFactor
        metalLayer.drawableSize = drawableSize
        
        view.layer .addSublayer(metalLayer)
    }

    func createVertexBuffer() -> Void {
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: MTLResourceOptions(rawValue: UInt(0)))
    }

    func createRenderPipeline() -> Void {
        let defaultLibray = device.makeDefaultLibrary()
        let vertexProgram = defaultLibray?.makeFunction(name: "basic_vertex")
        let fragmentProgram = defaultLibray?.makeFunction(name: "basic_fragment")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func createCommandQueue() -> Void {
        commonQueue = device.makeCommandQueue()
    }
    
    func createTimer() -> Void {
        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func render() -> Void {
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.8, 0.5, 1.0)
        
        let commandBuffer = commonQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    @objc func gameloop() -> Void {
        autoreleasepool {
            self.render()
        }
    }
}

