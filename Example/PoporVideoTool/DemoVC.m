//
//  DEMOViewController.m
//  PoporVideoTool
//
//  Created by popor on 01/28/2021.
//  Copyright (c) 2021 popor. All rights reserved.
//

#import "DemoVC.h"

#import <PoporUI/PoporUI.h>
#import <PoporFoundation/PoporFoundation.h>

#import <PoporMedia/PoporMedia.h>
#import <PoporAVPlayer/PoporAVPlayerVC.h>
#import <Masonry/Masonry.h>

#import "PoporVideoTool.h"


@interface DemoVC ()

@property (nonatomic, strong) UIButton *albumBtn;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UITextView * tv;
@property (nonatomic, strong) NSMutableAttributedString * tvAtt;

@property (nonatomic, strong) PoporMedia  * media;
@property (nonatomic, copy  ) NSURL * playUrl;


@end

@implementation DemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频压缩";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    {
        NSString * folder  = @"compress";
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", docPath, folder] withIntermediateDirectories:YES attributes:nil error:nil];
        NSString * outPath = [NSString stringWithFormat:@"%@/%@/compress1.mp4", docPath, folder];
        NSURL * outUrl     = [NSURL fileURLWithPath:outPath];
        
        self.playUrl       = outUrl;
    }
    [self addBt1];
}

- (void)addBt1 {
    [self.view addSubview:self.albumBtn];
    
    [self.albumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
        make.centerX.mas_equalTo(-60);
        make.top.mas_equalTo(40);
    }];
    
    self.playBtn = ({
        UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        oneBT.frame =  CGRectMake(100, 100, 80, 44);
        [oneBT setTitle:@"播放" forState:UIControlStateNormal];
        [oneBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [oneBT setBackgroundColor:[UIColor brownColor]];
        
        // oneBT.titleLabel.font = [UIFont systemFontOfSize:17];
        oneBT.layer.cornerRadius = 5;
        oneBT.layer.borderColor = [UIColor redColor].CGColor;
        oneBT.layer.borderWidth = 1;
        oneBT.clipsToBounds = YES;
        
        [self.view addSubview:oneBT];
        
        [oneBT addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        
        oneBT;
    });
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.albumBtn);
        make.height.mas_equalTo(self.albumBtn);
        make.centerX.mas_equalTo(60);
        make.top.mas_equalTo(self.albumBtn);
    }];
    
    self.tv = ({
        UITextView * tv = [UITextView new];
        tv.font = [UIFont systemFontOfSize:16];
        
        [self.view addSubview:tv];
        
        tv;
    });
    [self.tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.albumBtn.mas_bottom).mas_offset(30);
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
        make.right.mas_equalTo(-20);
    }];
    {
        NSData * historyData = [NSData dataWithContentsOfURL:self.playUrl];
        if (historyData.length > 0) {
            self.tvAtt = [NSMutableAttributedString new];
            [self.tvAtt addString:@"之前压缩后size: " font:self.tv.font color:UIColor.blackColor];
            [self.tvAtt addString:[NSString stringWithFormat:@"%@", [UIDevice getHumanSize:historyData.length]] font:self.tv.font color:UIColor.redColor];
            
            self.tv.attributedText = self.tvAtt;
        }
    }
}

