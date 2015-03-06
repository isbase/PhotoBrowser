//
//  HHWebImageDownLoader.m
//  PhotoBrowser
//
//  Created by Today on 15-3-6.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import "HHWebImageDownLoader.h"

@implementation HHWebImageDownLoader

+ (HHWebImageDownLoader *)shareDownLoader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

-(id)downloadImageWithURL:(NSURL *)url imageTypes:(NSInteger)type completed:(HHWebImageDownLoaderCompleteBlock)completeBlock
{
    
 
    NSURLConnection *connect = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:nil];
    

    [NSURLConnection sendAsynchronousRequest:<#(NSURLRequest *)#> queue:<#(NSOperationQueue *)#> completionHandler:<#^(NSURLResponse *response, NSData *data, NSError *connectionError)handler#>]
    
    
    return nil;
}
@end
