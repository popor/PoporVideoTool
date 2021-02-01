//
//  PoporVideoTool.m
//
// This file is part of the SDAVAssetExportSession package.
//
// Created by Olivier Poitrey <rs@dailymotion.com> on 13/03/13.
// Copyright 2013 Olivier Poitrey. All rights servered.
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//


#import "PoporVideoTool.h"

@interface PoporVideoTool ()

@property (nonatomic, assign, readwrite) float progress;

@property (nonatomic, strong) AVAssetReader                        * reader;
@property (nonatomic, strong) AVAssetReaderVideoCompositionOutput  * videoOutput;
@property (nonatomic, strong) AVAssetReaderAudioMixOutput          * audioOutput;
@property (nonatomic, strong) AVAssetWriter                        * writer;
@property (nonatomic, strong) AVAssetWriterInput                   * videoInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor * videoPixelBufferAdaptor;
@property (nonatomic, strong) AVAssetWriterInput                   * audioInput;
@property (nonatomic, strong) dispatch_queue_t                       inputQueue;

@end

@implementation PoporVideoTool {
    NSError * _error;
    NSTimeInterval duration;
    CMTime lastSamplePresentationTime;
}

+ (id)exportSessionWithAsset:(AVAsset *)asset {
    return [PoporVideoTool.alloc initWithAsset:asset];
}

- (id)initWithAsset:(AVAsset *)asset {
    if ((self = [super init])){
        _asset     = asset;
        _timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
    }

    return self;
}

#pragma mark - 压缩函数
- (void)compressCompletion:(PoporVideoBlock_PTool _Nonnull)completionBlock {
    [self compressCompletion:completionBlock progress:nil];
}

