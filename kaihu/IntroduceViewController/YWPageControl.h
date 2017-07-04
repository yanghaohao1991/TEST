//
//  YHPageControl.h
//  ASK
//
//  Created by zhuanghaishao on 14-8-25.
//  Copyright (c) 2014年 yiyaowang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIColor *otherPageColor;
@property (nonatomic, strong) UIColor *currentPageColor;
@property (nonatomic, strong) UIColor *otherPageStrokeColor;
@property (nonatomic, strong) UIColor *currentPageStrokeColor;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) NSTextAlignment alignment;

@end
