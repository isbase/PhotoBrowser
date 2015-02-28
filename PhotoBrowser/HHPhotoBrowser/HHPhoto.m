//
//  HHPhoto.m
//  PhotoBrowser
//
//  Created by Today on 15-1-22.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import "HHPhoto.h"
#import "EGOImageLoader.h"
//#import "SDWebImageManager.h"

@implementation HHPhoto
{
    BOOL _loadingInProgress;
}
@synthesize underlyingImage = _underlyingImage;

//便利构造函数
+ (HHPhoto *)photoWithImage:(UIImage *)image{
    return [[[HHPhoto alloc] initWithImage:image] autorelease];
}
+ (HHPhoto *)photoWithURL:(NSURL *)url{
    return [[[HHPhoto alloc] initWithURL:url] autorelease];
}

#pragma mark - Init
- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        _image = image;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        _photoURL = [url copy];
    }
    return self;
}

#pragma mark - HHPhoto Protocol Methods

-(UIImage *)underlyingImage{
    return _underlyingImage;
}

-(void)loadUnderlyingImageAndNotify
{
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}


-(void)performLoadUnderlyingImageAndNotify{
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        [self imageLoadingComplete];
        
    }else{
        if ([_photoURL isFileReferenceURL]) {
            
            // Load from local file async
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    @try {
                        self.underlyingImage = [UIImage imageWithContentsOfFile:_photoURL.path];
                    } @finally {
                        [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                    }
                }
            });
            
        } else {
            
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:_photoURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
               
                if (connectionError == nil) {
                    UIImage *imageFromData = [[UIImage alloc] initWithData:data];
                    if (imageFromData != NULL && imageFromData != nil && data.length > 0) {
                        self.underlyingImage = imageFromData;
                        [imageFromData release];
                    } else {
                        self.underlyingImage = nil;
                    }
                }else{
                    self.underlyingImage = nil;
                }
                [self imageLoadingComplete];
            }];
        }
    }
}
- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:HHPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

-(void)unloadUnderlyingImage
{
    self.underlyingImage = nil;
}

@end
