//
//  VideoEntity.h
//  PvtMac
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoEntity : NSObject
@property (nonatomic, copy  ) NSString * path;
@property (nonatomic, copy  ) NSString * fileName;
@property (nonatomic        ) CGSize     resolution;

@property (nonatomic        ) NSInteger  size;
@property (nonatomic, copy  ) NSString * sizeString;

@property (nonatomic        ) CGFloat    duration;
@property (nonatomic, copy  ) NSString * durationString;

@property (nonatomic        ) NSInteger  frameRate;
@property (nonatomic        ) CGFloat    bitRate;

@end

NS_ASSUME_NONNULL_END
