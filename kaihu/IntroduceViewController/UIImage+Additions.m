//
//  UIImage+Additions.m
//  ASK
//
//  Created by Pinka on 14-6-18.
//  Copyright (c) 2014年 yiyaowang. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)inputImageWithType:(InputImageType)type
{
    UIImage *image = nil;
    
    switch (type) {
        case InputImageType_White:
            image = [UIImage imageNamed:@"bg_Input_White"];
            break;
            
        case InputImageType_Gray:
            image = [UIImage imageNamed:@"bg_Input_Gray"];
            break;
    }
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 3, 9)];
}

+ (UIImage *)fc_solidColorImageWithSize:(CGSize)size color:(UIColor *)solidColor
{
    UIGraphicsBeginImageContext(size);
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
    [solidColor set];
    UIRectFill(drawRect);
    UIImage *drawnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return drawnImage;
}


+ (UIImage *)imageWithColor:(UIColor *)color {
    return [UIImage imageWithColor:color andSize:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)buttonImageWithName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    return image;
}

+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}
@end
