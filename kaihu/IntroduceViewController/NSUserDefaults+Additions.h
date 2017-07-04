//
//  NSUserDefaults+Additions.h
//  ASK
//
//  Created by zhuanghaishao on 14-8-25.
//  Copyright (c) 2014年 yiyaowang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Additions)

- (BOOL) isFirstLoad;
- (BOOL) isFirstLoadHome;
- (BOOL) isFirstLoadCustomer;
- (BOOL) isFirstLoadFind;
- (BOOL) isFirstLaunch;
- (void)launchStatus:(NSMutableDictionary*)dict;
- (NSMutableDictionary *)getLaunchStatus;
- (void )removeLaunchStatus;
- (void)saveLaunchValue:(NSMutableDictionary*)dict;
- (NSMutableDictionary *)getLaunchValue;
- (void)saveImage:(NSString*)str;
@end
