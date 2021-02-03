//
//  AppDelegate.m
//  PvtMac
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.
//

#import "AppDelegate.h"
#import <Masonry/Masonry.h>

@interface AppDelegate ()
@property (nonatomic, strong) NSButton * frontBT;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
#if TARGET_OS_MAC//模拟器
    NSString * macOSInjectionPath = @"/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle";
    if ([[NSFileManager defaultManager] fileExistsAtPath:macOSInjectionPath]) {
        [[NSBundle bundleWithPath:macOSInjectionPath] load];
    }
#endif
    
    [self addFrontBt];
}

- (void)addFrontBt {
    NSApplication * app     = [NSApplication sharedApplication];
    NSWindow * window       = app.windows.firstObject;
    NSButton * closeButton  = [window standardWindowButton:NSWindowCloseButton];
    NSView   * titleBarView = closeButton.superview;
    
    self.frontBT = ({
        NSButton * button = [NSButton checkboxWithTitle:@"置顶" target:self action:@selector(keepAtFrontAction:)];
        
        [titleBarView addSubview:button];
        button;
    });
    
    [self.frontBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-0);
        make.right.mas_equalTo(-5);
    }];
    
    // event
    NSString * front = [self get__keepFront];
    if (front.integerValue == 0) {
        self.frontBT.state = NSControlStateValueOn;
        [self keepAtFront:NO];
    } else {
        self.frontBT.state = NSControlStateValueOff;
        [self keepAtFront:YES];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (void)keepAtFrontAction:(NSButton *)bt {
    if (bt.state == NSControlStateValueOff) {
        bt.state = NSControlStateValueOff;
    } else {
        bt.state = NSControlStateValueOn;
    }
    //NSLog(@"%li", bt.state);
    
    [self keepAtFront:bt.state != NSControlStateValueOn];
}

- (void)keepAtFront:(BOOL)front {
    if (front) {
        [NSApp.windows[0] setLevel:NSNormalWindowLevel];
    }else{
        [NSApp.windows[0] setLevel:NSFloatingWindowLevel];
    }
    [self save__keepFront:[NSString stringWithFormat:@"%i", front]];
}

- (void)save__keepFront:(NSString *)__keepFront {
    [[NSUserDefaults standardUserDefaults] setObject:__keepFront forKey:@"__keepFront"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)get__keepFront {
    NSString * info = [[NSUserDefaults standardUserDefaults] objectForKey:@"__keepFront"];
    return info;
}


@end
