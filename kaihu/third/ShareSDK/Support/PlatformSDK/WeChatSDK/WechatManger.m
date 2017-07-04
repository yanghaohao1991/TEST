//
//  WechatManger.m
//  AnyChatSDKTest
//
//  Created by yanghaohao on 2017/3/20.
//  Copyright © 2017年 Thinkive. All rights reserved.
//

#import "WechatManger.h"
#define APPID  @"wxcc09640365636fc1"
#define SECRET  @"67a3ca62b84557b4f89e0cd6510d6c16"
#define WeakSelf __weak typeof(self) weakSelf = self;

@implementation WechatManger

#pragma mark - LifeCycle

+(instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    
    static WechatManger *instance;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[WechatManger alloc] init];
        
    });
    
    return instance;
    
}



#pragma mark - WXApiDelegate微信回调

- (void)onResp:(BaseResp *)resp

{
    
    /*微信登录的回调*/
    
    if ([resp isKindOfClass:[SendAuthResp class]])
        
    {
        
        //拿到微信返回的Code
        SendAuthResp *authResp = (SendAuthResp *)resp;
        NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", authResp.code, authResp.state, authResp.errCode];
        NSLog(@"%@",strMsg);
        [self getAccess_token:authResp.code];
        
    }
    
}

- (void)onReq:(BaseReq *)req

{
    
}

/*微信登录调起事件*/

+ (void)sendAuthRequest

{
    
    //构造SendAuthReq结构体
    
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    
    req.scope = @"snsapi_userinfo";
    
    req.openID = @"wxcc09640365636fc1";
    
    //第三方向微信终端发送一个SendAuthReq消息结构
    
    [WXApi sendReq:req];
    
}


#pragma mark -
- (void)getAccess_token:(NSString*)code
{
    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",APPID,SECRET, code];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3. Connection
    // 1> 登录完成之前,不能做后续工作!
    // 2> 登录进行中,可以允许用户干点别的会更好!
    // 3> 让登录操作在其他线程中进行,就不会阻塞主线程的工作
    // 4> 结论:登陆也是异步访问,中间需要阻塞住
    WeakSelf;
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError == nil) {
            // 网络请求结束之后执行!
            // 将Data转换成字符串
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *unionid = dict[@"unionid"];
            
            // num = 2
            NSLog(@"%@ %@", unionid, [NSThread currentThread]);
            // 更新界面
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 [weakSelf.webView stringByEvaluatingJavaScriptFromString:[ NSString stringWithFormat:@"getUIDFromWechat('%@')",unionid]];
//              
            }];
        }
    }];

}

@end
