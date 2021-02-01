//
//  PoporVideoTool.h
//
// This file is part of the SDAVAssetExportSession package.
//
// Created by Olivier Poitrey <rs@dailymotion.com> on 13/03/13.
// Copyright 2013 Olivier Poitrey. All rights servered.
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//
//
// ................................................................................
// Dailymotion是一家视频分享网站，用户可以在该网站上传、分享和观看视频，其总部位于法国巴黎的十八区。
// 它的域名在YouTube之后一个月注册。Dailymotion最广为人知的特点之一就是其提供支持开放格式ogg的视频。
// 和同类型的其他Flash视频分享网站相比，Dailymotion以其短片具有高清晰画质而闻名。
// 据Comscore的资料显示，Dailymotion是仅次于YouTube的全球第二大视频网站。
// 截至2010年10月，该网站获得每月超过9300万的访问者，alexa排名第32。
// 摘自百度
// ................................................................................
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 改编自: SDAVAssetExportSession, 系属于法国Dailymotion公司.
 简书: https://www.jianshu.com/p/4f69c22c6dce
 github: https://github.com/rs/SDAVAssetExportSession
 
 */

NS_ASSUME_NONNULL_BEGIN

@protocol PoporVideoCompressDelegate;
@class PoporVideoTool;

typedef void(^PoporVideoBlock_PTool)  (PoporVideoTool * _Nonnull poporVideoTool);
typedef void(^PoporVideoBlock_PFloat) (CGFloat progress);

/**
 * An `SDAVAssetExportSession` object transcodes the contents of an AVAsset source object to create an output
 * of the form described by specified video and audio settings. It implements most of the API of Apple provided
 * `AVAssetExportSession` but with the capability to provide you own video and audio settings instead of the
 * limited set of Apple provided presets.
 *
 * After you have initialized an export session with the asset that contains the source media, video and audio
 * settings, and the output file type (outputFileType), you can start the export running by invoking 
 * `exportAsynchronouslyWithCompletionHandler:`. Because the export is performed asynchronously, this method
 * returns immediately — you can observe progress to check on the progress.
 *
 * The completion handler you supply to `exportAsynchronouslyWithCompletionHandler:` is called whether the export
 * fails, completes, or is cancelled. Upon completion, the status property indicates whether the export has
 * completed successfully. If it has failed, the value of the error property supplies additional information
 * about the reason for the failure.
 */

@interface PoporVideoTool : NSObject

@property (nonatomic, weak  ) id<PoporVideoCompressDelegate> _Nullable delegate;

@property (nonatomic, copy  ) PoporVideoBlock_PTool  _Nullable completionBlock;
@property (nonatomic, copy  ) PoporVideoBlock_PFloat _Nullable progressBlock;

/**
 * The asset with which the export session was initialized.
 */
@property (nonatomic, strong, readonly) AVAsset *asset;

/**
 * Indicates whether video composition is enabled for export, and supplies the instructions for video composition.
 *
 * You can observe this property using key-value observing.
 */
@property (nonatomic, copy) AVVideoComposition *videoComposition;

/**
 * Indicates whether non-default audio mixing is enabled for export, and supplies the parameters for audio mixing.
 */
@property (nonatomic, copy) AVAudioMix *audioMix;

/**
 * The type of file to be written by the session.
 *
 * The value is a UTI string corresponding to the file type to use when writing the asset.
 * For a list of constants specifying UTIs for standard file types, see `AV Foundation Constants Reference`.
 *
 * You can observe this property using key-value observing.
 */
@property (nonatomic, copy) NSString *outputFileType;

/**
 * The URL of the export session’s output.
 *
 * You can observe this property using key-value observing.
 */
@property (nonatomic, copy) NSURL *outputURL;

/**
 * The settings used for input video track.
 *
 * The dictionary’s keys are from <CoreVideo/CVPixelBuffer.h>.
 */
@property (nonatomic, copy) NSDictionary *videoInputSettings;

/**
 * The settings used for encoding the video track.
 *
 * A value of nil specifies that appended output should not be re-encoded.
 * The dictionary’s keys are from <AVFoundation/AVVideoSettings.h>.
 */
@property (nonatomic, copy) NSDictionary *videoSettings;

/**
 * The settings used for encoding the audio track.
 *
 * A value of nil specifies that appended output should not be re-encoded.
 * The dictionary’s keys are from <CoreVideo/CVPixelBuffer.h>.
 */
@property (nonatomic, copy) NSDictionary *audioSettings;

