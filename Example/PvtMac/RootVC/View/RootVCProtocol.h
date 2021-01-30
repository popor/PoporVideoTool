//
//  RootVCProtocol.h
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import <Cocoa/Cocoa.h>

#import "EditableTextField.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RootTvCellType) {
    RootTvCellTypeOrder = 1,
    RootTvCellTypeTitle,
    RootTvCellTypeResolution,// 分辨率
    RootTvCellTypeBitRate,
    RootTvCellTypeSize, // 容量
    
    RootTvCellTypeDuration,
};


// MARK: 对外接口
@protocol RootVCProtocol <NSObject>

- (NSViewController *)vc;
- (NSTableView *)videoTV;

// MARK: 自己的

// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol RootVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol RootVCEventHandler <NSObject>

- (IBAction)addVideoAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
