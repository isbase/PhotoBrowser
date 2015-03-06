//
//  HHImageCompat.h
//  PhotoBrowser
//
//  Created by Today on 15-3-6.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import <Foundation/Foundation.h>



#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


@interface HHImageCompat : NSObject

@end