- (void)compressCompletion:(PoporVideoBlock_PTool _Nonnull)completionBlock_ progress:(PoporVideoBlock_PFloat _Nullable)progressBlock_ {
    NSParameterAssert(completionBlock_ != nil);
    [self cancelExport];
    self.completionBlock = completionBlock_;
    self.progressBlock   = progressBlock_;

    if (!self.outputURL) {
        _error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorExportFailed userInfo:@{NSLocalizedDescriptionKey: @"Output URL not set"}];
        [self excuteCompletionBlock];
        return;
    }

    NSError *readerError;
    self.reader = [AVAssetReader.alloc initWithAsset:self.asset error:&readerError];
    if (readerError) {
        _error = readerError;
        [self excuteCompletionBlock];
        return;
    }

    NSError *writerError;
    self.writer = [AVAssetWriter assetWriterWithURL:self.outputURL fileType:self.outputFileType error:&writerError];
    if (writerError) {
        _error = writerError;
        [self excuteCompletionBlock];
        return;
    }

    self.reader.timeRange = self.timeRange;
    self.writer.shouldOptimizeForNetworkUse = self.shouldOptimizeForNetworkUse;
    self.writer.metadata = self.metadata;

    NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];


    if (CMTIME_IS_VALID(self.timeRange.duration) && !CMTIME_IS_POSITIVE_INFINITY(self.timeRange.duration)) {
        duration = CMTimeGetSeconds(self.timeRange.duration);
    } else {
        duration = CMTimeGetSeconds(self.asset.duration);
    }
    
    //
    // Video output
    //
    if (videoTracks.count > 0) {
        self.videoOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:self.videoInputSettings];
        self.videoOutput.alwaysCopiesSampleData = NO;
        if (self.videoComposition) {
            self.videoOutput.videoComposition = self.videoComposition;
        } else {
            self.videoOutput.videoComposition = [self buildDefaultVideoComposition];
        }
        
        if ([self.reader canAddOutput:self.videoOutput]) {
            [self.reader addOutput:self.videoOutput];
        }

        //
        // Video input
        //
        self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoSettings];
        self.videoInput.expectsMediaDataInRealTime = NO;
        if ([self.writer canAddInput:self.videoInput]) {
            [self.writer addInput:self.videoInput];
        }
        
        NSDictionary *pixelBufferAttributes =
        @{
            (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
            (id)kCVPixelBufferWidthKey: @(self.videoOutput.videoComposition.renderSize.width),
            (id)kCVPixelBufferHeightKey: @(self.videoOutput.videoComposition.renderSize.height),
            @"IOSurfaceOpenGLESTextureCompatibility": @YES,
            @"IOSurfaceOpenGLESFBOCompatibility": @YES,
        };
        
        self.videoPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoInput sourcePixelBufferAttributes:pixelBufferAttributes];
    }

    //
    //Audio output
    //
    NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count > 0) {
      self.audioOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks audioSettings:nil];
      self.audioOutput.alwaysCopiesSampleData = NO;
      self.audioOutput.audioMix = self.audioMix;
      if ([self.reader canAddOutput:self.audioOutput]) {
          [self.reader addOutput:self.audioOutput];
      }
    } else {
        // Just in case this gets reused
        self.audioOutput = nil;
    }

    //
    // Audio input
    //
    if (self.audioOutput) {
        self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioSettings];
        self.audioInput.expectsMediaDataInRealTime = NO;
        if ([self.writer canAddInput:self.audioInput]) {
            [self.writer addInput:self.audioInput];
        }
    }
    
    [self.writer startWriting];
    [self.reader startReading];
    [self.writer startSessionAtSourceTime:self.timeRange.start];

    __block BOOL videoCompleted = NO;
    __block BOOL audioCompleted = NO;
    __weak typeof(self) wself = self;
    self.inputQueue = dispatch_queue_create("VideoEncoderInputQueue", DISPATCH_QUEUE_SERIAL);
    if (videoTracks.count > 0) {
        [self.videoInput requestMediaDataWhenReadyOnQueue:self.inputQueue usingBlock:^{
            if (![wself encodeReadySamplesFromOutput:wself.videoOutput toInput:wself.videoInput]) {
                @synchronized(wself) {
                    videoCompleted = YES;
                    if (audioCompleted) {
                        [wself finish];
                    }
                }
            }
        }];
    }
    else {
        videoCompleted = YES;
    }
    
    if (!self.audioOutput) {
        audioCompleted = YES;
    } else {
        [self.audioInput requestMediaDataWhenReadyOnQueue:self.inputQueue usingBlock:^{
             if (![wself encodeReadySamplesFromOutput:wself.audioOutput toInput:wself.audioInput]) {
                 @synchronized(wself) {
                     audioCompleted = YES;
                     if (videoCompleted) {
                         [wself finish];
                     }
                 }
             }
         }];
    }
}

- (BOOL)encodeReadySamplesFromOutput:(AVAssetReaderOutput *)output toInput:(AVAssetWriterInput *)input {
    while (input.isReadyForMoreMediaData) {
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
        if (sampleBuffer) {
            BOOL handled = NO;
            BOOL error = NO;

            if (self.reader.status != AVAssetReaderStatusReading || self.writer.status != AVAssetWriterStatusWriting) {
                handled = YES;
                error = YES;
            }
            
            if (!handled && self.videoOutput == output) {
                // update the video progress
                lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                lastSamplePresentationTime = CMTimeSubtract(lastSamplePresentationTime, self.timeRange.start);
                self.progress = duration == 0 ? 1 : CMTimeGetSeconds(lastSamplePresentationTime) / duration;
                
                if (self.progressBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.progressBlock(self.progress);
                    });
                }
                
                if ([self.delegate respondsToSelector:@selector(exportSession:renderFrame:withPresentationTime:toBuffer:)]) {
                    CVPixelBufferRef pixelBuffer  = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
                    CVPixelBufferRef renderBuffer = NULL;
                    CVPixelBufferPoolCreatePixelBuffer(NULL, self.videoPixelBufferAdaptor.pixelBufferPool, &renderBuffer);
                    [self.delegate exportSession:self renderFrame:pixelBuffer withPresentationTime:lastSamplePresentationTime toBuffer:renderBuffer];
                    
                    if (![self.videoPixelBufferAdaptor appendPixelBuffer:renderBuffer withPresentationTime:lastSamplePresentationTime]) {
                        error = YES;
                    }
                    CVPixelBufferRelease(renderBuffer);
                    handled = YES;
                }
            }
            
            if (!handled && ![input appendSampleBuffer:sampleBuffer]) {
                error = YES;
            }
            
            CFRelease(sampleBuffer);
            
            if (error) {
                return NO;
            }
        } else {
            [input markAsFinished];
            return NO;
        }
    }

    return YES;
}

