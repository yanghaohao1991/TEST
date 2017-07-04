//
//  WechatManger.h
//  AnyChatSDKTest
//
//  Created by yanghaohao on 2017/3/20.
//  Copyright © 2017年 Thinkive. All rights reserved.
//

#import "WXApi.h"
#import <UIKit/UIKit.h>

@interface WechatManger : NSObject

@property(nonatomic,strong) UIWebView* webView;


+(instancetype)sharedManager;

+ (void)sendAuthRequest;

@end
