//
//  GuideViewController.m
//  ASK
//
//  Created by zhuanghaishao on 14-8-25.
//  Copyright (c) 2014年 yiyaowang. All rights reserved.
//

#import "IntroduceViewController.h"
#import "YWPageControl.h"
#import "UIImage+Additions.h"
#import "RxWebViewController.h"
#import "RxWebViewNavigationViewController.h"


#define NUMBEROFPAGES 1
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define ColorRGB(_R_, _G_, _B_) [UIColor colorWithRed:(_R_/255.0) green:(_G_/255.0) blue:(_B_/255.0) alpha:1.0]
#define ColorRGBA(_R_, _G_, _B_, _A_) [UIColor colorWithRed:(_R_/255.0) green:(_G_/255.0) blue:(_B_/255.0) alpha:_A_]

@interface IntroduceViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YWPageControl *pageControl;

@end

@implementation IntroduceViewController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self) {
        _rootViewController = rootViewController;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = YES;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    _scrollView.scrollEnabled = NO;
    for (int i = 0; i < NUMBEROFPAGES; i++) {
        NSString *imageName = nil;
//        if ([UIScreen mainScreen].bounds.size.height >= 568) {
            imageName = [NSString stringWithFormat:@"jieshao%d-568@2x.png",i + 1];
//        } else {
//            imageName = [NSString stringWithFormat:@"jieshao%d",i + 1];
//        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        imageView.userInteractionEnabled = YES;
        [imageView setImage:[UIImage imageNamed:imageName]];
        [_scrollView addSubview:imageView];
        
//                if (i == NUMBEROFPAGES - 1) {
//                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//                    CGFloat width = 110;
//                    [button setFrame:CGRectMake((self.view.frame.size.width - width) / 2, kScreenHeight - 40, width, 34)];
//                    [button setImage:[UIImage imageNamed:@"b_p.png"] forState:UIControlStateNormal];
//                    [button setImage:[UIImage imageNamed:@"b.png"] forState:UIControlStateHighlighted];
//        
//        
//                    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//                    [imageView addSubview:button];
//                    [button addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
//        
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(action)];
                    [imageView addGestureRecognizer:tap];
//
//                }
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * NUMBEROFPAGES+10, 0)];
    [self.view addSubview:_scrollView];
    
//    //注册按钮
//    UIButton *regiBtn = [[UIButton alloc]init];
//    CGFloat width = 138;
//    [regiBtn setFrame:CGRectMake(self.view.width/ 2 - width -15, kScreenHeight - 93, width, 40)];
//    [regiBtn setTitle:@"注册" forState:UIControlStateNormal];
//    regiBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//    [regiBtn setBackgroundColor:[TKUIHelper colorWithHexString:@"5a7eb1"]];
//    [self.view addSubview:regiBtn];
//    [regiBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    //登录按钮
//    UIButton *loginBtn = [[UIButton alloc]init];
//    CGFloat loginWidth = 138;
//    [loginBtn setFrame:CGRectMake(self.view.width / 2 +15, kScreenHeight - 93, loginWidth, 40)];
//    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
//    loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//    [loginBtn setTitleColor:[TKUIHelper colorWithHexString:@"597eb1"] forState:UIControlStateNormal];
//    [self.view addSubview:loginBtn];
//    [loginBtn addTarget:self action:@selector(LoginAction) forControlEvents:UIControlEventTouchUpInside];
//    loginBtn.layer.borderWidth = 1.5;
//    loginBtn.layer.borderColor = [TKUIHelper colorWithHexString:@"537eb3"].CGColor;
//    
//    //登录按钮
//    UIButton *lookBtn = [[UIButton alloc]init];
//    [lookBtn setTitle:@"随便看看" forState:UIControlStateNormal];
//    lookBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
//    [lookBtn setFrame:CGRectMake(self.view.width / 2 -50 , kScreenHeight - 30, 100, 15)];
//    [lookBtn setTitleColor:[TKUIHelper colorWithHexString:@"587db3"] forState:UIControlStateNormal];
//    [self.view addSubview:lookBtn];
//    [lookBtn addTarget:self action:@selector(lookAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    //    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    backBtn.alpha = 0.5;
    //    [backBtn setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    //    [backBtn setImage:[UIImage imageNamed:@"loginReduce.png"] forState:UIControlStateNormal];
    //    [self.view addSubview:backBtn];
    
    _pageControl = [[YWPageControl alloc] initWithFrame:CGRectMake(0, kScreenHeight - 20, self.view.frame.size.width, 8)];
    _pageControl.numberOfPages = NUMBEROFPAGES;
    _pageControl.otherPageColor = ColorRGBA(11, 130, 206, 1);
    [self.view addSubview:_pageControl];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.data = [[NSMutableData alloc]init];
//    NSString *mobile_phone = (NSString*)[[TKCacheManager shareInstance]getFileCacheDataWithKey:@"mobile_phone"];
//    NSString *token_id = (NSString*)[[TKCacheManager shareInstance]getFileCacheDataWithKey:@"token_id"];
//    if ( token_id.length <= 0 && mobile_phone.length <= 0) {
//        
////        IntroduceViewController *guideVC = [[IntroduceViewController alloc]initWithName:@"dycyguide"];
////        UINavigationController *guidenav = [[UINavigationController alloc]initWithRootViewController:guideVC];
////        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
////        window.rootViewController = guidenav;
//    }else{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_TAB_70002" object:nil];
//    }
    
}


- (void)action
{
    RxWebViewNavigationViewController *nav = [[RxWebViewNavigationViewController alloc]initWithRootViewController:[[RxWebViewController alloc]init]];
    [[UIApplication sharedApplication] keyWindow].rootViewController = nav;
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    _pageControl.currentPage = currentPage;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x > kScreenWidth*2) {
        [self action];
    }
}


@end
