//
//  HHPhotoProtocol.h
//  PhotoBrowser
//
//  Created by Today on 15-1-22.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HHPHOTO_LOADING_DID_END_NOTIFICATION @"HHPHOTO_LOADING_DID_END_NOTIFICATION"

@protocol HHPhotoProtocol <NSObject>


@required
//这是要被显示的图片
@property(nonatomic,retain)UIImage  *underlyingImage;

//这里需要加载underlyingImage到内存
-(void)loadUnderlyingImageAndNotify;

//读取或者网络加载图片
- (void)performLoadUnderlyingImageAndNotify;

// 不再使用的时候清理
- (void)unloadUnderlyingImage;

@optional

// Cancel any background loading of image data
- (void)cancelAnyLoading;
@end
