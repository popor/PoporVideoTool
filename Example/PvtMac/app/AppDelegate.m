//
//  AppDelegate.m
//  PvtMac
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.
//

#import "AppDelegate.h"
#import "AppKeepFront.h"

@interface AppDelegate ()

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
    
    {
        NSApplication * app = [NSApplication sharedApplication];
        NSWindow * window   = app.windows.firstObject;
        self.window = window;
    }
    
    [[AppKeepFront share] showTitleBarFrontBT];
    [self updateWindowTitleEvent];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - IBAction
- (IBAction)deleteVideoAction:(id)sender {
    [MGJRouter openURL:MUrl_keyboard_deleteVideo];
}

- (void)updateWindowTitleEvent {
    NSApplication * app     = [NSApplication sharedApplication];
    NSWindow * window       = app.windows.firstObject;
    
    [MRouterConfig registerURL:MUrl_windowTitle toHandel:^(NSDictionary *routerParameters) {
        NSDictionary * dic = routerParameters[MGJRouterParameterUserInfo];
        NSString     * title = dic[@"title"];
        window.title = title;
    }];
}

// 当点击了关闭window,再次点击Dock上的icon时候,执行以下代码可以再次显示window.
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    if (flag) {
        return NO;
    } else{
        [self.window makeKeyAndOrderFront:self];
        return YES;
    }
}

@end
