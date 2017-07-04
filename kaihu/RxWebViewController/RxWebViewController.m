//
//  RxWebViewController.m
//  RxWebViewController
//
//  Created by roxasora on 15/10/23.
//  Copyright © 2015年 roxasora. All rights reserved.
//

#import "RxWebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import <CoreLocation/CoreLocation.h>
#import "YCPhoneMessage.h"

#define boundsWidth self.view.bounds.size.width
#define boundsHeight self.view.bounds.size.height

//#import <tztMobileBase/tztMobileBase.h>
//#import "LSActionSheet.h"
#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height
#import<AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import<AssetsLibrary/AssetsLibrary.h>
#import<CoreLocation/CoreLocation.h>
#import "JXActionSheet.h"
#import "ODRefreshControl.h"
#import "JDragonHUD.h"
//#import "WXApi.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]
#define WeakSelf __weak typeof(self) weakSelf = self;

//分享sdk


#ifdef Integration

#else
#import "WechatManger.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#endif

@interface RxWebViewController ()<UIWebViewDelegate,UINavigationControllerDelegate,UINavigationBarDelegate,NJKWebViewProgressDelegate,UIImagePickerControllerDelegate,FCChatResultDelegate>{
//    CardViewController *autoVC;
//    CameraController *manualVC;
//    UIImagePickerController *imagePickerController;
    NSString *libraryType;
    NSString *callbackFuncName;
    JXActionSheet *sheet;
    ODRefreshControl *refreshContr;
}

@property (nonatomic)UIBarButtonItem* customBackBarItem;
@property (nonatomic)UIBarButtonItem* closeButtonItem;
@property (nonatomic)UIBarButtonItem* connectButtonItem;
@property (nonatomic)NJKWebViewProgress* progressProxy;
@property (nonatomic)NJKWebViewProgressView* progressView;
@property (nonatomic, strong) CLLocationManager *locationMgr;

/**
 *  array that hold snapshots
 */
@property (nonatomic)NSMutableArray* snapShotsArray;

/**
 *  current snapshotview displaying on screen when start swiping
 */
@property (nonatomic)UIView* currentSnapShotView;

/**
 *  previous view
 */
@property (nonatomic)UIView* prevSnapShotView;

/**
 *  background alpha black view
 */
@property (nonatomic)UIView* swipingBackgoundView;

/**
 *  left pan ges
 */
@property (nonatomic)UIPanGestureRecognizer* swipePanGesture;

/**
 *  if is swiping now
 */
@property (nonatomic)BOOL isSwipingBack;

@end

@implementation RxWebViewController

-(UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - init
-(instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        self.url = url;
        _progressViewColor = UIColorFromHex(0x1870d2);
    }
    return self;
}





- (void)viewDidLoad{
    [super viewDidLoad];
   
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(ImageByOCR:) name:@"ImageByOCR" object:nil];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    manualVC = [storyboard instantiateViewControllerWithIdentifier:@"ViewControllerID"];
//    self.cameraVC = manualVC;
    
    self.cameraVC =  [[CameraController alloc]init];
    
    self.autoVC = [[CardViewController alloc]init];
    self.imagePickerController = [[UIImagePickerController alloc] init];
    _progressViewColor = UIColorFromHex(0x1870d2);

    
    self.title = @"";
    self.webView.backgroundColor = [UIColor whiteColor];
    
    //config navigation item
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.webView.delegate = self.progressProxy;
    [self.view addSubview:self.webView];
 
    [self loadURL];
    [self.navigationController.navigationBar addSubview:self.progressView];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        self.locationMgr = [[CLLocationManager alloc] init];
        
        //获取授权认证
        [self.locationMgr requestAlwaysAuthorization];
        [self.locationMgr requestWhenInUseAuthorization];
    }
    
    // Do any additional setup after loading the view.
    sheet = [[JXActionSheet alloc] initWithTitle:nil cancelTitle:@"取消" otherTitles:@[@"自动扫描(推荐)",@"手动拍照",@"从手机相册选择"]];
    [self addCCEaseRefresh];

}

-(void)loadURL{
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    //2.手机类型：iPhone 6
    NSString* phoneModel = [YCPhoneMessage iphoneType];//方法在下面
    NSString* networktype = [YCPhoneMessage networktype];//网络环境
    NSString* carrierName = [YCPhoneMessage getcarrierName];//运营商
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];// app版本
    NSString* dd = [NSString stringWithFormat:@"ap=1&dd=%@|%@|%@%@", phoneModel,phoneVersion,carrierName,networktype];//方法在下面
    
