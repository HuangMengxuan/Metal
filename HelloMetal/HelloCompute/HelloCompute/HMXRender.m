//
//  HMXRender.m
//  DeviceAndCommand
//
//  Created by meitu on 2018/7/24.
//  Copyright © 2018年 meitu. All rights reserved.
//

#import "HMXRender.h"
#import "HMXShaderTypes.h"
#import "HMXImage.h"

@interface HMXRender ()
   
@property (strong, nonatomic) id<MTLDevice> device;
@property (strong, nonatomic) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic) id<MTLComputePipelineState> computePipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> renderPipelineState;
@property (strong, nonatomic) id<MTLTexture> inputTexture;
@property (strong, nonatomic) id<MTLTexture> outputTexture;
@property (strong, nonatomic) id<MTLBuffer> vertexBuffer;
@property (assign, nonatomic) vector_uint2 viewportSize;
@property (assign, nonatomic) MTLSize threadgroupSize;
@property (assign, nonatomic) MTLSize threadgroupCount;
    
@end

@implementation HMXRender
    
- (instancetype)initWithMetalKitView:(MTKView *)mtkView {
    if (self = [super init]) {
        self.device = mtkView.device;
        [self loadMetal:mtkView];
    }
    return self;
}

- (void)loadMetal:(MTKView *)mtkView {
    
    NSError *error = nil;
    
    NSURL *imageFileUrl = [[NSBundle mainBundle] URLForResource:@"Image" withExtension:@"tga"];
    
    HMXImage *image = [[HMXImage alloc] initWithTGAFileUrl:imageFileUrl];
    if (!image) {
        NSLog(@"Failed to create the image from %@", imageFileUrl.absoluteString);
        return;
    }
    
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    textureDescriptor.width = image.width;
    textureDescriptor.height = image.height;
    
    self.inputTexture = [self.device newTextureWithDescriptor:textureDescriptor];
    
    MTLRegion region = {
        {0, 0, 0},
        {image.width, image.height, 1}
    };
    
    NSUInteger bytesPerRow = 4 * image.width;
    [self.inputTexture replaceRegion:region mipmapLevel:0 withBytes:image.data.bytes bytesPerRow:bytesPerRow];
    if (self.inputTexture == nil) {
        NSLog(@"Error creating texture");
    }
    
    textureDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    self.outputTexture = [self.device newTextureWithDescriptor:textureDescriptor];
    
    
    id<MTLLibrary> defaultLibarary = [self.device newDefaultLibrary];
    
    id<MTLFunction> vertexFunction = [defaultLibarary newFunctionWithName:@"vertexShader"];
    
    id<MTLFunction> fragmentFunction = [defaultLibarary newFunctionWithName:@"fragmentShader"];
    
    id<MTLFunction> kernelFunction = [defaultLibarary newFunctionWithName:@"grayscaleKernel"];
    
    self.computePipelineState = [self.device newComputePipelineStateWithFunction:kernelFunction error:&error];
    if (!self.computePipelineState) {
        NSLog(@"Failed to create compute pipeline state, error %@", error);
    }
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.label = @"simple pipeline";
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if (error) {
        NSLog(@"Failed to create Pipeline State, error:%@", error);
    }
    
    self.threadgroupSize = MTLSizeMake(16, 16, 1);
    
    _threadgroupCount.width = (self.inputTexture.width  + self.threadgroupSize.width -  1) / self.threadgroupSize.width;
    _threadgroupCount.height = (self.inputTexture.height + self.threadgroupSize.height - 1) / self.threadgroupSize.height;
    _threadgroupCount.depth = 1;
    
    self.commandQueue = [self.device newCommandQueue];
}

#pragma mark - MTKViewDelegate
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

// 每一帧都会调用drawInMTKView:方法
- (void)drawInMTKView:(MTKView *)view {
    static const HMXVertex quadVertices[] =
    {
        //Pixel Positions, Texture Coordinates
        { {  250,  -250 }, { 1.f, 0.f } },
        { { -250,  -250 }, { 0.f, 0.f } },
        { { -250,   250 }, { 0.f, 1.f } },
        
        { {  250,  -250 }, { 1.f, 0.f } },
        { { -250,   250 }, { 0.f, 1.f } },
        { {  250,   250 }, { 1.f, 1.f } },
    };
    
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    commandBuffer.label = @"MyComputeEncoder";
    
    [computeEncoder setComputePipelineState:self.computePipelineState];
    [computeEncoder setTexture:self.inputTexture atIndex:HMXTextureIndexInput];
    [computeEncoder setTexture:self.outputTexture atIndex:HMXTextureIndexOutput];
    [computeEncoder dispatchThreadgroups:self.threadgroupCount threadsPerThreadgroup:self.threadgroupSize];
    [computeEncoder endEncoding];
    
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0 }];
        [renderEncoder setRenderPipelineState:self.self.renderPipelineState];
        
        [renderEncoder setVertexBytes:quadVertices length:sizeof(quadVertices) atIndex:HMXVertexInputIndexVertices];
        [renderEncoder setVertexBytes:&(_viewportSize) length:sizeof(_viewportSize) atIndex:HMXVertexInputIndexViewportSize];
        
        [renderEncoder setFragmentTexture:self.outputTexture atIndex:HMXTextureIndexOutput];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

@end
