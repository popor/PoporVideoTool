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
#import <ReactiveObjC/ReactiveObjC.h>

@interface RootVC ()

@property (nonatomic, strong) RootVCPresenter * present;

@end

@implementation RootVC


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
    @weakify(self);
    [self addTagTVs:^(NSScrollView *sv, NSTableView *tv) {
        @strongify(self);
        
        self.infoSV = sv;
        self.infoTV = tv;
    }];
    
    self.setBox = ({
        NSBox * view = [NSBox new];
        
        [self.view addSubview:view];
        view;
    });
    
    self.addVideoBT = ({
        NSButton * button = [NSButton buttonWithTitle:@"添加文件" target:self action:@selector(addVideoAction:)];
        [self.view addSubview:button];
        
        button;
    });
    
    self.compressVideoBT = ({
        NSButton * button = [NSButton buttonWithTitle:@"压缩" target:self action:@selector(addVideoAction:)];
        [self.view addSubview:button];
        
        button;
    });
    
    [self updateMasonry];
    
}

- (void)updateMasonry {
    [self.view addSubview:self.infoSV];
    [self.view addSubview:self.setBox];
    [self.view addSubview:self.addVideoBT];
    [self.view addSubview:self.compressVideoBT];
    
    [self.infoSV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
        make.width.mas_greaterThanOrEqualTo(200);
    }];
    [self.infoTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-0);
        make.right.mas_equalTo(-0);
    }];
    
    [self.setBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(self.infoSV.mas_right).mas_offset(20);
        //make.bottom.mas_equalTo(-20);
        make.width.mas_equalTo(281);
        make.height.mas_equalTo(114);
        make.right.mas_equalTo(-20);
    }];
    
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
    tv.backgroundColor = NSColor.quaternaryLabelColor;
    // scrubberTexturedBackgroundColor : 刷子, 线条颜色.
    
    sv.layer.cornerRadius  = 6;
    sv.layer.masksToBounds = YES;
    
    //tv.headerView.layer.backgroundColor = NSColor.redColor.CGColor;
    
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

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

// -----------------------------------------------------------------------------

- (IBAction)addVideoAction:(id)sender {
    [self.present addVideoAction:sender];
}

@end