#ifdef Distribution
    NSString *host_url = [NSString stringWithFormat:@"%@%@&av=%@", kHHost,dd,app_Version];
#elif defined Integration
    NSString *host_url = [NSString stringWithFormat:@"%@%@&av=%@", self.url,dd,app_VersionIntegration];
#else
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *host_url = [NSString stringWithFormat:@"%@%@&av=%@", [defaults stringForKey:@"name_preference"],dd,app_Version];
#endif
    
    self.url = [[NSURL alloc] initWithString:[host_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request =[NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
    [self.webView loadRequest:request];
}

-(void)addCCEaseRefresh{
    refreshContr = [[ODRefreshControl alloc] initInScrollView:self.webView.scrollView];
    [refreshContr addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.progressView removeFromSuperview];
    //    self.webView.delegate = nil;
}



#pragma mark - public funcs
-(void)reloadWebView{
    [self.webView reload];
}

#pragma mark - logic of push and pop snap shot views
-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    //    NSLog(@"push with request %@",request);
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    //如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        //        NSLog(@"about blank!! return");
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    
    UIView* currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:
     @{
       @"request":request,
       @"snapShotView":currentSnapShotView
       }
     ];
    //    NSLog(@"now array count %d",self.snapShotsArray.count);
}

-(void)startPopSnapshotView{
    if (self.isSwipingBack) {
        return;
    }
    if (!self.webView.canGoBack) {
        return;
    }
    self.isSwipingBack = YES;
    //create a center of scrren
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    //add shadows just like UINavigationController
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = (UIView*)[[self.snapShotsArray lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.prevSnapShotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapShotView];
}

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    prevSnapshotViewCenter.x -= (boundsWidth - distance)*60/boundsWidth;
    //    NSLog(@"prev center x%f",prevSnapshotViewCenter.x);
    
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (boundsWidth - distance)/boundsWidth;
}

-(void)endPopSnapShotView{
    if (!self.isSwipingBack) {
        return;
    }
    
    //prevent the user touch for now
    self.view.userInteractionEnabled = NO;
    
    if (self.currentSnapShotView.center.x >= boundsWidth) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(boundsWidth*3/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.swipingBackgoundView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            [self.webView goBack];
            [self.snapShotsArray removeLastObject];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }else{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.currentSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2-60, boundsHeight/2);
            self.prevSnapShotView.alpha = 1;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}

#pragma mark - update nav items

-(void)updateNavigationItems{
    if (self.webView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//                UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(customBackItemClicked)];
//                self.navigationItem.leftBarButtonItem = leftItem;
        
        
        //弃用customBackBarItem，使用原生backButtonItem
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.customBackBarItem,self.closeButtonItem] animated:NO];
        
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
#ifdef Integration
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem] animated:NO];
#else
        [self.navigationItem setLeftBarButtonItems:nil];
#endif

    }
    [self.navigationItem setRightBarButtonItems:@[self.connectButtonItem] animated:NO];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16],NSFontAttributeName, nil] forState:UIControlStateNormal];
}

#pragma mark - events handler
-(void)swipePanGestureHandler:(UIPanGestureRecognizer*)panGesture{
    CGPoint translation = [panGesture translationInView:self.webView];
    CGPoint location = [panGesture locationInView:self.webView];
    //    NSLog(@"pan x %f,pan y %f",translation.x,translation.y);
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 50 && translation.x > 0) {  //开始动画
            [self startPopSnapshotView];
        }
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        [self endPopSnapShotView];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}

-(void)customBackItemClicked{
    if (self.webView.canGoBack){
        [self.webView goBack];
    }else{
        if ([_delegate respondsToSelector:@selector(goBackLastViewController)] ) {
            [_delegate goBackLastViewController];
        }
    }
}

