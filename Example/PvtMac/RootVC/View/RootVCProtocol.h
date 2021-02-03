//
//  RootVCProtocol.h
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import <Cocoa/Cocoa.h>

#import "EditableTextField.h"
#import "NSView_prefix.h"
#import "AcceptDragFileView.h"

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

@property (nonatomic, strong) NSButton    * outputOriginSizeBT;

@property (nonatomic, strong) NSButton    * outputSizeBT;
@property (nonatomic, strong) NSTextField * outputWidthTF;
@property (nonatomic, strong) NSTextField * outputHeightTF;

@property (nonatomic, strong) NSButton    * outputBitScaleBT;
@property (nonatomic, strong) NSTextField * outputBitScaleTF;

@property (nonatomic, strong) NSButton    * outputBitBT;
@property (nonatomic, strong) NSTextField * outputBitRateTF;


@property (nonatomic, strong) NSButton     * addVideoBT;
@property (nonatomic, strong) NSButton     * compressVideoBT;

@property (nonatomic, strong) AcceptDragFileView * dragFileView;
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

- (void)outputSizeAction:(NSButton *)bt;

- (void)outputBitAction:(NSButton *)bt;

- (void)addVideoPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
