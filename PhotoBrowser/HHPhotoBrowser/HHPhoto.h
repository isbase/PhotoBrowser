//
//  HHPhoto.h
//  PhotoBrowser
//
//  Created by Today on 15-1-22.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHPhotoProtocol.h"
@interface HHPhoto : NSObject <HHPhotoProtocol>

//可选属性
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSURL *photoURL;

//便利构造函数
+ (HHPhoto *)photoWithImage:(UIImage *)image;
+ (HHPhoto *)photoWithURL:(NSURL *)url;

//普通初始化函数
- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;

@end
