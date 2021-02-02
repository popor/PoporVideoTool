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

//@property (nonatomic, strong) IBOutlet NSScrollView * infoSV;
//@property (nonatomic, strong) IBOutlet NSTableView  * infoTV;
//@property (nonatomic, strong) IBOutlet NSBox        * setBox;
//@property (nonatomic, strong) IBOutlet NSButton     * addVideoBT;
//@property (nonatomic, strong) IBOutlet NSButton     * compressVideoBT;

@property (nonatomic, strong) NSScrollView * infoSV;
@property (nonatomic, strong) NSTableView  * infoTV;
@property (nonatomic, strong) NSBox        * setBox;
@property (nonatomic, strong) NSButton     * addVideoBT;
@property (nonatomic, strong) NSButton     * compressVideoBT;

- (IBAction)addVideoAction:(id)sender;

@end