-(void)closeItemClicked{
    // 返回首页
    for (int i = 0; i < 20; i++) {
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        }
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

-(void)connectItemClicked{
    [self.webView stringByEvaluatingJavaScriptFromString:@"contactService()"];
}

#pragma mark - webView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    //    NSLog(@"navigation type %d",navigationType);
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeBackForward: {
            break;
        }
        case UIWebViewNavigationTypeReload: {
            break;
        }
        case UIWebViewNavigationTypeFormResubmitted: {
            break;
        }
        case UIWebViewNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    __block NSString *strUrl = [[request URL] absoluteString];
    if ([[[request URL] absoluteString] rangeOfString:@"http://action"].location !=NSNotFound)
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SystemPlugin" ofType:@"plist"];
        NSMutableDictionary *plugins = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSString *strUrlS =[strUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSRange pathRang = [strUrlS rangeOfString:@"?"];
        strUrlS = [strUrlS substringToIndex:pathRang.location];
        strUrlS = [strUrlS substringWithRange:NSMakeRange(pathRang.location-6,5)];//截取范围类的字符串
        if ([plugins objectForKey:strUrlS]) {
            //调用相册
            if ([strUrl rangeOfString:@"10051"].location !=NSNotFound) {
                [sheet showView];
                WeakSelf;
                [sheet dismissForCompletionHandle:^(NSInteger index, BOOL isCancel) {
                    if (index==0) {
                        //相机权限
                        AVAuthorizationStatus authStatus = [AVCaptureDevice
                                                            authorizationStatusForMediaType:AVMediaTypeVideo];
                        if (authStatus ==AVAuthorizationStatusRestricted ||//此应用程序没有被授权访问的照片数据。可能是家长控制权限
                            authStatus ==AVAuthorizationStatusDenied)  //用户已经明确否认了这一照片数据的应用程序访问
                        {
                            // 无权限 引导去开启
                            NSURL *url2 = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            if ([[UIApplication sharedApplication]canOpenURL:url2]) {
                                [[UIApplication sharedApplication]openURL:url2];
                            }
                        }
                        
                        NSRange pathRang = [strUrl rangeOfString:@"?"];
                        strUrl = [strUrl substringFromIndex:pathRang.location+pathRang.length];
                        NSMutableDictionary *pDict = [self GetRequestPram:strUrl];
                        NSString *type =[pDict objectForKey:@"type"];
                        
                        weakSelf.autoVC.webView = weakSelf.webView;
                        weakSelf.autoVC.positivePic = type;
                        //                [self presentViewController:vc animated:YES completion:^{
                        //
                        //                }];
                        UIBarButtonItem *backIetm = [[UIBarButtonItem alloc] init];
                        backIetm.title =@"返回";
                        weakSelf.navigationItem.backBarButtonItem = backIetm;
                        [weakSelf.navigationController pushViewController:weakSelf.autoVC animated:NO];
                    }
                    else if(index==1){
                        //相机权限
                        AVAuthorizationStatus authStatus = [AVCaptureDevice
                                                            authorizationStatusForMediaType:AVMediaTypeVideo];
                        if (authStatus ==AVAuthorizationStatusRestricted ||//此应用程序没有被授权访问的照片数据。可能是家长控制权限
                            authStatus ==AVAuthorizationStatusDenied)  //用户已经明确否认了这一照片数据的应用程序访问
                        {
                            // 无权限 引导去开启
                            NSURL *url2 = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            if ([[UIApplication sharedApplication]canOpenURL:url2]) {
                                [[UIApplication sharedApplication]openURL:url2];
                            }
                        }
                        
                        
                        NSRange pathRang = [strUrl rangeOfString:@"?"];
                        strUrl = [strUrl substringFromIndex:pathRang.location+pathRang.length];
                        NSMutableDictionary *pDict = [self GetRequestPram:strUrl];
                        NSString *type =[pDict objectForKey:@"type"];
                        
                        weakSelf.cameraVC.webView = weakSelf.webView;
                        weakSelf.cameraVC.positivePic = type;
                        UIBarButtonItem *backIetm = [[UIBarButtonItem alloc] init];
                        backIetm.title =@"返回";
                        weakSelf.navigationItem.backBarButtonItem = backIetm;
                        [weakSelf.navigationController pushViewController:weakSelf.cameraVC animated:NO];
                    }
                    else if(index==2){
                        NSRange pathRang = [strUrl rangeOfString:@"?"];
                        strUrl = [strUrl substringFromIndex:pathRang.location+pathRang.length];
                        NSMutableDictionary *pDict = [self GetRequestPram:strUrl];
                        libraryType =[pDict objectForKey:@"type"];
                        
                        // 跳转到相机或相册页面
                        weakSelf.imagePickerController.delegate = weakSelf;
                        weakSelf.imagePickerController.allowsEditing = NO;
                        weakSelf.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        
                        [weakSelf presentViewController:weakSelf.imagePickerController animated:YES completion:^{
                            
                        }];
                    }
                    else{
                        
                    }
                    
                }];
                
                return NO;
            }
            
#ifdef Integration
            
#else
            if ([[[request URL] absoluteString] rangeOfString:@"20002"].location !=NSNotFound)
            {
                /**
                 *  设置分享参数
                 *
                 *  @param content     分享内容
                 *  @param images   图片base64
                 *  @param url      网页路径/应用路径
                 *  @param title    标题
                 *  @param demo @"http://action:20002/?content=xxxxxxx&&images=xxxxxx&&url=xxxxxxxx&&title=xxxxxxxx"
                 */
                //1、创建分享参数
                NSString *strUrlS =[strUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSRange pathRang = [strUrlS rangeOfString:@"?"];
                strUrlS = [strUrlS substringFromIndex:pathRang.location+pathRang.length];
                NSString *content =[self GetRequestPram:strUrlS key:@"content"];
                NSString *images =[self GetRequestPram:strUrlS key:@"images"];
                NSString *urlW =[self GetRequestPram:strUrlS key:@"url"];
                NSString *title =[self GetRequestPram:strUrlS key:@"title"];
                NSData *_decodedImageData   =  [[NSData alloc] initWithBase64EncodedString:images   options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *_decodedImage      = [UIImage imageWithData:_decodedImageData];
                NSArray* imageArray = @[_decodedImage];
                if (imageArray) {
                    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                    [shareParams SSDKSetupShareParamsByText:content.length>0?content:nil
                                                     images:imageArray
                                                        url:urlW.length>0?[NSURL URLWithString:urlW]:nil
                                                      title:title.length>0?title:nil
                                                       type:SSDKContentTypeAuto];
                    //            [shareParams SSDKSetupSinaWeiboShareParamsByText:content.length>0?content:nil title:title.length>0?title:nil image:imageArray url:urlW.length>0?[NSURL URLWithString:urlW]:nil latitude:1.2 longitude:l objectID:nil type:SSDKContentTypeAuto];
                    //有的平台要客户端分享需要加此方法，例如微博
                    [shareParams SSDKEnableUseClientShare];
                    //2、分享（可以弹出我们的分享菜单和编辑界面）
                    [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                             items:nil
                                       shareParams:shareParams
                               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                                   
                                   switch (state) {
                                       case SSDKResponseStateSuccess:
                                       {
                                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                               message:nil
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"确定"
                                                                                     otherButtonTitles:nil];
                                           [alertView show];
                                           break;
                                       }
                                       case SSDKResponseStateFail:
                                       {
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                           message:[NSString stringWithFormat:@"%@",error]
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:@"OK"
                                                                                 otherButtonTitles:nil, nil];
                                           [alert show];
                                           break;
                                       }
                                       default:
                                           break;
                                   }
                               }
                     ];
                }
                return NO;
                
            }
            
#endif
            
            
            //调用视频控件
            if([strUrl rangeOfString:@"10050"].location !=NSNotFound)
            {
                NSRange pathRang = [strUrl rangeOfString:@"?"];
                strUrl = [strUrl substringFromIndex:pathRang.location+pathRang.length];
                NSMutableDictionary *pDict = [self GetRequestPram:strUrl];
                
                // NSMutableDictionary *pDict = [strUrl tztNSMutableDictionarySeparatedByString:@"&&"];
                NSString *hosturl =[pDict objectForKey:@"hostUrl"];
                NSString *userid =[pDict objectForKey:@"userId"];
                NSString *jsessionIdpram =[pDict objectForKey:@"jsessionIdpram"];
                NSString *nickname =[pDict objectForKey:@"nickName"];
                NSString *orgid =[pDict objectForKey:@"orgId"];
                NSInteger usertype =[[pDict objectForKey:@"userType"] integerValue];
                int vediotype = [[pDict objectForKey:@"type"] intValue];
                
                // 判断视频类型 区分开户视频
                if (vediotype && vediotype == 1)
                {
                    hosturl = [hosturl stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]];
                    hosturl =[NSString stringWithFormat:@"%@;jsessionid=%@?", hosturl, jsessionIdpram];
                    FCChatControllerAC *tkCtl = [[FCChatControllerAC alloc]initChatWithDelegate:self hostUrl:hosturl userId:userid nickName:nickname orgId:orgid userType:usertype] ;
                    [self presentViewController:tkCtl animated:YES completion:nil];
                    
                }
                return NO;
                
            }
#ifdef Integration
            
#else
            if ([[[request URL] absoluteString] rangeOfString:@"20000"].location !=NSNotFound)
            {
                
                [WechatManger sharedManager].webView = self.webView;
                [WechatManger sendAuthRequest];
                return NO;
                
            }
            
            if ([[[request URL] absoluteString] rangeOfString:@"20001"].location !=NSNotFound)
            {
                
                NSRange pathRang = [[[request URL] absoluteString] rangeOfString:@"?"];
                NSString *str = [[[request URL] absoluteString] substringFromIndex:pathRang.location+pathRang.length];
                NSMutableDictionary *pDict = [self GetRequestPram2:str];
                NSString *copyContent =[pDict objectForKey:@"copyContent"];
                NSString *transString = [NSString stringWithString:[copyContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = transString;
                NSURL * url = [NSURL URLWithString:@"weixin://"];
                BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:url];
                //先判断是否能打开该url
                if (canOpen)
                {   //打开微信
                    [[UIApplication sharedApplication] openURL:url];
                    self.url = [[NSURL alloc] initWithString:@"https://yccft.fcsc.com/m/wx/#!/yifuhuiSkip/receiveAward.html"];
                    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
                }else {
                }
                return NO;
            }
#endif
            if ([[[request URL] absoluteString] rangeOfString:@"20003"].location !=NSNotFound)
            {
                NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SystemPlugin" ofType:@"plist"];
                NSMutableDictionary *plugins = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
                 NSArray *keys = [plugins allKeys];
                NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
                    return [obj1 compare:obj2 options:NSNumericSearch];
                }];
                NSString *pluginsStr = [sortedArray componentsJoinedByString:@";"];
                [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getAllFunctionNo('%@')",pluginsStr]];
                return NO;
                
            }

        }
        else{
            NSString *action =[strUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSRange pathRang = [action rangeOfString:@"http://action:"];
            action = [action substringToIndex:pathRang.location];
            action = [strUrl substringWithRange:NSMakeRange(pathRang.length,5)];
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"functionNotFund('%@')",action]];
            return NO;
        }
        
       
        
        
    }
    
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [self.weshowTipViewAtCenterbView.scrollView endRefreshingSuccess];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (theTitle.length > 10) {
        theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
    }
    self.title = theTitle;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if([error code] == NSURLErrorCancelled)
    {
        return;
    }
     [JDragonHUD showTipViewAtCenter:@"网络异常,请检查您的网络"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - NJProgress delegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:NO];
}


