//
//  UIImage+Additions.h
//  ASK
//
//  Created by Pinka on 14-6-18.
//  Copyright (c) 2014年 yiyaowang. All rights reserved.
//
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, InputImageType) {
    InputImageType_White,
    InputImageType_Gray,
};

@interface UIImage (Additions)

+ (UIImage *)inputImageWithType:(InputImageType)type;

+ (UIImage *)fc_solidColorImageWithSize:(CGSize)size color:(UIColor *)solidColor;

/*
 * Return UIImage object with the assign color, the default size of the image is CGSize(1.0f,1.0f)
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/*
 * Return UIImage object with the assign color and size
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

+ (UIImage *)buttonImageWithName:(NSString *)imageName;

/*
 * Convert UIView to UIImage object!
 */
+ (UIImage *)imageWithView:(UIView *)view;
@end
