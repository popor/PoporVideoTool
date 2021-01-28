//
//  UIImage+pCreate.m
//  PoporUI
//
//  Created by apple on 2018/11/9.
//  Copyright © 2018年 popor. All rights reserved.

#import "UIImage+pCreate.h"

@implementation UIImage (pCreate)

#pragma mark - 生成:根据颜色
// 不继承最全的函数,是为了省资源
+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size {
    return [UIImage imageFromColor:color size:size corner:0 corners:UIRectCornerAllCorners borderWidth:0 borderColor:nil borderInset:UIEdgeInsetsZero scale:-1];
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size corner:(CGFloat)corner {
    return [UIImage imageFromColor:color size:size corner:corner corners:UIRectCornerAllCorners borderWidth:0 borderColor:nil borderInset:UIEdgeInsetsZero scale:-1];
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size corner:(CGFloat)corner borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    return [UIImage imageFromColor:color size:size corner:corner corners:UIRectCornerAllCorners borderWidth:borderWidth borderColor:borderColor borderInset:UIEdgeInsetsZero scale:-1];
}

#pragma mark - 制定圆角
+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size corner:(CGFloat)corner corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor * _Nullable)borderColor {
    return [UIImage imageFromColor:color size:size corner:corner corners:corners borderWidth:borderWidth borderColor:borderColor borderInset:UIEdgeInsetsZero scale:-1];
}

