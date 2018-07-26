//
//  HMXImage.h
//  BasicTexturing
//
//  Created by meitu on 2018/7/26.
//  Copyright © 2018年 meitu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMXImage : NSObject

- (instancetype)initWithTGAFileUrl:(NSURL *)fileUrl;

// Width of image in pixels
@property (nonatomic, readonly) NSUInteger      width;

// Height of image in pixels
@property (nonatomic, readonly) NSUInteger      height;

// Image data in 32-bits-per-pixel (bpp) BGRA form (which is equivalent to MTLPixelFormatBGRA8Unorm)
@property (nonatomic, readonly, nonnull) NSData *data;

@end
