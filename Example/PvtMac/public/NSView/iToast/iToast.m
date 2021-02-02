//
//  iToast.m
//  MoveFile
//
//  Created by apple on 2018/3/15.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "iToast.h"
#import <PoporFoundation/NSString+pSize.h>
#import <Masonry/Masonry.h>

@import QuartzCore;

@interface iToast ()
@property (nonatomic        ) float duration;

@end

@implementation iToast

- (id)initWithMessage:(NSString *)message duration:(float)duration {
    if (self = [super init]) {
        self.duration = duration;
        self.string = message;
        self.editable = NO;
        self.selectable = NO;
        self.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.textColor = [NSColor whiteColor];
        self.font = [NSFont systemFontOfSize:16];
        self.alignment = NSTextAlignmentCenter;
        
        
        CGSize size = [message sizeInFont:self.font width:500];
        self.frame = CGRectMake(0, 0, MAX(size.width + 20, 320), size.height + 20);
        self.textContainerInset = CGSizeMake(10, 10);
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = [self bounds];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:10 yRadius:10];
    [path addClip];
    
    if (self.bgColor) {
        [self.bgColor set];
    } else {
        [[NSColor colorWithRed:0 green:0 blue:0 alpha:0.8] set];
    }
    
    
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
    
}

- (void)showAtView:(NSView *)view {
    // 移除之前的自己
    NSArray * array = [view subviews];
    for (NSView * subview in array) {
        if ([subview isKindOfClass:[self class]]) {
            [subview removeFromSuperview];
        }
    }
    
    [view addSubview:self];
    
    //self.frame = CGRectMake((view.frame.size.width - self.frame.size.width)/2, 40, self.frame.size.width, self.frame.size.height);
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-40);
        make.width.mas_equalTo(self.frame.size.width);
        make.height.mas_equalTo(self.frame.size.height);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

+ (void)alertToastTitle:(NSString *)title view:(NSView *)view {
    [self alertToastTitle:title duration:2 view:view];
}

+ (void)alertToastTitle:(NSString *)title duration:(NSInteger)duration view:(NSView *)view {
    [self alertToastTitle:title duration:duration view:view textColor:nil bgColor:nil];
}

+ (void)alertToastTitle:(NSString *)title duration:(NSInteger)duration view:(NSView *)view textColor:(NSColor * _Nullable)textColor bgColor:(NSColor * _Nullable)bgColor {
    iToast * i = [[iToast alloc] initWithMessage:title duration:duration];
    
    if (textColor) {
        i.textColor = textColor;
    }
    
    if (bgColor) {
        i.bgColor   = bgColor;
    }
    
    
    [i showAtView:view];
}

@end
