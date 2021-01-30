//
//  RootVC.h
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "RootVCProtocol.h"

@interface RootVC : NSViewController <RootVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)addViews;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

//@property (nonatomic, strong) IBOutlet NSButton    * addVideoBT;
//@property (nonatomic, strong) IBOutlet NSButton    * compressVideoBT;
@property (nonatomic, strong) IBOutlet NSTableView * infoTV;

- (IBAction)addVideoAction:(id)sender;

@end

