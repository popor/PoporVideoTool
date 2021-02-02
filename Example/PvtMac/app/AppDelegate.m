//
//  AppDelegate.m
//  PvtMac
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self keepAtFrontAction:NO];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (void)keepAtFrontAction:(BOOL)front {
    if (front) {
        [NSApp.windows[0] setLevel:NSNormalWindowLevel];
    }else{
        [NSApp.windows[0] setLevel:NSFloatingWindowLevel];
    }
}

@end