- (AVMutableVideoComposition *)buildDefaultVideoComposition {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    AVAssetTrack *videoTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    // get the frame rate from videoSettings, if not set then try to get it from the video track,
    // if not set (mainly when asset is AVComposition) then use the default frame rate of 30
    float trackFrameRate = 0;
    if (self.videoSettings) {
        NSDictionary *videoCompressionProperties = [self.videoSettings objectForKey:AVVideoCompressionPropertiesKey];
        if (videoCompressionProperties) {
            NSNumber *frameRate = [videoCompressionProperties objectForKey:AVVideoAverageNonDroppableFrameRateKey];
            if (frameRate) {
                trackFrameRate = frameRate.floatValue;
            }
        }
    } else {
        trackFrameRate = [videoTrack nominalFrameRate];
    }

    if (trackFrameRate == 0) {
        trackFrameRate = 30;
    }

	videoComposition.frameDuration = CMTimeMake(1, trackFrameRate);
	CGSize targetSize = CGSizeMake([self.videoSettings[AVVideoWidthKey] floatValue], [self.videoSettings[AVVideoHeightKey] floatValue]);
	CGSize naturalSize = [videoTrack naturalSize];
	CGAffineTransform transform = videoTrack.preferredTransform;
	// Workaround radar 31928389, see https://github.com/rs/SDAVAssetExportSession/pull/70 for more info
	if (transform.ty == -560) {
		transform.ty = 0;
	}

	if (transform.tx == -560) {
		transform.tx = 0;
	}

	CGFloat videoAngleInDegree  = atan2(transform.b, transform.a) * 180 / M_PI;
	if (videoAngleInDegree == 90 || videoAngleInDegree == -90) {
		CGFloat width = naturalSize.width;
		naturalSize.width = naturalSize.height;
		naturalSize.height = width;
	}
	videoComposition.renderSize = naturalSize;
	// center inside
	{
		float ratio;
		float xratio = targetSize.width / naturalSize.width;
		float yratio = targetSize.height / naturalSize.height;
		ratio = MIN(xratio, yratio);

		float postWidth = naturalSize.width * ratio;
		float postHeight = naturalSize.height * ratio;
		float transx = (targetSize.width - postWidth) / 2;
		float transy = (targetSize.height - postHeight) / 2;

		CGAffineTransform matrix = CGAffineTransformMakeTranslation(transx / xratio, transy / yratio);
		matrix = CGAffineTransformScale(matrix, ratio / xratio, ratio / yratio);
		transform = CGAffineTransformConcat(transform, matrix);
	}

	// Make a "pass through video track" video composition.
	AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
	passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);

	AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    [passThroughLayer setTransform:transform atTime:kCMTimeZero];

	passThroughInstruction.layerInstructions = @[passThroughLayer];
	videoComposition.instructions = @[passThroughInstruction];

    return videoComposition;
}

- (void)finish {
    // Synchronized block to ensure we never cancel the writer before calling finishWritingWithCompletionHandler
    if (self.reader.status == AVAssetReaderStatusCancelled || self.writer.status == AVAssetWriterStatusCancelled) {
        return;
    }

    if (self.writer.status == AVAssetWriterStatusFailed) {
        [self complete];
    }
    else if (self.reader.status == AVAssetReaderStatusFailed) {
        [self.writer cancelWriting];
        [self complete];
    }
    else {
        [self.writer finishWritingWithCompletionHandler:^{
            [self complete];
        }];
    }
}

- (void)complete {
    if (self.writer.status == AVAssetWriterStatusFailed || self.writer.status == AVAssetWriterStatusCancelled) {
        [NSFileManager.defaultManager removeItemAtURL:self.outputURL error:nil];
    }

    [self excuteCompletionBlock];
}

