//
//  RootVC.m
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import "RootVC.h"
#import "RootVCPresenter.h"
#import "RootVCInteractor.h"

#import <Masonry/Masonry.h>
#import "PoporNS.h"

@interface RootVC ()

@property (nonatomic, strong) RootVCPresenter * present;

@end

@implementation RootVC
@synthesize outputFolderBT;
@synthesize outputFolderTF;

@synthesize outputOriginSizeBT;

@synthesize outputSizeBT;
@synthesize outputWidthTF;
@synthesize outputHeightTF;

@synthesize outputBitScaleBT;
@synthesize outputBitScaleTF;

@synthesize outputBitBT;
@synthesize outputBitRateTF;

@synthesize addVideoBT;
@synthesize compressVideoBT;

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [self assembleViper];
    [super viewDidLoad];
    
    if (!self.title) {
        self.title = @"RootVC";
    }
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark - VCProtocol
- (NSViewController *)vc {
    return self;
}

- (NSTableView *)videoTV {
    return self.infoTV;
}

#pragma mark - viper views
- (void)assembleViper {
    if (!self.present) {
        RootVCPresenter * present = [RootVCPresenter new];
        RootVCInteractor * interactor = [RootVCInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

- (void)addViews {
    
    self.addVideoBT = ({
        NSButton * button = [NSButton buttonWithTitle:@"添加文件" target:self action:@selector(addVideoAction:)];
        [self.view addSubview:button];
        
        button;
    });
    
    self.compressVideoBT = ({
        NSButton * button = [NSButton buttonWithTitle:@"压缩" target:self.present action:@selector(compressVideoAction:)];
        [self.view addSubview:button];
        
        button;
    });
    
    [self addTvs];
    [self addBoxs];
    
    [self updateMasonry];
    
}

- (void)addTvs {
    @weakify(self);
    [self addTagTVs:^(NSScrollView *sv, NSTableView *tv) {
        @strongify(self);
        
        self.infoSV = sv;
        self.infoTV = tv;
    }];
    
    
    self.outputFolderBT = ({
        NSButton * button = [NSButton buttonWithTitle:@"保存文件件" target:self.present action:@selector(outputFolderAction:)];
        [self.view addSubview:button];
        
        button;
    });
    
    self.outputFolderTF = ({
        EditableTextField * tf = [[EditableTextField alloc] init];
        tf.editable = NO;
        tf.selectable = YES;
        [self.view addSubview:tf];
        
        tf;
    });
    
    //....................................................................................
    [self.infoSV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        //make.bottom.mas_equalTo(-20);
        make.width.mas_greaterThanOrEqualTo(200);
        make.height.mas_greaterThanOrEqualTo(100);
    }];
    
    [self.outputFolderBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.infoSV.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(80, 24));
        make.bottom.mas_equalTo(-20);
    }];
    
    [self.outputFolderTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.outputFolderBT);
        make.left.mas_equalTo(self.outputFolderBT.mas_right).mas_offset(10);
        make.height.mas_equalTo(self.outputFolderBT);
        make.right.mas_equalTo(self.infoSV);
    }];
}

- (void)updateMasonry {
    [self.view addSubview:self.infoSV];
    [self.view addSubview:self.setBox];
    [self.view addSubview:self.addVideoBT];
    [self.view addSubview:self.compressVideoBT];
    
    
    [self.addVideoBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.setBox.mas_bottom).mas_offset(20);
        make.left.mas_equalTo(self.setBox);
        make.bottom.mas_equalTo(-20);
        //make.right.mas_equalTo(self.setBox);
        make.size.mas_equalTo(CGSizeMake(75, 24));
    }];
    
    [self.compressVideoBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addVideoBT);
        //make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.addVideoBT);
        make.right.mas_equalTo(-20);
        
        make.size.mas_equalTo(CGSizeMake(75, 24));
    }];
    
    [self.view needsUpdateConstraints];
}

