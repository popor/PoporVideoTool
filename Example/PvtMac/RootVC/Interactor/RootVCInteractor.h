//
//  RootVCInteractor.h
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "VideoEntity.h"

NS_ASSUME_NONNULL_BEGIN

// 处理Entity事件
@interface RootVCInteractor : NSObject

@property (nonatomic, strong) NSMutableArray * infoArray;
@property (nonatomic, copy  ) NSString       * outputFolderPath;

//@property (nonatomic, copy  ) NSArray        * 

- (void)save__outputFolderPath:(NSString *)__outputFolderPath;
- (NSString *)get__outputFolderPath;

@end

NS_ASSUME_NONNULL_END
