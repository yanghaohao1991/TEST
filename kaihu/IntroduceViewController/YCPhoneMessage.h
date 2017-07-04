//
//  YCPhoneMessage.h
//  AnyChatSDKTest
//
//  Created by yanghaohao on 2017/6/21.
//  Copyright © 2017年 Thinkive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCPhoneMessage : UIView

+ (NSString *)iphoneType;

//获取网络环境
+(NSString *)networktype;

//获取运营商
+(NSString *)getcarrierName;
   

@end