- (void)excuteCompletionBlock {
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(self);
            self.completionBlock = nil;
        });
    }
}

- (NSError *)error {
    if (_error) {
        return _error;
    } else {
        return self.writer.error ? : self.reader.error;
    }
}

- (AVAssetExportSessionStatus)status {
    switch (self.writer.status) {
        default:
        case AVAssetWriterStatusUnknown:
            return AVAssetExportSessionStatusUnknown;
        case AVAssetWriterStatusWriting:
            return AVAssetExportSessionStatusExporting;
        case AVAssetWriterStatusFailed:
            return AVAssetExportSessionStatusFailed;
        case AVAssetWriterStatusCompleted:
            return AVAssetExportSessionStatusCompleted;
        case AVAssetWriterStatusCancelled:
            return AVAssetExportSessionStatusCancelled;
    }
}

- (void)cancelExport {
    if (self.inputQueue){
        dispatch_async(self.inputQueue, ^{
            [self.writer cancelWriting];
            [self.reader cancelReading];
            [self complete];
            [self reset];
        });
    }
}

- (void)reset {
    _error = nil;
    self.progress = 0;
    self.reader = nil;
    self.videoOutput = nil;
    self.audioOutput = nil;
    self.writer = nil;
    self.videoInput = nil;
    self.videoPixelBufferAdaptor = nil;
    self.audioInput = nil;
    self.inputQueue = nil;
    self.completionBlock = nil;
    self.progressBlock   = nil;
}

#pragma mark - tool
+ (CGSize)sizeFrom:(CGSize)originSize toSize:(CGSize)targetSize {
    if (originSize.width !=0 && originSize.height != 0 && targetSize.width !=0 && targetSize.height != 0) {
        CGFloat wScale;
        CGFloat hScale;
        CGFloat tScale;
        if (originSize.width == originSize.height || targetSize.width == targetSize.height) {
            wScale = originSize.width/targetSize.width;
            hScale = originSize.height/targetSize.height;
            tScale = MIN(wScale, hScale);
            //NSLog(@"正方形");
        }else{
            if((originSize.width > originSize.height && targetSize.width > targetSize.height)
               ||(originSize.width < originSize.height && targetSize.width < targetSize.height)){
                wScale = originSize.width/targetSize.width;
                hScale = originSize.height/targetSize.height;
                tScale = MAX(wScale, hScale);
                //NSLog(@"同方向");
            }else{
                wScale = originSize.height/targetSize.width;
                hScale = originSize.width/targetSize.height;
                tScale = MAX(wScale, hScale);
                //NSLog(@"反方向");
            }
        }
        return CGSizeMake((int)(originSize.width/tScale), (int)(originSize.height/tScale));
    }else{
        return originSize;
    }
}

+ (CGSize)sizeVideoUrl:(NSURL *)videoUrl {
    if (!videoUrl) {
        return CGSizeZero;
    }
    AVAsset *asset  = [AVAsset assetWithURL:videoUrl];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0) {
        AVAssetTrack *videoTrack = tracks[0];
        CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
        videoSize = CGSizeMake(fabs(videoSize.width), fabs(videoSize.height));
        return videoSize;
    }else{
        return CGSizeZero;
    }
}

+ (CGFloat)durationVideoUrl:(NSURL *)videoUrl {
    if (!videoUrl) {
        return 0;
    }
    AVURLAsset * asset = [AVURLAsset assetWithURL:videoUrl];
    CMTime time = [asset duration];
    CGFloat seconds = ceil(time.value/time.timescale);
    return seconds;
}

+ (NSInteger)frameRateVideoUrl:(NSURL *)videoUrl {
    if (!videoUrl) {
        return 0;
    }
    
    AVAsset *asset  = [AVAsset assetWithURL:videoUrl];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0) {
        AVAssetTrack *videoTrack = tracks[0];
        
        NSInteger frameRate = [videoTrack nominalFrameRate];
        //float bps = [videoTrack estimatedDataRate];
        //NSLog(@"Frame rate == %f",frameRate);
        //NSLog(@"bps rate == %f",bps);
        
        return frameRate;
    }else{
        return 0;
    }
}

