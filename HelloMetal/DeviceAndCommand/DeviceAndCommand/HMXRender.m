//
//  HMXRender.m
//  DeviceAndCommand
//
//  Created by meitu on 2018/7/24.
//  Copyright © 2018年 meitu. All rights reserved.
//

#import "HMXRender.h"

@interface HMXRender ()
   
@property (strong, nonatomic) id<MTLDevice> device;
@property (strong, nonatomic) id<MTLCommandQueue> commandQueue;
    
@end

typedef struct {
    float red, green, blue, alpha;
} Color;

@implementation HMXRender
    
- (instancetype)initWithMetalKitView:(MTKView *)mtkView {
    if (self = [super init]) {
        self.device = mtkView.device;
        
        // 通过MTLCommandQueue获取MTLCommandQueue
        self.commandQueue = [self.device newCommandQueue];
    }
    return self;
}

- (Color)makeFancyColor
{
    static BOOL       growing = YES;
    static NSUInteger primaryChannel = 0;
    static float      colorChannels[] = {1.0, 0.0, 0.0, 1.0};
    
    const float DynamicColorRate = 0.015;
    
    if(growing)
    {
        NSUInteger dynamicChannelIndex = (primaryChannel+1)%3;
        colorChannels[dynamicChannelIndex] += DynamicColorRate;
        if(colorChannels[dynamicChannelIndex] >= 1.0)
        {
            growing = NO;
            primaryChannel = dynamicChannelIndex;
        }
    }
    else
    {
        NSUInteger dynamicChannelIndex = (primaryChannel+2)%3;
        colorChannels[dynamicChannelIndex] -= DynamicColorRate;
        if(colorChannels[dynamicChannelIndex] <= 0.0)
        {
            growing = YES;
        }
    }
    
    Color color;
    
    color.red   = colorChannels[0];
    color.green = colorChannels[1];
    color.blue  = colorChannels[2];
    color.alpha = colorChannels[3];
    
    return color;
}

#pragma mark - MTKViewDelegate
// 每一帧都会调用drawInMTKView:方法
- (void)drawInMTKView:(MTKView *)view {
    // 获取需要显示的Color
    Color color = [self makeFancyColor];
    
    // 将待显示颜色设置为MTKView的clearColor
    view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alpha);
    
    // 通过MTLCommandQueue获取MTLCommandBuffer
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    // MetalKit视图为每个帧创建一个新的MTLRenderPassDescriptor对象
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil) {
        // 创建MTLRenderCommandEncoder
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        renderEncoder.label = @"MyRenderEncoder";
        
        // 指示编码器已完成
        [renderEncoder endEncoding];
        
        // 告诉Metal等待GPU完成渲染到drawable之后再在屏幕上显示
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    // 将MTLCommandBuffer提交到MTLCommandQueue，并阻止再对该MTLCommandBuffer进行编码
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