- (UIButton *)albumBtn {
    if (!_albumBtn) {
        UIButton * oneBT = ({
            UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
            [oneBT setTitle:@"压缩" forState:UIControlStateNormal];
            [oneBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [oneBT setBackgroundColor:[UIColor brownColor]];
            
            oneBT.layer.cornerRadius = 5;
            oneBT.layer.borderColor = [UIColor redColor].CGColor;
            oneBT.layer.borderWidth = 1;
            oneBT.clipsToBounds = YES;
            
            [self.view addSubview:oneBT];
            
            [oneBT addTarget:self action:@selector(albumAction:) forControlEvents:UIControlEventTouchUpInside];
            
            oneBT;
        });
        _albumBtn = oneBT;
    }
    return _albumBtn;
}


- (void)albumAction:(id)sender {
    //[self compress1];
    
    [self pickVideoAction];
}

- (void)pickVideoAction {
    
    @weakify(self);
    self.media = [PoporMedia new];
    [self.media showVideoACTitle:@"选取视频" message:nil vc:self videoIconSize:CGSizeMake(540, 960) qualityType:UIImagePickerControllerQualityTypeIFrame960x540 finish:^(NSURL *videoURL, NSString *videoPath, NSData *imageData, UIImage *image, PHAsset *phAsset, CGFloat time, CGFloat videoSize) {
        @strongify(self);
        
        [self compressVideoUrl:videoURL];
    }];
}


- (void)compressVideoUrl:(NSURL *)videoOriginUrl {
    // 删除目标地址
    [NSFileManager deleteFile:self.playUrl.path];
    NSLog(@"outPath: %@", self.playUrl);
    
    __block ProgressView_Popor * pv = ({
        ProgressView_Popor * pv = [ProgressView_Popor new];
        pv.frame  = CGRectMake(0, 0, 100, 100);
        pv.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        
        [self.view addSubview:pv];
        pv;
    });
    
    NSDate * date0 = [NSDate date];
    {   // 添加注释
        self.tvAtt = [NSMutableAttributedString new];
        
        [self.tvAtt addString:@"原视频size: " font:self.tv.font color:UIColor.blackColor];
        NSData * data = [NSData dataWithContentsOfURL:videoOriginUrl];
        [self.tvAtt addString:[NSString stringWithFormat:@"%@", [UIDevice getHumanSize:data.length]] font:self.tv.font color:UIColor.redColor];
        
        self.tv.attributedText = self.tvAtt;
    }
    
    {
        //    NSString * path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
        //    NSString * folder  = @"compress";
        //    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        //    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", docPath, folder] withIntermediateDirectories:YES attributes:nil error:nil];
        //    NSString * outPath = [NSString stringWithFormat:@"%@/%@/compress1.mp4", docPath, folder];
        //    NSURL * outUrl     = [NSURL fileURLWithPath:outPath];
        //    self.playUrl       = outUrl;
    }
    
    // 初始化 encoder
    PoporVideoTool *encoder = [PoporVideoTool.alloc initWithAsset:[AVAsset assetWithURL:videoOriginUrl]];
    encoder.outputFileType  = AVFileTypeMPEG4;
    encoder.outputURL       = self.playUrl;
    
    // 获取压缩视频Size
    CGSize prioritySize = CGSizeMake(540, 960);
    CGSize originSize   = [PoporVideoTool sizeVideoUrl:videoOriginUrl];
    CGSize targetSize   = [PoporVideoTool sizeFrom:originSize toSize:prioritySize];
    
    // 设置压缩配置
    encoder.videoSettings = [PoporVideoTool dicVideoSettingsSize:targetSize bitRate:0]; // 视频参数
    encoder.audioSettings = [PoporVideoTool dicAudioSettings]; // 音频参数
    
    // 异步压缩
    [encoder compressCompletion:^(PoporVideoTool * _Nonnull poporVideoTool) {
        [pv removeFromSuperview];
        pv = nil;
        
        switch (poporVideoTool.status) {
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"Video export succeeded");
                NSDate * date1 = [NSDate date];
                
                {   // 添加注释
                    [self.tvAtt addString:@"\n压缩后size: " font:self.tv.font color:UIColor.blackColor];
                    [self.tvAtt addString:[NSString stringWithFormat:@"%@", [UIDevice getHumanSize:[NSData dataWithContentsOfURL:self.playUrl].length]] font:self.tv.font color:UIColor.redColor];
                    
                    [self.tvAtt addString:@"\n\n花费时间: " font:self.tv.font color:UIColor.blackColor];
                    NSString * time = [NSDate clockText:date1.unixTimestamp -date0.unixTimestamp];
                    [self.tvAtt addString:time font:self.tv.font color:UIColor.redColor];
                    
                    self.tv.attributedText = self.tvAtt;
                }
                break;
            }
            case AVAssetExportSessionStatusCancelled: {
                NSLog(@"Video export cancelled");
                {   // 添加注释
                    [self.tvAtt addString:@"\n压缩取消: " font:self.tv.font color:UIColor.blackColor];
                    
                    self.tv.attributedText = self.tvAtt;
                }
                break;
            }
            default: {
                NSLog(@"Video export failed with error: %@ (%li)", encoder.error.localizedDescription, encoder.error.code);
                {   // 添加注释
                    [self.tvAtt addString:@"\n压缩失败: " font:self.tv.font color:UIColor.blackColor];
                    
                    self.tv.attributedText = self.tvAtt;
                }
                break;
            }
        }
    } progress:^(CGFloat progress) {
        [pv setCurrentProgress:progress];
        if (progress >= 1) {
            [pv removeFromSuperview];
            pv = nil;
        }
    }];
}

- (void)playAction {
    // self.playUrl
    NSDictionary * dic = @{
        @"videoURL":self.playUrl,
        @"title":@"压缩视频",
    };
    PoporAVPlayerVC * vc = [[PoporAVPlayerVC alloc] initWithDic:dic];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)compressVideoUrl:(NSURL *)videoOriginUrl outputUrl:(NSURL *)outputURL{
    // 删除目标地址
    [NSFileManager deleteFile:outputURL.path];
    
    // 初始化 encoder
    PoporVideoTool *encoder = [PoporVideoTool.alloc initWithAsset:[AVAsset assetWithURL:videoOriginUrl]];
    encoder.outputFileType  = AVFileTypeMPEG4;
    encoder.outputURL       = outputURL;
    
    // 获取压缩视频Size
    CGSize prioritySize = CGSizeMake(540, 960);
    CGSize originSize   = [PoporVideoTool sizeVideoUrl:videoOriginUrl];
    CGSize targetSize   = [PoporVideoTool sizeFrom:originSize toSize:prioritySize];
    
    // 设置压缩配置
    encoder.videoSettings = [PoporVideoTool dicVideoSettingsSize:targetSize bitRate:0]; // 视频参数
    encoder.audioSettings = [PoporVideoTool dicAudioSettings]; // 音频参数
    
    // 异步压缩
    [encoder compressCompletion:^(PoporVideoTool * _Nonnull poporVideoTool) {
        switch (poporVideoTool.status) {
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"Video export succeeded");
                break;
            }
            case AVAssetExportSessionStatusCancelled: {
                NSLog(@"Video export cancelled");
                break;
            }
            default: {
                NSLog(@"Video export failed with error: %@ (%li)", encoder.error.localizedDescription, encoder.error.code);
                break;
            }
        }
    } progress:^(CGFloat progress) {
        NSLog(@"progress: %f", progress);
    }];
}

@end