/**
 * The time range to be exported from the source.
 *
 * The default time range of an export session is `kCMTimeZero` to `kCMTimePositiveInfinity`,
 * meaning that (modulo a possible limit on file length) the full duration of the asset will be exported.
 *
 * You can observe this property using key-value observing.
 *
 */
@property (nonatomic, assign) CMTimeRange timeRange;

/**
 * Indicates whether the movie should be optimized for network use.
 *
 * You can observe this property using key-value observing.
 */
@property (nonatomic, assign) BOOL shouldOptimizeForNetworkUse;

/**
 * The metadata to be written to the output file by the export session.
 */
@property (nonatomic, copy) NSArray *metadata;

/**
 * Describes the error that occurred if the export status is `AVAssetExportSessionStatusFailed`
 * or `AVAssetExportSessionStatusCancelled`.
 *
 * If there is no error to report, the value of this property is nil.
 */
@property (nonatomic, strong, readonly) NSError *error;

/**
 * The progress of the export on a scale from 0 to 1.
 *
 *
 * A value of 0 means the export has not yet begun, 1 means the export is complete.
 *
 * Unlike Apple provided `AVAssetExportSession`, this property can be observed using key-value observing.
 */
@property (nonatomic, assign, readonly) float progress;

/**
 * The status of the export session.
 *
 * For possible values, see “AVAssetExportSessionStatus.”
 *
 * You can observe this property using key-value observing. (TODO)
 */
@property (nonatomic, assign, readonly) AVAssetExportSessionStatus status;

/**
 * Returns an asset export session configured with a specified asset.
 *
 * @param asset The asset you want to export
 * @return An asset export session initialized to export `asset`.
 */
+ (id)exportSessionWithAsset:(AVAsset *)asset;

/**
 * Initializes an asset export session with a specified asset.
 *
 * @param asset The asset you want to export
 * @return An asset export session initialized to export `asset`.
 */
- (id)initWithAsset:(AVAsset *)asset;


#pragma mark - 压缩函数
/**
 * Starts the asynchronous execution of an export session.
 *
 * This method starts an asynchronous export operation and returns immediately. status signals the terminal
 * state of the export session, and if a failure occurs, error describes the problem.
 *
 * If internal preparation for export fails, handler is invoked synchronously. The handler may also be called
 * asynchronously, after the method returns, in the following cases:
 *
 * 1. If a failure occurs during the export, including failures of loading, re-encoding, or writing media data to the output.
 * 2. If cancelExport is invoked.
 * 3. After the export session succeeds, having completely written its output to the outputURL.
 *
 * @param completionBlock A block that is invoked when writing is complete or in the event of writing failure.
 *
 */
- (void)compressCompletion:(PoporVideoBlock_PTool _Nonnull)completionBlock;

- (void)compressCompletion:(PoporVideoBlock_PTool _Nonnull)completionBlock progress:(PoporVideoBlock_PFloat _Nullable)progressBlock;

/**
 * Cancels the execution of an export session.
 *
 * You can invoke this method when the export is running.
 */
- (void)cancelExport;

#pragma mark - tool
+ (CGSize)sizeFrom:(CGSize)originSize toSize:(CGSize)targetSize;
+ (CGSize)sizeVideoUrl:(NSURL *)videoUrl;

+ (CGFloat)durationVideoUrl:(NSURL *)videoUrl;

+ (NSInteger)frameRateVideoUrl:(NSURL *)videoUrl;

// 压缩时候, 应该判断一下, 防止变大.
+ (CGFloat)bitRateVideoUrl:(NSURL *)videoUrl;

/**
 *  @param videoSize  压缩后视频宽度
 *  @param size_BitRate_scale 屏幕和bitRate的比例, 微信视频压缩大约是2.
 */
+ (NSDictionary *)dicVideoSettingsSize:(CGSize)videoSize
                    size_BitRate_scale:(CGFloat)size_BitRate_scale;

/**
 *  @param videoSize  压缩后视频宽度
 *  @param bitRate    比特率
 */
+ (NSDictionary *)dicVideoSettingsSize:(CGSize)videoSize
                               bitRate:(CGFloat)bitRate;

+ (NSDictionary *)dicAudioSettings;

@end


@protocol PoporVideoCompressDelegate <NSObject>

- (void)exportSession:(PoporVideoTool *)exportSession renderFrame:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime toBuffer:(CVPixelBufferRef)renderBuffer;

@end

NS_ASSUME_NONNULL_END
