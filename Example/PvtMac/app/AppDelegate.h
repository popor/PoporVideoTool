//
//  AppDelegate.h
//  PvtMac
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>


// IB事件, 没有sender参数的话, 很可能看不到.
- (IBAction)deleteVideoAction:(id)sender;

@end

