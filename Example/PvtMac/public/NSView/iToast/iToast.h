//
//  iToast.h
//  MoveFile
//
//  Created by apple on 2018/3/15.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define AlertToastTitle(title, atView)           [iToast alertToastTitle:title view:atView]
#define AlertToastTitleTime(title, time, atView) [iToast alertToastTitle:title duration:time view:atView]

#define AlertToastTitleTimeTextColorBgColor(title, time, atView, textColor, bgColor) [iToast alertToastTitle:title duration:time view:atView t##extColor:textColor b##gColor:bgColor]

@interface iToast : NSTextView

//- (id)initWithMessage:(NSString *)message;
//- (void)showAtView:(NSView *)view;

//@property (nonatomic, copy  ) NSColor * textColor;
@property (nonatomic, copy  ) NSColor * bgColor;


+ (void)alertToastTitle:(NSString *)title view:(NSView *)view;
+ (void)alertToastTitle:(NSString *)title duration:(NSInteger)duration view:(NSView *)view;

+ (void)alertToastTitle:(NSString *)title duration:(NSInteger)duration view:(NSView *)view textColor:(NSColor * _Nullable)textColor bgColor:(NSColor * _Nullable)bgColor;

@end
