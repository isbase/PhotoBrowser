//
//  HHWebImageDownLoader.h
//  PhotoBrowser
//
//  Created by Today on 15-3-6.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^HHWebImageDownLoaderCompleteBlock)(UIImage *image,NSData *data,NSError *error,BOOL finished);


@interface HHWebImageDownLoader : NSObject

/*
 * 下载器单例
 */
+(HHWebImageDownLoader *)shareDownLoader;

/*
 * 下载方法
 */
-(id)downloadImageWithURL:(NSURL *)url imageTypes:(NSInteger )type completed:(HHWebImageDownLoaderCompleteBlock)completeBlock;

@end