// MARK: tv
- (void)addTagTVs: (void (^ _Nullable)(NSScrollView * sv, NSTableView * tv))finish {
    // create a table view and a scroll view
    NSScrollView * sv = [[NSScrollView alloc] initWithFrame:CGRectZero];
    NSTableView  * tv = [[NSTableView alloc] initWithFrame:sv.bounds];
    tv.tag = 0;
    
    sv.borderType = NSLineBorder; // 可以使得TV仅仅靠边
    
    
    //tv.backgroundColor = NSColor.yellowColor;
    
    //sv.backgroundColor = NSColor.controlBackgroundColor;
    //sv.backgroundColor = NSColor.redColor;
    //tv.headerView.layer.backgroundColor = NSColor.redColor.CGColor;
    
    
    //sv.layer.cornerRadius  = 6;
    //sv.layer.masksToBounds = YES;
    
    // 设计圆角
    [sv setWantsLayer:YES];
    [sv.layer setCornerRadius:4];
    [sv.contentView setWantsLayer:YES];
    [sv.contentView.layer setCornerRadius:4.0f];
    
    NSArray * folderEntityArray = [self columeArray];
    for (int i=0; i<folderEntityArray.count; i++) {
        NSTableColumn * column = folderEntityArray[i];
        [tv addTableColumn:column];
    }
    
    tv.delegate              = self.present;
    tv.dataSource            = self.present;
    sv.documentView          = tv;
    sv.hasVerticalScroller   = YES;
    sv.hasHorizontalScroller = YES;
    
    [self.view addSubview:sv];
    [tv reloadData];
    self.infoTV = tv;
    
    if (finish) {
        finish(sv, tv);
    }
}

- (NSMutableArray *)columeArray {
    NSMutableArray * array = [NSMutableArray new];
    NSArray * titleArray =
    @[TvIdSort, TvIdTitle, TvIdResolution,  TvIdBitRate, TvIdSize,
      TvIdTime
    ];
    
    NSArray * idArray =
    @[@(TvIdType_Sort),@(TvIdType_Title),@(TvIdType_Resolution),@(TvIdType_BitRate),@(TvIdType_Size),
      @(TvIdType_Time),
    ];
    
    NSArray * widthArray    = @[@(30), @(200), @(100), @(80), @(80),    @(80), ];
    NSArray * minWidthArray = @[@(30), @(60) , @(100), @(80), @(80),    @(80), ];
    for (NSInteger i = 0; i<titleArray.count; i++) {
        NSString * title     = titleArray[i];
        NSString * idN       = idArray[i];
        NSNumber * widthN    = widthArray[i];
        NSNumber * minWidthN = minWidthArray[i];
        
        NSTableColumn * column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%li", idN.integerValue]];
        column.width         = widthN.floatValue;
        column.minWidth      = minWidthN.floatValue;
        column.title         = title;
        column.headerToolTip = title;
        
        [array addObject:column];
    }
    return array;
}

