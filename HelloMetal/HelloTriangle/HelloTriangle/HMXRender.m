//
//  HMXRender.m
//  DeviceAndCommand
//
//  Created by meitu on 2018/7/24.
//  Copyright © 2018年 meitu. All rights reserved.
//

#import "HMXRender.h"
#import "HMXShaderTypes.h"

@interface HMXRender ()
   
@property (strong, nonatomic) id<MTLDevice> device;
@property (strong, nonatomic) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic) id<MTLRenderPipelineState> pipelineState;

@property (assign, nonatomic) vector_uint2 viewportSize;
    
@end

@implementation HMXRender
    
- (instancetype)initWithMetalKitView:(MTKView *)mtkView {
    if (self = [super init]) {
        self.device = mtkView.device;
        
        // 加载项目中所有后缀为.metal的文件
        id<MTLLibrary> defaultLibrary = [self.device newDefaultLibrary];
        
        // 加载顶点着色器
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        
        // 加载片元着色器
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        // 创建MTLRenderPipelineState
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"simple pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        
        NSError *error = nil;
        self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
        if (!self.pipelineState) {
            NSLog(@"Failed to create Pipeline State, error:%@", error);
            return nil;
        }
        
        // 通过MTLCommandQueue获取MTLCommandQueue
        self.commandQueue = [self.device newCommandQueue];
    }
    return self;
}

#pragma mark - MTKViewDelegate
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

// 每一帧都会调用drawInMTKView:方法
- (void)drawInMTKView:(MTKView *)view {
    static const HMXVertex triangleVertices[] =
    {
        // 2D positions,    RGBA colors
        { {  250,  -250 }, { 1, 0, 0, 1 } },
        { { -250,  -250 }, { 0, 1, 0, 1 } },
        { {    0,   250 }, { 0, 0, 1, 1 } },
    };
    
    // 通过MTLCommandQueue获取MTLCommandBuffer
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    // MetalKit视图为每个帧创建一个新的MTLRenderPassDescriptor对象
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil) {
        // 创建MTLRenderCommandEncoder
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        // 设置视口
        [renderEncoder setViewport:(MTLViewport){0.0f, 0.0f, _viewportSize.x, _viewportSize.y, -1.0f, 1.0f}];
        
        [renderEncoder setRenderPipelineState:self.pipelineState];
        
        [renderEncoder setVertexBytes:triangleVertices length:sizeof(triangleVertices) atIndex:HMXVertexInputIndexVertices];
        
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:HMXVertexInputIndexViewportSize];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        
        // 指示编码器已完成
        [renderEncoder endEncoding];
        
        // 告诉Metal等待GPU完成渲染到drawable之后再在屏幕上显示
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    // 将MTLCommandBuffer提交到MTLCommandQueue，并阻止再对该MTLCommandBuffer进行编码
    [commandBuffer commit];
}

@end
