//
//  NSUserDefaults+Additions.m
//  ASK
//
//  Created by zhuanghaishao on 14-8-25.
//  Copyright (c) 2014年 yiyaowang. All rights reserved.
//

#import "NSUserDefaults+Additions.h"

#define LAST_RUN_VERSION_KEY @"lastVersion"
#define LAST_RUN_LAUNCH_KEY @"lastLaunch"
#define LASTHOME_RUN_VERSION_KEY @"lastVersionhome"
#define LASTcustomer_RUN_VERSION_KEY @"lastVersioncustomer"
#define LASTFind_RUN_VERSION_KEY @"lastVersionFind"

@implementation NSUserDefaults (Additions)

//APP首次启动或者更新后首次启动
- (BOOL) isFirstLoad{
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleVersion"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRunVersion = [defaults objectForKey:LAST_RUN_VERSION_KEY];
    
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        [defaults synchronize];
        return YES;
        // App is being run for first time
    }
    else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        [defaults synchronize];
        return YES;
        // App has been updated since last run
    }
    return NO;
}

//APP首次启动或者更新后首次启动
- (BOOL) isFirstLoadHome{
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleVersion"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRunVersion = [defaults objectForKey:LASTHOME_RUN_VERSION_KEY];
    
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LASTHOME_RUN_VERSION_KEY];
        [defaults synchronize];
        return YES;
        // App is being run for first time
    }
    else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:LASTHOME_RUN_VERSION_KEY];
        [defaults synchronize];
        return YES;
        // App has been updated since last run
    }
    return NO;
}

//APP首次启动或者更新后首次启动
- (BOOL) isFirstLoadCustomer{
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleVersion"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRunVersion = [defaults objectForKey:LASTcustomer_RUN_VERSION_KEY];
    
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LASTcustomer_RUN_VERSION_KEY];
        [defaults synchronize];
        return YES;
        // App is being run for first time
    }
    else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:LASTcustomer_RUN_VERSION_KEY];
        [defaults synchronize];
        return YES;
        // App has been updated since last run
    }
    return NO;
}

//APP首次启动或者更新后首次启动
- (BOOL) isFirstLoadFind{
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleVersion"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRunVersion = [defaults objectForKey:LASTFind_RUN_VERSION_KEY];
    
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LASTFind_RUN_VERSION_KEY];
        [defaults synchronize];
        return YES;
        // App is being run for first time
    }
    else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:LASTFind_RUN_VERSION_KEY];
        [defaults synchronize];
        return YES;
        // App has been updated since last run
    }
    return NO;
}

- (BOOL) isFirstLaunch{
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleVersion"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRunVersion = [defaults objectForKey:LAST_RUN_LAUNCH_KEY];
    
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LAST_RUN_LAUNCH_KEY];
        [defaults synchronize];
        return YES;
        // App is being run for first time
    }
    else{
        return NO;
    }
    return NO;
}

- (void)launchStatus:(NSMutableDictionary*)dict{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[dict objectForKey:@"jumpFlag"] forKey:@"jumpFlag"];
    [defaults setObject:[dict objectForKey:@"title"] forKey:@"title"];
    [defaults setObject:[dict objectForKey:@"url"] forKey:@"url"];
    [defaults synchronize];
}

- (void)saveLaunchValue:(NSMutableDictionary*)dict{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[dict objectForKey:@"img_id"] forKey:@"img_id"];
    [defaults setObject:[dict objectForKey:@"ad_url"] forKey:@"ad_url"];
    [defaults setObject:[dict objectForKey:@"ad_title"] forKey:@"ad_title"];
    [defaults synchronize];
}

- (NSMutableDictionary *)getLaunchValue{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *img_id = [defaults objectForKey:@"img_id"];
    NSString *ad_url = [defaults objectForKey:@"ad_url"];
    NSString *ad_title = [defaults objectForKey:@"ad_title"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:img_id forKey:@"img_id"];
    [dict setValue:ad_url forKey:@"ad_url"];
    [dict setValue:ad_title forKey:@"ad_title"];
    return dict;
}


- (NSMutableDictionary *)getLaunchStatus{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *jumpFlag = [defaults objectForKey:@"jumpFlag"];
    NSString *title = [defaults objectForKey:@"title"];
    NSString *url = [defaults objectForKey:@"url"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:jumpFlag forKey:@"jumpFlag"];
    [dict setValue:title forKey:@"title"];
    [dict setValue:url forKey:@"url"];
    return dict;
}


- (void )removeLaunchStatus{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"jumpFlag"];
    [defaults setObject:@"" forKey:@"title"];
    [defaults setObject:@"" forKey:@"url"];
    [defaults synchronize];
}

- (void)saveImage:(NSString*)str{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:str forKey:@"launchImage"];
    [defaults synchronize];
}


@end
