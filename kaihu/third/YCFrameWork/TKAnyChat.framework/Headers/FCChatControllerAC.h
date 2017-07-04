//
//  TKChatControllerAC.h
//  TKchat_AC
//
//  Created by chensj on 14-4-18.
//  Copyright (c) 2014年 chensj. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

#define codeTKChatResultPASS @"10000" //见证通过
#define codeTKChatResultFAIL @"10001" //见证不通过
#define codeTKChatResultRECHECKPASS @"10003" //复核通过
#define codeTKChatResultFORCEQUIT @"10004" //被退出


#define codeTKChatResultServerRefresh @"10006" //网络异常,见证不通过
#define codeTKChatResultNetFAIL @"10007" //网络异常,见证不通过
#define codeTKChatResultVideoFAIL @"10008" //视频异常,见证不通过
#define codeTKChatResultDataFAIL @"10009" //资料异常,见证不通过


/**
 *
 * @class ChatWaitCtl
 *
 * @description  等待视频见证视图控制器
 *
 */
@interface FCChatWaitCtl : UIViewController


@end


/**
  * @description 见证结果委托
  *
 */
@protocol FCChatResultDelegate <NSObject>

@required


/**
 *
 * @method tkChatDelegateResult:forUserId:isDone:statusCode:
 * @param _ret:当isDone = NO时，返回异常描述，为YES时，返回宏定义codeTKChatResult
 * @param uid: 当前客户号
 * @param isDone:是否完成见证
 * @param statuscode: 见证结果 0:取消排队，-1:视频连接异常，1:用户挂断视频，-999:用户未登录,其它：视频见证通道消息（通过及驳回）
 *
 */
- (void)tkChatDelegateResult:(NSString*)_ret forUserId:(NSString*)uid isDone:(BOOL)isDone statusCode:(NSString*)statuscode;


@end

/**
  * @class  TKChatControllerAC 
  *
  * @description anychat视频见证视图控制器
 */
@interface FCChatControllerAC : UIViewController


 /**
  *
  *  @method initChatWithDelegate:hostUrl:userId:nickName:orgId:
  *
  *  @param del 回调代理
  *  @param url 连接地址
  *  @param uid 用户标识
  *  @param nName 用户名称
  *  @param oid 营业部标识
  *
  *  @return 
  */
- (id)initChatWithDelegate:(id<FCChatResultDelegate>)del hostUrl:(NSString*)url userId:(NSString*)uid nickName:(NSString*)nName orgId:(NSString*)oid userType:(NSInteger)uType;

//-(void)registNotifyHandle;

@end
