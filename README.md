# PoporVideoTool

[![CI Status](https://img.shields.io/travis/popor/PoporVideoTool.svg?style=flat)](https://travis-ci.org/popor/PoporVideoTool)
[![Version](https://img.shields.io/cocoapods/v/PoporVideoTool.svg?style=flat)](https://cocoapods.org/pods/PoporVideoTool)
[![License](https://img.shields.io/cocoapods/l/PoporVideoTool.svg?style=flat)](https://cocoapods.org/pods/PoporVideoTool)
[![Platform](https://img.shields.io/cocoapods/p/PoporVideoTool.svg?style=flat)](https://cocoapods.org/pods/PoporVideoTool)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PoporVideoTool is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PoporVideoTool'
```

```objc
#import<PoporVideoTool/PoporVideoTool.h>

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
```
## Author

popor, 908891024@qq.com

## License

PoporVideoTool is available under the MIT license. See the LICENSE file for more info.
