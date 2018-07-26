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

@property (strong, nonatomic) id<MTLBuffer> vertexBuffer;

@property (assign, nonatomic) NSUInteger numVertices;
    
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
    
    NSData *vertexData = [HMXRender generateVertexData];
    self.vertexBuffer = [self.device newBufferWithLength:vertexData.length options:MTLResourceStorageModeShared];
    memcpy(self.vertexBuffer.contents, vertexData.bytes, vertexData.length);
    
    self.numVertices = vertexData.length / sizeof(HMXVertex);
    
    self.commandQueue = [self.device newCommandQueue];
}

+ (NSData *)generateVertexData {
    const HMXVertex quadVertices[] =
    {
        // Pixel positions, RGBA colors
        { { -20,   20 },    { 1, 0, 0, 1 } },
        { {  20,   20 },    { 0, 0, 1, 1 } },
        { { -20,  -20 },    { 0, 1, 0, 1 } },
        
        { {  20,  -20 },    { 1, 0, 0, 1 } },
        { { -20,  -20 },    { 0, 1, 0, 1 } },
        { {  20,   20 },    { 0, 0, 1, 1 } },
    };
    
    const NSUInteger NUM_COLUMNS = 25;
    const NSUInteger NUM_ROWS = 15;
    const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices) / sizeof(HMXVertex);
    const float QUAD_SPACING = 50.0;
    
    NSUInteger dataSize = sizeof(quadVertices) * NUM_COLUMNS * NUM_ROWS;
    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
    
    HMXVertex* currentQuad = vertexData.mutableBytes;
    
    for(NSUInteger row = 0; row < NUM_ROWS; row++)
    {
        for(NSUInteger column = 0; column < NUM_COLUMNS; column++)
        {
            vector_float2 upperLeftPosition;
            upperLeftPosition.x = ((-((float)NUM_COLUMNS) / 2.0) + column) * QUAD_SPACING + QUAD_SPACING/2.0;
            upperLeftPosition.y = ((-((float)NUM_ROWS) / 2.0) + row) * QUAD_SPACING + QUAD_SPACING/2.0;
            
            memcpy(currentQuad, &quadVertices, sizeof(quadVertices));
            
            for (NSUInteger vertexInQuad = 0; vertexInQuad < NUM_VERTICES_PER_QUAD; vertexInQuad++)
            {
                currentQuad[vertexInQuad].position += upperLeftPosition;
            }
            
            currentQuad += 6;
        }
    }
    return vertexData;
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
        
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.numVertices];
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
    
}

@end