// 以后图片的scale变为1.0, 尺寸有size决定, 不再自作主张.
+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size corner:(CGFloat)corner corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor * _Nullable)borderColor borderInset:(UIEdgeInsets)borderInset scale:(CGFloat)scale {
    
    if (scale <= 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    CGFloat w = size.width;
    CGFloat h = size.height;
    //CGFloat scale = [UIScreen mainScreen].scale;
    // 防止圆角半径小于0，或者大于宽/高中较小值的一半。
    if (corner < 0){
        corner = 0;
    } else if (corner > MIN(w, h)){
        corner = MIN(w, h) / 2.0;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    UIBezierPath *path;// = [UIBezierPath bezierPath];
    // 添加圆到path
    CGRect rect;
    
    // UIEdgeInsetsZero的情况
    // rect = CGRectMake(borderWidth*scale/2.0 + borderInset.left, // 加上左边的set
    //                   borderWidth*scale/2.0 + borderInset.top,  // 加上上面的set
    //                   w - borderWidth*scale - borderInset.left - borderInset.right,   // 减去左边右边的set
    //                   h - borderWidth*scale - borderInset.top  - borderInset.bottom);// 减去上边下边的set
    
    rect = CGRectMake(borderWidth + borderInset.left, // 加上左边的set
                      borderWidth + borderInset.top,  // 加上上面的set
                      w - borderWidth*2 - borderInset.left - borderInset.right,   // 减去左边右边的set
                      h - borderWidth*2 - borderInset.top  - borderInset.bottom);// 减去上边下边的set
    
    CGFloat radii = corner-borderWidth;
    if (radii > 0) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radii, radii)];
    } else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    
    // 设置描边宽度（为了让描边看上去更清楚）
    [path setLineWidth:borderWidth];
    //设置颜色（颜色设置也可以放在最上面，只要在绘制前都可以）
    [borderColor setStroke]; // 描边
    [color setFill];         // 填充
    [path stroke];           // 描边
    [path fill];             // 填充
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 生成:根据图片文字
//@{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : 30 ], NSForegroundColorAttributeName :[ UIColor whiteColor ] }
+ (UIImage *)imageFromImage:(UIImage *)image str:(NSString *)str dic:(NSDictionary *)dic scale:(CGFloat)scale {
    
    if (scale <= 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    CGSize size= CGSizeMake(image.size.width, image.size.height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions (size, NO, scale);
    
    [image drawAtPoint:CGPointMake (0 ,0)];
    
    // 获得一个位图图形上下文
    CGContextRef context= UIGraphicsGetCurrentContext ();
    CGContextDrawPath (context, kCGPathStroke);
    
    CGSize strSize = [str sizeWithAttributes:dic];
    [str drawAtPoint:CGPointMake((size.width - strSize.width)/2, (size.height - strSize.height)/2) withAttributes:dic];
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    UIGraphicsEndImageContext ();
    
    return newImage;
}

#pragma mark - 生成:根据图片
+ (UIImage *)imageFromImage:(UIImage *)image size:(CGSize)size {
    return [self imageFromImage:image size:size imageDrawRect:CGRectZero bgColor:[UIColor clearColor] corner:0 borderWidth:0 borderColor:nil scale:-1];
}

+ (UIImage *)imageFromImage:(UIImage *)image size:(CGSize)size corner:(CGFloat)corner {
    return [self imageFromImage:image size:size imageDrawRect:CGRectZero bgColor:[UIColor clearColor] corner:corner borderWidth:0 borderColor:nil scale:-1];
}

+ (UIImage *)imageFromImage:(UIImage *)image size:(CGSize)size imageDrawRect:(CGRect)imageDrawRect corner:(CGFloat)corner borderWidth:(CGFloat)borderWidth borderColor:(UIColor * _Nullable)borderColor {
    return [self imageFromImage:image size:size imageDrawRect:imageDrawRect bgColor:[UIColor clearColor] corner:corner borderWidth:borderWidth borderColor:borderColor scale:-1];
}

+ (UIImage *)imageFromImage:(UIImage *)image size:(CGSize)size imageDrawRect:(CGRect)imageDrawRect bgColor:(UIColor * _Nullable)bgColor corner:(CGFloat)corner borderWidth:(CGFloat)borderWidth borderColor:(UIColor *_Nullable)borderColor scale:(CGFloat)scale {
    
    if (scale <= 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    if (CGRectEqualToRect(imageDrawRect, CGRectZero)) {
        // 图片要居中显示
        CGFloat ImageOW = image.size.width;
        CGFloat ImageOH = image.size.height;
        CGFloat ImageMinScale = MIN(ImageOW/size.width, ImageOH/size.height);
        
        CGFloat ImageSW = ImageOW/ImageMinScale;
        CGFloat ImageSH = ImageOH/ImageMinScale;
        
        imageDrawRect = CGRectMake(-(ImageSW-size.width)/2, -(ImageSH-size.height)/2, ImageSW, ImageSH);
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    UIBezierPath * path;
    if (corner>0 || borderWidth>0) {
        // 添加圆到path
        CGRect pathRect = CGRectMake(borderWidth*scale/2.0, borderWidth*scale/2.0, size.width - borderWidth*scale, size.height - borderWidth*scale);
        path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:corner-borderWidth*scale];
        [path addClip]; // 超出边界的,都会被忽略掉
        
        if (borderColor > 0) {
            [path setLineWidth:borderWidth];
        }
    }
    
    if (path) {
        // 有边界的话,在边界范围内进行填充颜色,图片和边界线
        if (bgColor) {
            [bgColor setFill];
            [path fill];
        }
        if (image) {
            [image drawInRect:imageDrawRect];
        }
        if (borderColor) {
            [borderColor setStroke];
            [path stroke];
        }
    }else{
        // 没有边界宽度的话,仅仅填充背景色和图片
        if (bgColor) {
            [bgColor setFill];
            UIRectFill(CGRectMake(0, 0, size.width, size.height));
        }
        if (image) {
            [image drawInRect:imageDrawRect];
        }
    }
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 修改图片
// 更改图片色系
+ (UIImage *)imageFromImage:(UIImage *)image changecolor:(UIColor *)color {
    return [UIImage imageFromImage:image changecolor:color scale:-1];
}

+ (UIImage *)imageFromImage:(UIImage *)image changecolor:(UIColor *)color scale:(CGFloat)scale {
    if (scale <= 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// 更改图片背景色
+ (UIImage *)imageFromImage:(UIImage *)image bgColor:(UIColor *)color {
    return [UIImage imageFromImage:image bgColor:color scale:-1];
}

+ (UIImage *)imageFromImage:(UIImage *)image bgColor:(UIColor *)color scale:(CGFloat)scale {
    if (scale <= 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    CGSize size= CGSizeMake(image.size.width, image.size.height); // 画布大小
    UIGraphicsBeginImageContextWithOptions (size, NO, scale);
    
    // 设置背景色
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    [image drawAtPoint:CGPointMake (0 ,0)];
    // 获得一个位图图形上下文
    CGContextRef context= UIGraphicsGetCurrentContext ();
    CGContextDrawPath (context, kCGPathStroke);
    
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    UIGraphicsEndImageContext ();
    
    return newImage;
}

#pragma mark - 根据图片叠加图片
+ (UIImage *)imageFromBaseImage:(UIImage *)baseImage addImage:(UIImage *)addImage size:(CGSize)size {
    return [UIImage imageFromBaseImage:baseImage addImage:addImage size:size scale:-1];
}

+ (UIImage *)imageFromBaseImage:(UIImage *)baseImage addImage:(UIImage *)addImage size:(CGSize)size scale:(CGFloat)scale {
    if (scale <= 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    CGRect drawRect;
    {
        // 图片要居中显示
        CGFloat ImageOW = baseImage.size.width;
        CGFloat ImageOH = baseImage.size.height;
        CGFloat ImageMinScale = MIN(ImageOW/size.width, ImageOH/size.height);
        
        CGFloat ImageSW = ImageOW/ImageMinScale;
        CGFloat ImageSH = ImageOH/ImageMinScale;
        
        drawRect = CGRectMake(-(ImageSW-size.width)/2, -(ImageSH-size.height)/2, ImageSW, ImageSH);
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    [baseImage drawInRect:drawRect];
    
    CGRect addImageRect = CGRectMake((baseImage.size.width - addImage.size.width)/2, (baseImage.size.height - addImage.size.height)/2, addImage.size.width, addImage.size.height);
    [addImage drawInRect:addImageRect];
    
    baseImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return baseImage;
}

#pragma mark - 从View上截图
+ (UIImage *)imageFromView:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    } else {
        // 这是老版本方法,假如运行在ios10中,截取的NCBarTitle为半透明色
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageFromLayer:(CALayer *)layer {
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, 0);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

#pragma mark - 图片压缩
- (UIImage *)scaleWidth:(CGFloat)width {
    return [self scaleWidthScale:(width/self.size.width) scale:-1];
}

- (UIImage *)scaleWidth:(CGFloat)width scale:(CGFloat)scale {
    return [self scaleWidthScale:(width/self.size.width) scale:scale];
}

- (UIImage *)scaleWidthScale:(CGFloat)wScale scale:(CGFloat)scale {
    if (!self) {
        return nil;
    }
    if (scale <= 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    CGSize size = CGSizeMake(self.size.width*wScale, self.size.height*wScale);
    
    CGImageRef imgRef = self.CGImage;
    CGSize originSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // 原始大小
    if (CGSizeEqualToSize(originSize, size)) {
        return self;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    /**
     *  设置CGContext集插值质量
     *  kCGInterpolationHigh 插值质量高
     */
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
