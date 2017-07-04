//
//  YHPageControl.m
//  ASK
//
//  Created by zhuanghaishao on 14-8-25.
//  Copyright (c) 2014年 yiyaowang. All rights reserved.
//

#import "YWPageControl.h"

@implementation YWPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfPages = 0;
        _currentPage = 0;
        
        _currentPageColor = [UIColor grayColor];
        _otherPageColor = [UIColor darkGrayColor];
        
        _currentPageStrokeColor = [UIColor clearColor];
        _otherPageStrokeColor = [UIColor clearColor];
        _spacing = 10;
        _lineWidth = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - getter setter
- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    _numberOfPages = numberOfPages;
    [self setNeedsDisplay];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self setNeedsDisplay];
}

- (void)setOtherPageColor:(UIColor *)otherPageColor
{
    _otherPageColor = otherPageColor;
    [self setNeedsDisplay];
}

- (void)setCurrentPageColor:(UIColor *)currentPageColor
{
    _currentPageColor = currentPageColor;
    [self setNeedsDisplay];
}

- (void)setOtherPageStrokeColor:(UIColor *)otherPageStrokeColor
{
    _otherPageStrokeColor = otherPageStrokeColor;
    [self setNeedsDisplay];
}

- (void)setCurrentPageStrokeColor:(UIColor *)currentPageStrokeColor
{
    _currentPageStrokeColor = currentPageStrokeColor;
    [self setNeedsDisplay];
}

- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth{
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

#pragma mark -
- (void)drawRect:(CGRect)rect
{
    if (_numberOfPages > 1)
    {
        CGFloat height = self.frame.size.height - _lineWidth * 2;
        CGFloat width = height * _numberOfPages + _spacing * (_numberOfPages - 1) + _lineWidth * 2;
        CGFloat startX = self.frame.size.width / 2 - width / 2;
        switch (_alignment) {
            case NSTextAlignmentLeft:
                
                break;
            case NSTextAlignmentRight:
                startX = rect.size.width - width - height;
                break;
            default:
                break;
        }
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(ctx, _lineWidth);
        for (int i = 0; i < _numberOfPages; i++) {
            CGRect fillRect = CGRectZero;
            if (i == _currentPage) {
                fillRect = CGRectMake(startX, _lineWidth / 2, self.frame.size.height - _lineWidth, self.frame.size.height - _lineWidth);
                startX += _spacing + self.frame.size.height - _lineWidth;
                CGContextSetFillColorWithColor(ctx, _currentPageColor.CGColor);
                CGContextSetStrokeColorWithColor(ctx, _currentPageStrokeColor.CGColor);
            } else {
                fillRect = CGRectMake(startX, (self.frame.size.height - height) / 2, height, height);
                startX += _spacing + height;
                CGContextSetFillColorWithColor(ctx, [[UIColor lightGrayColor]colorWithAlphaComponent:0.5] .CGColor);
                CGContextSetStrokeColorWithColor(ctx, _otherPageStrokeColor.CGColor);
            }
            CGContextFillEllipseInRect(ctx, fillRect);
            CGContextStrokeEllipseInRect(ctx, CGRectInset(fillRect, 0.5, 0.5));
        }
    }
}

@end
