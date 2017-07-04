//
//  ISIDReaderResultViewController.h
//  ISIDReaderPreview
//
//  Created by 汪凯 on 15/11/13.
//  Copyright © 2015年 汪凯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISIDReaderResultViewController : UIViewController

@property (strong, nonatomic)  NSString *positivePic;
@property(nonatomic,strong) UIWebView *webView;

- (instancetype)initWithDictionary:(NSDictionary *)info;

@end
