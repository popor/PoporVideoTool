//
//  UIImage+pGradient.m
//  PoporUI
//
//  Created by apple on 2018/11/9.
//  Copyright © 2018年 popor. All rights reserved.

#import "UIImage+pGradient.h"

@implementation UIImage (pGradient)

/**
 *  获取矩形的渐变色的UIImage(此函数还不够完善)
 *
 *  @param bounds          UIImage的bounds
 *  @param colors          渐变色数组，可以设置两种颜色
 *  @param gradientHorizon 渐变的方式：0--->从上到下   1--->从左到右
 *
 *  @return 渐变色的UIImage
 */
+ (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors gradientHorizon:(BOOL)gradientHorizon {
    CGPoint start;
    CGPoint end;
    
    if (gradientHorizon) {
        start = CGPointMake(0.0, 0.0);
        end = CGPointMake(bounds.size.width, 0.0);
    }else{
        start = CGPointMake(0.0, 0.0);
        end = CGPointMake(0.0, bounds.size.height);
    }
    
    UIImage *image = [self gradientImageWithBounds:bounds andColors:colors addStartPoint:start addEndPoint:end];
    return image;
}

+ (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors addStartPoint:(CGPoint)startPoint addEndPoint:(CGPoint)endPoint {
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

/**
 CGPointMake(0, 0);// 开始点
 CGPointMake(0, 1);// 结束点
 用法:
 1  [UIImage imageFromLayer:gradientLayer];
 2  [view.layer addSublayer:gradientLayer];
 */
+ (CAGradientLayer *)gradientLayer:(CGRect)bounds colors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations start:(CGPoint)start end:(CGPoint)end {
    if (colors.count != locations.count) {
        return nil;
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = bounds;
    
    NSMutableArray * cgColors = [NSMutableArray new];
    for (UIColor * color in colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    
    gradientLayer.colors    = cgColors;
    gradientLayer.locations = locations;
    
    gradientLayer.startPoint = start;
    gradientLayer.endPoint   = end;
    
    return gradientLayer;
}

@end
