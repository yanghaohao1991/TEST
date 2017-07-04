//
//  ISIDCardReaderController.h
//  ISIDReaderPreviewSDK
//
//  Created by Felix on 15/5/11.
//  Copyright (c) 2015年 IntSig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ISOpenSDKFoundation/ISOpenSDKFoundation.h>
#import <CoreMedia/CoreMedia.h>

extern NSString * const kOpenSDKCardResultTypeOriginImage;//origin image(原图)
extern NSString * const kOpenSDKCardResultTypeCardName;//card name(卡/证名,字符串值)
extern NSString * const kOpenSDKCardResultTypeCardType;//card type(卡/证类型,整型值)
extern NSString * const kOpenSDKCardResultTypeCardItemInfo;//card item info dictionary(卡/证的详细信息)
extern NSString * const kOpenSDKCardResultTypeCardRotate;//origin image rotate(原图的旋转角度，暂时只可能返回0,90,180,270)

extern NSString * const kCardItemName;//姓名
extern NSString * const kCardItemGender;//性别
extern NSString * const kCardItemNation;//民族
extern NSString * const kCardItemBirthday;//出生日期
extern NSString * const kCardItemAddress;//住址
extern NSString * const kCardItemIDNumber;//号码
extern NSString * const kCardItemIssueAuthority;//签发机关
extern NSString * const kCardItemValidity;//有效期限

typedef NS_ENUM(NSUInteger, ISOpenSDKIDCardType)//身份证类型枚举
{
    ISOpenSDKIDCardTypeSecondMain = 0,//第二代身份证正面
    ISOpenSDKIDCardTypeFirst = 1,//第一代身份证
    ISOpenSDKIDCardTypeSecondCover = 2,//第二代身份证背面
};

typedef void(^ConstructResourcesFinishHandler)(ISOpenSDKStatus status);//初始化结果的回调Block
typedef void(^DetectCardFinishHandler)(int result, NSArray *borderPointsArray);//边缘检测的回调Block
typedef void(^RecognizeCardFinishHandler)(NSDictionary *cardInfo);//识别成功的回调Block

@interface ISIDCardReaderController : NSObject<ISPreviewSDKProtocol>

/**
 *  单例对象
 *
 *  @return 身份证预览识别控制器单例
 */
+ (ISIDCardReaderController *)sharedISOpenSDKController;

/**
 *  初始化相机模块，如果使用Intsig自带的相机模块，请使用该方法进行初始化
 *
 *  @param appKey    申请获得的SDK，用于授权
 *  @param subAppKey 为扩展而留，当前请传空
 *
 *  @return 相机模块实体
 */
- (ISOpenSDKCameraViewController *)cameraViewControllerWithAppkey:(NSString *)appKey
                                                        subAppkey:(NSString *)subAppKey;

/**
 *  初始化SDK，调用识别函数之前请先调用该接口
 *
 *  @param appKey    申请获得的SDK，用于授权
 *  @param subAppKey 为扩展而留，当前请传空
 *  @param handler   初始化结果的回调Block，授权状态定义在ISOpenSDKStatus.h
 */
- (void)constructResourcesWithAppKey:(NSString *)appKey
                           subAppkey:(NSString *)subAppKey
                       finishHandler:(ConstructResourcesFinishHandler)handler;

/**
 *  检测和识别卡/证的方法
 *
 *  @param sampleBuffer            需要识别的的图像数据，YUV格式
 *  @param rect                    需要识别的图像位置
 *  @param detectCardFinishHandler 边缘检测的回调Block，result为检测结果，大于0表示检测成功，borderPointsArray为检测出的8个角点数组
 *  @param recognizeFinishHandler  识别成功的回调Block，只有在识别成功时才会回调，cardInfo里面包含了识别结果信息
 *
 *  @return SDK的授权状态，如果SDK未授权或者之前授权不成功，将不会返回边缘检测结果和识别结果
 */
- (ISOpenSDKStatus)detectCardWithOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                           cardRect:(CGRect)rect
                            detectCardFinishHandler:(DetectCardFinishHandler)detectCardFinishHandler
                         recognizeCardFinishHandler:(RecognizeCardFinishHandler)recognizeFinishHandler;

/**
 *  释放资源
 */
- (void)destructResources;

@end