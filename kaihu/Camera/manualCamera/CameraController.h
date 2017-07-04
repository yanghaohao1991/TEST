//
//  CardViewController.h
//  AnyChatSDKTest
//
//  Created by yanghaohao on 2017/2/7.
//  Copyright © 2017年 Thinkive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraController : UIViewController

@property(nonatomic,strong) UIWebView *webView;

@property(nonatomic,strong) NSString *positivePic;

@property (strong, nonatomic) UIImageView *IDCardImage;

-(void)changeOrientationF;
-(void)changeOrientationB;

@end
