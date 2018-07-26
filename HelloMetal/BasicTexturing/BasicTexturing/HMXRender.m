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
@property (strong, nonatomic) id<MTLRenderPipelineState> pipelineState;

@property (strong, nonatomic) id<MTLTexture> texture;

@property (strong, nonatomic) id<MTLBuffer> vertexBuffer;

@property (assign, nonatomic) NSUInteger numVertices;

@property (assign, nonatomic) vector_uint2 viewportSize;
    
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
    
    self.texture = [self.device newTextureWithDescriptor:textureDescriptor];
    
    MTLRegion region = {
        {0, 0, 0},
        {image.width, image.height, 1}
    };
    
    NSUInteger bytesPerRow = 4 * image.width;
    
    [self.texture replaceRegion:region mipmapLevel:0 withBytes:image.data.bytes bytesPerRow:bytesPerRow];
    
    static const HMXVertex quadVertices[] =
    {
        // Pixel positions, Texture coordinates
        { {  250,  -250 },  { 1.f, 0.f } },
        { { -250,  -250 },  { 0.f, 0.f } },
        { { -250,   250 },  { 0.f, 1.f } },
        
        { {  250,  -250 },  { 1.f, 0.f } },
        { { -250,   250 },  { 0.f, 1.f } },
        { {  250,   250 },  { 1.f, 1.f } },
    };
    
    self.vertexBuffer = [self.device newBufferWithBytes:quadVertices length:sizeof(quadVertices) options:MTLResourceStorageModeShared];
    
    self.numVertices = sizeof(quadVertices) / sizeof(HMXVertex);
    
    id<MTLLibrary> defaultLibarary = [self.device newDefaultLibrary];
    
    id<MTLFunction> vertexFunction = [defaultLibarary newFunctionWithName:@"vertexShader"];
    
    id<MTLFunction> fragmentFunction = [defaultLibarary newFunctionWithName:@"fragmentShader"];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.label = @"simple pipeline";
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    NSError *error = nil;
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if (error) {
        NSLog(@"Failed to create Pipeline State, error:%@", error);
    }
    
    self.commandQueue = [self.device newCommandQueue];
}

#pragma mark - MTKViewDelegate
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

// 每一帧都会调用drawInMTKView:方法
- (void)drawInMTKView:(MTKView *)view {
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0 }];
        [renderEncoder setRenderPipelineState:self.pipelineState];
        
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:HMXVertexInputIndexVertices];
        [renderEncoder setVertexBytes:&(_viewportSize) length:sizeof(_viewportSize) atIndex:HMXVertexInputIndexViewportSize];
        
        [renderEncoder setFragmentTexture:self.texture atIndex:HMXTextureIndexBaseColor];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.numVertices];
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
    
}

@end
