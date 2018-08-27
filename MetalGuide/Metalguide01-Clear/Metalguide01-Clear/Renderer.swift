//
//  Renderer.swift
//  Metalguide01-ClearScreen
//
//  Created by meitu on 2018/8/27.
//  Copyright © 2018年 meitu. All rights reserved.
//

import UIKit
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue

    init(mtkView: MTKView) {
        
        // 获取设备的默认GPU对象
        self.device = MTLCreateSystemDefaultDevice()!
        
        // 通过MTLDevice获取MTLCommandQueue
        self.commandQueue = self.device.makeCommandQueue()!
        
        super.init()
        
        // 为MTKView设置代理
        mtkView.delegate = self
        
        // 为MTKView设置device属性，MTKView的device属性为空则无法渲染
        mtkView.device = self.device
    }
    
    // 视图尺寸发生改变时调用该方法
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    // 每渲染一帧都会调用该方法
    func draw(in view: MTKView) {
        
        // MetalKit视图为每个帧创建一个新的MTLRenderPassDescriptor对象
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        // 获取MTKView中的drawable
        guard let drawable = view.currentDrawable else {
            return
        }
        
        // 设置colorAttachments[0]的清屏颜色
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0)
        // 设置colorAttachments[0]的清屏类型
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        // 通过MTLCommandQueue获取MTLCommandBuffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // 创建MTLRenderCommandEncoder
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        // 指示编码器已完成
        renderEncoder?.endEncoding()
        
        // 告诉Metal等待GPU完成渲染到drawable之后再在屏幕上显示
        commandBuffer?.present(drawable)
        
        // 将MTLCommandBuffer提交到MTLCommandQueue，并阻止再对该MTLCommandBuffer进行编码
        commandBuffer?.commit()
    }
}
