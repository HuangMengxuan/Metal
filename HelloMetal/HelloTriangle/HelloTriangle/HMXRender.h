//
//  HMXRender.h
//  DeviceAndCommand
//
//  Created by meitu on 2018/7/24.
//  Copyright © 2018年 meitu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

@interface HMXRender : NSObject <MTKViewDelegate>
    
- (instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end
