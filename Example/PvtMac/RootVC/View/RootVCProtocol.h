//
//  RootVCProtocol.h
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import <Cocoa/Cocoa.h>

#import "EditableTextField.h"
#import "NSView_prefix.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TvIdType) {
    TvIdType_Sort,
    TvIdType_Title,
    TvIdType_Resolution,
    TvIdType_BitRate,
    TvIdType_Size,
    TvIdType_Time,
};


static NSString * TvIdSort       = @"顺序";
static NSString * TvIdTitle      = @"名称";
static NSString * TvIdResolution = @"分辨率";
static NSString * TvIdBitRate    = @"比特率";
static NSString * TvIdSize       = @"容量";
static NSString * TvIdTime       = @"时间";

// MARK: 对外接口
@protocol RootVCProtocol <NSObject>

- (NSViewController *)vc;
- (NSTableView *)videoTV;

// MARK: 自己的
@property (nonatomic, strong) NSButton    * outputFolderBT;
@property (nonatomic, strong) NSTextField * outputFolderTF;

@property (nonatomic, strong) NSTextField * outputSizeL;
@property (nonatomic, strong) NSTextField * outputWidthTF;
@property (nonatomic, strong) NSTextField * outputHeightTF;

@property (nonatomic, strong) NSTextField * outputBitL;
@property (nonatomic, strong) NSTextField * outputBitScaleTF;
@property (nonatomic, strong) NSTextField * outputBitRateTF;


@property (nonatomic, strong) NSButton     * addVideoBT;
@property (nonatomic, strong) NSButton     * compressVideoBT;


// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol RootVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol RootVCEventHandler <NSObject>

- (void)addVideoAction:(id)sender;
- (void)compressVideoAction:(NSButton * _Nullable)sender;

- (void)outputFolderAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
