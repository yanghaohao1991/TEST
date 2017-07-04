//
//  RxWebViewNavigationViewController.m
//  RxWebViewController
//
//  Created by roxasora on 15/10/23.
//  Copyright © 2015年 roxasora. All rights reserved.
//

#import "RxWebViewNavigationViewController.h"
#import "RxWebViewController.h"

@interface RxWebViewNavigationViewController ()<UINavigationBarDelegate>

/**
 *  由于 popViewController 会触发 shouldPopItems，因此用该布尔值记录是否应该正确 popItems
 */
@property BOOL shouldPopItemAfterPopViewController;

@end

@implementation RxWebViewNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationBar.tintColor = [UIColor whiteColor];

    
    self.shouldPopItemAfterPopViewController = NO;
}


//
//-(UIViewController*)popViewControllerAnimated:(BOOL)animated{
//    self.shouldPopItemAfterPopViewController = YES;
//    return [super popViewControllerAnimated:animated];
//}
//
//-(NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    self.shouldPopItemAfterPopViewController = YES;
//    return [super popToViewController:viewController animated:animated];
//}
//
//-(NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated{
////    self.shouldPopItemAfterPopViewController = YES;
//    return [super popToRootViewControllerAnimated:animated];
//}
//-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
//    NSLog(@"------%d",self.shouldPopItemAfterPopViewController);
//    //! 如果应该pop，说明是在 popViewController 之后，应该直接 popItems
//    if (self.shouldPopItemAfterPopViewController) {
//        self.shouldPopItemAfterPopViewController = NO;
//        return YES;
//    }
//    
//    //! 如果不应该 pop，说明是点击了导航栏的返回，这时候则要做出判断区分是不是在 webview 中
//    if ([self.topViewController isKindOfClass:[RxWebViewController class]]) {
//        RxWebViewController* webVC = (RxWebViewController*)self.viewControllers.lastObject;
//        if (webVC.webView.canGoBack) {
//            [webVC.webView goBack];
//            
//            self.shouldPopItemAfterPopViewController = NO;
//            [[self.navigationBar subviews] lastObject].alpha = 1;
//            return NO;
//        }else{
//            [self popViewControllerAnimated:YES];
//            return NO;
//        }
//    }else{
//        [self popViewControllerAnimated:YES];
//        return NO;
//    }
//}

@end
