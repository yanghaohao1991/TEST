//
//  RxWebViewController.h
//  RxWebViewController
//
//  Created by roxasora on 15/10/23.
//  Copyright © 2015年 roxasora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TKAnyChat/FCChatControllerAC.h>
#import "CameraController.h"
#import "CardViewController.h"

@protocol RxWebViewControllerProtocol <NSObject>

@optional
- (void)goBackLastViewController;
@end

@interface RxWebViewController : UIViewController

/**
 *  origin url
 */
@property (nonatomic)NSURL* url;

/**
 *  embed webView
 */
@property(nonatomic,strong) UIWebView* webView;

/**
 *  tint color of progress view
 */
@property (nonatomic)UIColor* progressViewColor;

@property(nonatomic,strong) CameraController *cameraVC;
@property(nonatomic,strong) CardViewController *autoVC;
@property(nonatomic,strong) UIImagePickerController *imagePickerController;
@property(nonatomic,assign)id<RxWebViewControllerProtocol>delegate;



/**
 *  get instance with url
 *
 *  @param url url
 *
 *  @return instance
 */
-(instancetype)initWithUrl:(NSURL*)url;


-(void)reloadWebView;

@end



