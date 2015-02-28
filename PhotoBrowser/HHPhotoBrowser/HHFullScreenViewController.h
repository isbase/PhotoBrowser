//
//  HHFullScreenViewController.h
//  PhotoBrowser
//
//  Created by Today on 15-1-22.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHPhoto.h"
#import "HHPhotoProtocol.h"
@interface HHFullScreenViewController : UIViewController<UIScrollViewDelegate>


- (id)initWithPhotos:(NSArray *)photosArray;

- (UIImage *)imageForPhoto:(id<HHPhotoProtocol>)photo;

-(void)sigleFingerTouch;
@end
