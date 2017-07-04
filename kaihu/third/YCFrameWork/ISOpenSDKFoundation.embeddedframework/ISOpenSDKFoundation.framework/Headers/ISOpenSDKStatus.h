//
//  ISSDKStatus.h
//  ISSDK
//
//  Created by Felix on 15/3/23.
//  Copyright (c) 2015年 IntSig. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ISOpenSDKStatus)
{
    ISOpenSDKStatusUnauthorized = -1,//unauthorized(未授权)
    ISOpenSDKStatusSuccess,//auth success(授权成功)
    ISOpenSDKStatusUnreachable,//auth info uncreachable, network error(无法获取授权信息，网络问题)
    ISOpenSDKStatusDeviceIDError,//wrong device ID(错误的设备号)
    ISOpenSDKStatusAppIDError,//wrong app ID(错误的app ID)
    ISOpenSDKStatusAppKeyError,//wrong app key(错误的app key)
    ISOpenSDKStatusAuthExpiredError,//auth time expire(授权过期)
    ISOpenSDKStatusDeviceCappedError,//reach device limit(达到设备上限)
    ISOpenSDKStatusDetectCappedError,//reach detect limit(达到识别额度上限)
    ISOpenSDKStatusSubAppKeyError,//wrong sub app key, unused now(错误的sub app key，暂时无用)
    ISOpenSDKStatusUnsupportedAuthError,//unsupported auth error(不支持的错误)
    ISOpenSDKStatusAuthorizeInfoError,//server return wrong authorize info(服务器返回错误的授权信息)
    ISOpenSDKStatusConstructResourceError,//construct resource error, unused now(初始化资源失败，暂时无用)
    ISOpenSDKStatusVersionError//wrong sdk type(错误的SDK库)
};

