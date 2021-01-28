//
//  UIDevice+pScreenSize.m
//  PoporUI
//
//  Created by popor on 2018/3/27.
//  Copyright © 2018年 popor. All rights reserved.
//

#import "UIDevice+pScreenSize.h"

#pragma mark - iOS
#if TARGET_OS_IOS || TARGET_OS_WATCH

@implementation UIDevice (pScreenSize)

// 是否是刘海屏幕,通过安全区域取值
+ (BOOL)isIphoneXScreen {
    BOOL iPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.top > 20.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}

+ (CGFloat)statusBarHeight {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        return mainWindow.safeAreaInsets.top;
    }else{
        return 20;
    }
}

+ (CGFloat)safeBottomMargin {
    if ([self isIphoneXScreen]) {
        return 34;
    }else{
        return 0;
    }
}

+ (UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        return mainWindow.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

+ (CGFloat)portainWidth {
    static CGFloat width;
    if (width == 0) {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        width = MIN(size.width, size.height);
    }
    return width;
}

+ (CGFloat)portainHeight {
    static CGFloat height;
    if (height == 0) {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        height = MAX(size.width, size.height);
    }
    return height;
}

@end

#pragma mark - macOX
#elif TARGET_OS_MAC


#endif


