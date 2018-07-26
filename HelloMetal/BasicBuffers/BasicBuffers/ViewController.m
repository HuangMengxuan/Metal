//
//  ViewController.m
//  BasicBuffers
//
//  Created by meitu on 2018/7/26.
//  Copyright © 2018年 meitu. All rights reserved.
//

#import "ViewController.h"
#import "HMXRender.h"

@interface ViewController ()

@property (strong, nonatomic) MTKView *mtkView;
@property (strong, nonatomic) HMXRender *render;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView = (MTKView *)self.view;
    
    // 获取设备的默认GPU对象
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    
    if (!self.mtkView.device) {
        NSLog(@"Metal is not supported on this device!");
        return;
    }
    
    self.render = [[HMXRender alloc] initWithMetalKitView:self.mtkView];
    
    if (!self.render) {
        NSLog(@"Renderer failed initializetion!");
        return;
    }
    
    [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    
    self.mtkView.delegate = self.render;
    
    self.mtkView.preferredFramesPerSecond = 60;
}

@end