- (void)addBoxs {
 
    self.setBox = ({
        NSBox * view = [NSBox new];
        view.boxType = NSBoxCustom;
        view.cornerRadius = 4;
        
        [self.view addSubview:view];
        view;
    });
    
    [self.setBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(self.infoSV.mas_right).mas_offset(20);
        //make.bottom.mas_equalTo(-20);
        make.width.mas_equalTo(281);
        make.height.mas_equalTo(124);
        make.right.mas_equalTo(-20);
    }];
    //---- 1.1
    self.outputOriginSizeBT = ({
        NSButton * button = [NSButton radioButtonWithTitle:@"原始分辨率" target:self.present action:@selector(outputSizeAction:)];
        
        [self.setBox addSubview:button];
        
        button;
    });
    //---- 1.2
    self.outputSizeBT = ({
        NSButton * button = [NSButton radioButtonWithTitle:@"固定分辨率" target:self.present action:@selector(outputSizeAction:)];
        [self.setBox addSubview:button];
        
        button.toolTip = @"视频压缩后的长宽为540x960或者960x540";
        button;
    });
    
    self.outputWidthTF = ({
        EditableTextField * tf = [[EditableTextField alloc] init];
        tf.editable    = YES;
        tf.selectable  = YES;
        tf.stringValue = @"540";
        [self.setBox addSubview:tf];
        
        tf;
    });
    self.outputHeightTF = ({
        EditableTextField * tf = [[EditableTextField alloc] init];
        tf.editable    = YES;
        tf.selectable  = YES;
        tf.stringValue = @"960";
        [self.setBox addSubview:tf];
        
        tf;
    });
    
    //---- 2.1
    self.outputBitScaleBT = ({
        NSButton * button = [NSButton radioButtonWithTitle:@"相对比特率" target:self.present action:@selector(outputBitAction:)];
        [self.setBox addSubview:button];
        
        button.toolTip = @"推荐使用此配置，微信视频压缩系数为2，（视频长x视频宽x2）";
        
        button;
    });
    
    self.outputBitScaleTF = ({
        EditableTextField * tf = [[EditableTextField alloc] init];
        tf.editable    = YES;
        tf.selectable  = YES;
        tf.placeholderString = @"0.1 ~ 10.0";
        tf.stringValue = @"2";
        [self.setBox addSubview:tf];
        
        tf;
    });
    //---- 2.2
    self.outputBitBT = ({
        NSButton * button = [NSButton radioButtonWithTitle:@"固定比特率" target:self.present action:@selector(outputBitAction:)];
        [self.setBox addSubview:button];
        
        button.toolTip = @"此配置能保证视频容量固定不变";
        
        button;
    });
    
    self.outputBitRateTF = ({
        EditableTextField * tf = [[EditableTextField alloc] init];
        tf.editable    = YES;
        tf.selectable  = YES;
        tf.placeholderString = @"1000 000 ~ 10 000 000";
        tf.stringValue = @"1000 000";
        [self.setBox addSubview:tf];
        
        tf;
    });
    
    CGFloat LHeight = 20;
    CGFloat left    = 5;
    CGFloat BtWidth = 90;
    //....................................................................................
    [self.outputOriginSizeBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(left);
        make.width.mas_equalTo(BtWidth);
        make.height.mas_equalTo(20);
        //make.height.mas_equalTo(self.outputSizeBT.font.lineHeight);
    }];
    
    [self.outputSizeBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.outputWidthTF);
        make.left.mas_equalTo(5);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(20);
        //make.height.mas_equalTo(self.outputSizeBT.font.lineHeight);
    }];
    [self.outputWidthTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.outputOriginSizeBT.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(self.outputSizeBT.mas_right).mas_offset(10);
        make.height.mas_equalTo(LHeight);
    }];
    [self.outputHeightTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.outputWidthTF);
        make.left.mas_equalTo(self.outputWidthTF.mas_right).mas_offset(10);
        make.width.mas_equalTo(self.outputWidthTF);
        make.right.mas_equalTo(-left);
        make.height.mas_equalTo(LHeight);
    }];
    
    // 2.1
    [self.outputBitScaleBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.outputBitScaleTF);
        make.left.mas_equalTo(left);
        make.width.mas_equalTo(BtWidth);
    }];
    [self.outputBitScaleTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.outputSizeBT.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.outputBitScaleBT.mas_right).mas_offset(10);
        make.right.mas_equalTo(-left);
        make.height.mas_equalTo(LHeight);
    }];
    [self.outputBitBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.outputBitRateTF);
        make.left.mas_equalTo(left);
        make.width.mas_equalTo(BtWidth);
    }];
    [self.outputBitRateTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.outputBitScaleTF.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.outputBitBT.mas_right).mas_offset(10);
        make.right.mas_equalTo(-left);
        make.height.mas_equalTo(LHeight);
    }];
    
    // 默认值
    self.outputOriginSizeBT.state = NSControlStateValueOn;
    self.outputBitScaleBT.state   = NSControlStateValueOn;
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

// -----------------------------------------------------------------------------

- (IBAction)addVideoAction:(id)sender {
    [self.present addVideoAction:sender];
}

@end
