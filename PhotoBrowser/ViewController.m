//
//  ViewController.m
//  PhotoBrowser
//
//  Created by Today on 15-1-22.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import "ViewController.h"

#import "HHFullScreenViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)onButtonClick:(id)sender {
    
    NSArray *images = @[@"http://a.hiphotos.baidu.com/image/pic/item/eaf81a4c510fd9f9dffb233e262dd42a2934a4fc.jpg",
                        @"http://h.hiphotos.baidu.com/image/pic/item/64380cd7912397ddc6e0afa75b82b2b7d1a287f3.jpg",
                        @"http://h.hiphotos.baidu.com/image/pic/item/6c224f4a20a446233e9e92c19a22720e0cf3d738.jpg",
                        @"http://e.hiphotos.baidu.com/image/pic/item/ac345982b2b7d0a26050333ec9ef76094a369af3.jpg",
                        @"http://d.hiphotos.baidu.com/image/pic/item/77094b36acaf2eddd08f7e4a8f1001e939019312.jpg",
                        @"http://d.hiphotos.baidu.com/image/pic/item/3801213fb80e7bec2fa434422d2eb9389b506b12.jpg",
                        @"http://g.hiphotos.baidu.com/image/pic/item/6f061d950a7b0208659e084260d9f2d3572cc839.jpg",
                        @"http://h.hiphotos.baidu.com/image/pic/item/f703738da977391214ffee75fb198618377ae2cd.jpg",
                        @"http://f.hiphotos.baidu.com/image/pic/item/b8014a90f603738d0c936736b01bb051f919eccd.jpg",
                        @"http://c.hiphotos.baidu.com/image/pic/item/3812b31bb051f8192cfc685ed9b44aed2f73e7cd.jpg",
                        @"http://f.hiphotos.baidu.com/image/pic/item/f9198618367adab4e709705788d4b31c8601e4cd.jpg",
                        @"http://pic3.nipic.com/20090601/2348350_185513072_2.jpg",
                        @"http://e.hiphotos.baidu.com/image/pic/item/83025aafa40f4bfb6706f8e9004f78f0f63618bc.jpg"];
    
    HHFullScreenViewController *fullscreen = [[HHFullScreenViewController alloc] initWithPhotos:images];
    [self presentViewController:fullscreen animated:YES completion:nil];
    [fullscreen release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