#pragma mark - setters and getters
-(void)setUrl:(NSURL *)url{
    _url = url;
}

-(void)setProgressViewColor:(UIColor *)progressViewColor{
    _progressViewColor = progressViewColor;
    self.progressView.progressColor = progressViewColor;
}

-(UIWebView*)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
        _webView.delegate = (id)self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor whiteColor];
        [_webView addGestureRecognizer:self.swipePanGesture];
        [_webView setKeyboardDisplayRequiresUserAction:NO];
    }
    return _webView;
}

-(UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:@"backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"backItemImage2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
    }
    return _closeButtonItem;
}

-(UIBarButtonItem*)connectButtonItem{
    if (!_connectButtonItem) {
        //        UIImage* backItemImage = [[UIImage imageNamed:@"backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"backItemImage-hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton* menuButton = [[UIButton alloc] init];
        [menuButton.titleLabel setTextAlignment:NSTextAlignmentRight];
        [menuButton setTitle:@"联系客服" forState:UIControlStateNormal];
        [menuButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [menuButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [menuButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        //        [menuButton setImage:backItemImage forState:UIControlStateNormal];
        [menuButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [menuButton sizeToFit];
        [menuButton addTarget:self action:@selector(connectItemClicked) forControlEvents:UIControlEventTouchUpInside];
        
        _connectButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    }
    return _connectButtonItem;
}

-(UIView*)swipingBackgoundView{
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

-(BOOL)isSwipingBack{
    if (!_isSwipingBack) {
        _isSwipingBack = NO;
    }
    return _isSwipingBack;
}

-(UIPanGestureRecognizer*)swipePanGesture{
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
    }
    return _swipePanGesture;
}

-(NJKWebViewProgress*)progressProxy{
    if (!_progressProxy) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _progressProxy.webViewProxyDelegate = (id)self;
        _progressProxy.progressDelegate = (id)self;
    }
    return _progressProxy;
}

-(NJKWebViewProgressView*)progressView{
    if (!_progressView) {
        CGFloat progressBarHeight = 3.0f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        //        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight-0.5, navigaitonBarBounds.size.width, progressBarHeight);
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.progressColor = self.progressViewColor;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}



#pragma mark TKChatResultDelegate

- (void)tkChatDelegateResult:(NSString *)_ret forUserId:(NSString *)uid isDone:(BOOL)isDone statusCode:(NSString *)statuscode
{
    [self.webView stringByEvaluatingJavaScriptFromString:[ NSString stringWithFormat:@"tztqrcodescanresult('%@','%@')",@"",_ret]];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (NSMutableDictionary*)GetRequestPram:(NSString*)url
{
    NSArray *paramArr = [url componentsSeparatedByString:@"&&"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    for (int j = 0 ; j < paramArr.count; j++)
    {
        //在通过=拆分键和值
        NSArray *dicArray = [paramArr[j] componentsSeparatedByString:@"="];
        [dict setObject:dicArray[1] forKey:dicArray[0]];
    }
    
    return dict;
}

- (NSString*)GetRequestPram:(NSString*)url  key:(NSString*)key
{
    NSArray *paramArr = [url componentsSeparatedByString:@"&&"];
    NSString*string = @"";
    NSString *keyStr = @"";
    for (int j = 0 ; j < paramArr.count; j++)
    {
       keyStr = [paramArr[j] substringWithRange:NSMakeRange(0,key.length)];
        if ([paramArr[j] rangeOfString:key].location !=NSNotFound) {
            if ([keyStr isEqualToString:key]) {
                string = [paramArr[j] substringFromIndex:key.length+@"=".length];
            }
        }
    }
    
    return string;
}

- (NSMutableDictionary*)GetRequestPram2:(NSString*)url
{
    NSArray *paramArr = [url componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    for (int j = 0 ; j < paramArr.count; j++)
    {
        //在通过=拆分键和值
        NSArray *dicArray = [paramArr[j] componentsSeparatedByString:@"="];
        [dict setObject:dicArray[1] forKey:dicArray[0]];
    }
    
    return dict;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *image2 = [self fixOrientation:image];
    NSData *imagedata = [self compressImageWith:image2 width:540*1.3 height:540];
    NSString * base64String = [imagedata base64EncodedStringWithOptions:0];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.webView stringByEvaluatingJavaScriptFromString:[ NSString stringWithFormat:@"getImage('%@','%@')",base64String,libraryType]];
    }];
}


- (NSData *)compressImageWith:(UIImage *)image width:(float)width height:(float)height
{
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, width , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , height)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return UIImageJPEGRepresentation(newImage, 0.7);
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    UIImage *image = nil;
    switch (aImage.imageOrientation) {
        case UIImageOrientationUp:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationUp];
            break;
        }
        case UIImageOrientationDown:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationLeft];
            break;
        }
        case UIImageOrientationLeft:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationUp];
            break;
        }
        case UIImageOrientationRight:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationUp];
            break;
        }
        case UIImageOrientationUpMirrored:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationLeftMirrored];
            break;
        }
        case UIImageOrientationDownMirrored:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationRightMirrored];
            break;
        }
        case UIImageOrientationLeftMirrored:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationDownMirrored];
            break;
        }
        case UIImageOrientationRightMirrored:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationUpMirrored];
            break;
        }
        default:
            break;
    }
    
    return image;
}

- (void)ImageByOCR:(NSNotification *)text{
    
    NSString *str = [text object];
    [self.webView stringByEvaluatingJavaScriptFromString:str];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!self.webView.canGoBack) {
            [self loadURL];
        }else{
            [self.webView reload];
        }
        [refreshControl endRefreshing];
    });
}


@end