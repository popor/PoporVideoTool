//
//  RootVCPresenter.h
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "RootVCProtocol.h"

// 处理和View事件
@interface RootVCPresenter : NSObject <RootVCEventHandler, RootVCDataSource
, NSTableViewDelegate, NSTableViewDataSource
>

- (void)setMyInteractor:(id)interactor;

- (void)setMyView:(id)view;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

@end