+ (CGFloat)bitRateVideoUrl:(NSURL *)videoUrl {
    if (!videoUrl) {
        return 0;
    }
    
    AVAsset *asset  = [AVAsset assetWithURL:videoUrl];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0) {
        AVAssetTrack *videoTrack = tracks[0];
        float bps = [videoTrack estimatedDataRate];
        return bps;
    }else{
        return 0;
    }
}

+ (NSDictionary *)dicVideoSettingsSize:(CGSize)videoSize
                    size_BitRate_scale:(CGFloat)size_BitRate_scale
{
    // 判断 size 和 bitRate的倍数
    if (size_BitRate_scale <= 0) {
        size_BitRate_scale = 2;
    }
    CGFloat bitRate = videoSize.width * videoSize.height * size_BitRate_scale;
    
    return [self dicVideoSettingsSize:videoSize bitRate:bitRate];
}

+ (NSDictionary *)dicVideoSettingsSize:(CGSize)videoSize
                               bitRate:(CGFloat)bitRate
{
    if (videoSize.width <= 0 || videoSize.height <= 0) {
        return nil;
    }
    
    if (bitRate <= 0) {
        bitRate = 900 * 1000;
    }
    
    NSDictionary * dic = @{
        AVVideoCodecKey : [self codeKey], //之前为 AVVideoCodecH264,
        AVVideoWidthKey : @(videoSize.width),
        AVVideoHeightKey: @(videoSize.height),
        AVVideoCompressionPropertiesKey:
            @{
                AVVideoAverageBitRateKey : @(bitRate),
                
                //AVVideoProfileLevelKey   : AVVideoProfileLevelH264High40,// 这个值对AVVideoWidthKey和AVVideoHeightKey要求太苛刻.
                AVVideoProfileLevelKey   : AVVideoProfileLevelH264HighAutoLevel,
                
                //AVVideoMaxKeyFrameIntervalKey: @(15), // 目前发现设置这个参数不起作用
            },
    };
    return dic;
}

+ (NSString *)codeKey {
    NSString * codeKey;
#if TARGET_OS_OSX//mac
    codeKey = AVVideoCodecTypeH264;
#elif TARGET_OS_IOS
    //TARGET_OS_IOS// ioc
    if (@available(iOS 11, *)) {
        codeKey = AVVideoCodecTypeH264;
    } else {
        codeKey = AVVideoCodecH264;
    }
#elif TARGET_OS_TV
    if (@available(tvOS 11, *)) {
        codeKey = AVVideoCodecTypeH264;
    } else {
        codeKey = AVVideoCodecH264;
    }
    
#endif
    return codeKey;
}

+ (NSDictionary *)dicAudioSettings {
    NSDictionary * dic = @{
        AVFormatIDKey        : @(kAudioFormatMPEG4AAC),
        AVNumberOfChannelsKey: @2,
        AVSampleRateKey      : @44100,
        AVEncoderBitRateKey  : @128000,
    };
    
    return dic;
}

//+ (CGSize)videoSizeFromUrl_old:(NSString *)url {
//    if (!url) {
//        return CGSizeZero;
//    }
//    if ([url hasPrefix:@"file://"]) {
//        url = [url substringFromIndex:7];
//    }
//    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:url]];
//    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
//    if([tracks count] > 0) {
//        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
//        CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
//        //NSLog(@"=====video size  width:%f===height:%f",videoTrack.naturalSize.width,videoTrack.naturalSize.height);
//
//        BOOL upDown = YES;
//        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
//            // Portrait
//            upDown = YES;
//        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
//            // PortraitUpsideDown
//            upDown = YES;
//        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
//            // LandscapeRight
//            upDown = NO;
//        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
//            // LandscapeLeft
//            upDown = NO;
//        }
//        if (!upDown) {
//            return CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
//        }else{
//            return CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
//        }
//
//    }else{
//        return CGSizeZero;
//    }
//}

@end
