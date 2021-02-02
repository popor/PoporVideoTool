//
//  RootVCPresenter.m
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import "RootVCPresenter.h"
#import "RootVCInteractor.h"

//#import <ReactiveObjC/ReactiveObjC.h>
#import <PoporFoundation/PoporFoundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "PoporVideoTool.h"

static CGFloat CellHeight = 20;

@interface RootVCPresenter ()

@property (nonatomic, weak  ) id<RootVCProtocol> view;
@property (nonatomic, strong) RootVCInteractor * interactor;

@end

@implementation RootVCPresenter

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setMyInteractor:(RootVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<RootVCProtocol>)view {
    self.view = view;
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    
    
}

#pragma mark - VC_DataSource
#pragma mark table delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.interactor.infoArray.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return CellHeight;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    EditableTextField * cellTF = (EditableTextField *)[tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if (!cellTF) {
        cellTF = [self tableView:tableView cellTFForColumn:tableColumn row:row edit:NO initBlock:^(NSDictionary *dic) {
            NSTextField * tf = dic[@"tf"];
            tf.alignment = NSTextAlignmentLeft;
        }];
    }
    
    VideoEntity    * entity = self.interactor.infoArray[row];    
    switch (tableColumn.identifier.integerValue) {
        case TvIdType_Sort: {//@"顺序"
            cellTF.stringValue = [NSString stringWithFormat:@"%li", row];
            
            return cellTF;
        }
        case TvIdType_Title: {//@"名称"
            cellTF.stringValue = entity.fileName;
            
            return cellTF;
        }
        case TvIdType_Resolution: {//@"分辨率"
            cellTF.stringValue = [NSString stringWithFormat:@"%lix%li", (long)entity.resolution.width, (long)entity.resolution.height];
            
            return cellTF;
        }
        case TvIdType_BitRate: {//@"比特率"
            cellTF.stringValue = [NSString stringWithFormat:@"%li", (long)entity.bitRate];
            
            return cellTF;
        }
            
            
        case TvIdType_Size: {//@"容量"
            cellTF.stringValue = entity.sizeString;
            
            return cellTF;
        }
            
        case TvIdType_Time: {//@"时间"
            cellTF.stringValue = entity.durationString;
            
            return cellTF;
        }
        default:
            break;
    }

    return cellTF;
}

- (EditableTextField *)tableView:(NSTableView *)tableView cellTFForColumn:(NSTableColumn *)tableColumn row:(NSInteger)row edit:(BOOL)edit initBlock:(BlockPDic)block {
    EditableTextField * cellTF = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self.view];
    if (!cellTF) {
        int font = 15;
        cellTF = [[EditableTextField alloc] initWithFrame:CGRectMake(0, 0, tableColumn.width, CellHeight)];
        cellTF.font            = [NSFont systemFontOfSize:font];
        cellTF.alignment       = NSTextAlignmentCenter;
        cellTF.editable        = edit;
        cellTF.identifier      = tableColumn.identifier;
        
        cellTF.backgroundColor = [NSColor clearColor];
        cellTF.bordered        = NO;
        
        cellTF.lineBreakMode   = NSLineBreakByTruncatingMiddle;
        if (block) {
            block(@{@"tf":cellTF});
        }
    }
    cellTF.tag = row;
    return cellTF;
}

//- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
//{
//    //NSLog(@"clumn : %@", tableColumn.identifier);
//}

- (void)tableViewClick:(NSTableView *)tableView
{
    NSInteger row = tableView.clickedRow;
    NSInteger Column = tableView.clickedColumn;
    NSLog(@"点击Column: %li row: %li",Column, row);
    //    if (row>=0) {
    //        self.currentAE = self.archiveArray[row];
    //
    //        if ([self.currentAE.arch1 isEqualToString:@"x86_64"]) {
    //            self.xcarchiveInfoTF.stringValue = @"x86_64";
    //            self.isMacAPP = YES;
    //            self.uuidTF.stringValue = [NSString stringWithFormat:@"UUID: %@", self.currentAE.uuid2];
    //        }else{
    //            self.xcarchiveInfoTF.stringValue = @"arm64,armv7";
    //            self.isMacAPP = NO;
    //            self.uuidTF.stringValue = [NSString stringWithFormat:@"UUID: %@", self.currentAE.uuid1];
    //        }
    //    }
    /*
     if (Column == 5) {
     if (!self.archiveSetWC) {
     self.archiveSetWC = [[ArchiveSetWC alloc] initWithWindowNibName:@"ArchiveSetWC"];
     self.archiveSetWC.delegate = self;
     }
     
     [self.archiveSetWC showWindow:self];
     [self.archiveSetWC updateArchiveRecordEntity:self.arEntityArray[row]];
     }
     if (Column == 4) {
     ArchiveRecordEntity * oneAREntity = self.arEntityArray[row];
     [oneAREntity freshVersion];
     [ArchiveRecordDB updateArchiveRecordRowVersion:oneAREntity];
     
     [self.infoTV reloadData];
     }
     //*/
}

#pragma mark - VC_EventHandler
- (IBAction)addVideoAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setAllowsMultipleSelection:YES];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"mp4", @"mov"]];
    
    [NSApp.windows[0] setLevel:NSNormalWindowLevel];
    
    if ([panel runModal] == NSModalResponseOK) {
        
        for (int i = 0; i<panel.URLs.count; i++) {
            NSString * path   = [panel.URLs[i] path];
            
            [self addXcarchivePath:path];
        }
        
        [self.view.videoTV reloadData];
    }
    
}

- (void)addXcarchivePath:(NSString *)path {
    VideoEntity * entity = [VideoEntity new];
    entity.path = path;
    entity.fileName = path.lastPathComponent;
    
    NSURL * url = [NSURL fileURLWithPath:path];
    entity.resolution = [PoporVideoTool sizeVideoUrl:url];
    
    NSData * data = [NSData dataWithContentsOfURL:url];
    entity.size       = data.length;
    entity.sizeString = [self getHumanSize:entity.size];
    
    entity.duration   = [PoporVideoTool durationVideoUrl:url];
    entity.durationString = [NSDate clockText:entity.duration];
    
    entity.bitRate = [PoporVideoTool bitRateVideoUrl:url];
    entity.frameRate = [PoporVideoTool frameRateVideoUrl:url];
    
    [self.interactor.infoArray addObject:entity];
}

- (NSString *)getHumanSize:(CGFloat)fileSizeFloat {
    __block NSString * humanSize;
    [self fileSize:fileSizeFloat complete:^(CGFloat size, NSString *unit) {
        humanSize = [NSString stringWithFormat:@"%.02f%@", size, unit];
    }];
    return humanSize;;
}

- (void)fileSize:(NSInteger)fileSize complete:(void (^ __nullable)(CGFloat sizeFloat, NSString * sizeUnit))complete {
    if (!complete) {
        return;
    }
    CGFloat KbMax = 1024.0;
    CGFloat MbMax = 1048576.0;
    CGFloat GbMax = 1073741824.0;
    CGFloat TbMax = 1099511627776.0;
    
    if (fileSize < MbMax) {
        complete(fileSize/KbMax, @"KB");
    } else if (fileSize < GbMax) {
        complete(fileSize/MbMax, @"MB");
    } else if (fileSize < TbMax) {
        complete(fileSize/GbMax, @"GB");
    } else {
        complete(fileSize/TbMax, @"TB");
    }
}


#pragma mark - Interactor_EventHandler

@end
