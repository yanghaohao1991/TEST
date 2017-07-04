//
//  AppDelegate.m
//  AnyChatSDKTest
//
//  Created by Clover on 15/6/11.
//  Copyright (c) 2015年 Thinkive. All rights reserved.
//

#import "AppDelegate.h"
#import "YCViewController.h"
#import "RxWebViewNavigationViewController.h"
#import "RxWebViewController.h"
#import "IntroduceViewController.h"
#import "NSUserDefaults+Additions.h"
#import <Bugtags/Bugtags.h>


//分享功能
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import "WechatManger.h"
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BugtagsOptions *options = [[BugtagsOptions alloc] init];
    options.trackingCrashes = YES; // 具体可设置的属性请查看 Bugtags.h
    options.crashWithScreenshot = YES;
    options.trackingConsoleLog = YES;
    [Bugtags startWithAppKey:@"0a998403baf7ac147181be4140d3504f" invocationEvent:BTGInvocationEventNone options:options];
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:@"1e8f91a6b471c"
     
          activePlatforms:@[
//                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ),]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
//             case SSDKPlatformTypeSinaWeibo:
//                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
//                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
//             case SSDKPlatformTypeSinaWeibo:
//                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
//                 [appInfo SSDKSetupSinaWeiboByAppKey:@"3722934383"
//                                           appSecret:@"43167b2c49c11de9703a88ddd2f0495e"
//                                         redirectUri:@"http://www.firstcapital.com.cn"
//                                            authType:SSDKAuthTypeBoth];
//                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wxcc09640365636fc1"
                                       appSecret:@"67a3ca62b84557b4f89e0cd6510d6c16"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1106223514"
                                      appKey:@"N8DasPJqpGIXgAzI"
                                    authType:SSDKAuthTypeBoth];
                 break;

             default:
                 break;
         }
     }];
    
    
    [WXApi registerApp:@"wxcc09640365636fc1"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSDictionary *defaults = @{
                               @"name_preference": kHHost};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([[NSUserDefaults standardUserDefaults] isFirstLoad] ) {
        IntroduceViewController *guideVC = [[IntroduceViewController alloc]init];
        self.window.rootViewController = guideVC;
    }else{
#ifdef Integration
        RxWebViewNavigationViewController *nav = [[RxWebViewNavigationViewController alloc]initWithRootViewController:[[RxWebViewController alloc]initWithUrl:[NSURL URLWithString:kHHost]]];
#else
        RxWebViewNavigationViewController *nav = [[RxWebViewNavigationViewController alloc]initWithRootViewController:[[RxWebViewController alloc]init]];
#endif
        self.window.rootViewController = nav;
        
    }
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [self cleanCacheAndCookie];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [self cleanCacheAndCookie];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

NSString *wakeUpURL;
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url scheme] isEqualToString:@"open"])
    {
        wakeUpURL = [url absoluteString];
        YCViewController *vc = (YCViewController *)self.window.rootViewController;
        [vc loadUrl];
    }
    if ([WXApi handleOpenURL:url delegate:(id)[WechatManger sharedManager]]) {
        return YES;
    }
    return YES;
}

//统一链接处理
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webpageURL = userActivity.webpageURL;
        NSString *host = webpageURL.host;
        if ([host isEqualToString:@"www.fcsc.com"]) {
            //进行我们需要的处理
            NSString * parameterString = webpageURL.absoluteString ;
            NSArray  *arr = [parameterString componentsSeparatedByString:@"?"];
            parameterString = arr[1]?arr[1]:@"";
            YCViewController *vc = (YCViewController *)self.window.rootViewController;
            [vc loadUrl:parameterString];
        }
        else {
            // [[UIApplication sharedApplication]openURL:webpageURL];
        }
        
    }
    return YES;
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([WXApi handleOpenURL:url delegate:(id)[WechatManger sharedManager]]) {
        return YES;
    }
    return YES;
}

@end
