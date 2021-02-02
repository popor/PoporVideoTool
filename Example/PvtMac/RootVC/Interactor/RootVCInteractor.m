//
//  RootVCInteractor.m
//  PoporVideoTool
//
//  Created by popor on 2021/1/30.
//  Copyright © 2021 popor. All rights reserved.

#import "RootVCInteractor.h"

@interface RootVCInteractor ()

@end

@implementation RootVCInteractor

- (id)init {
    if (self = [super init]) {
        self.infoArray = [NSMutableArray new];
        self.outputFolderPath = [self get__outputFolderPath];
    }
    return self;
}

#pragma mark - VCDataSource
- (void)save__outputFolderPath:(NSString *)__outputFolderPath {
    [[NSUserDefaults standardUserDefaults] setObject:__outputFolderPath forKey:@"__outputFolderPath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)get__outputFolderPath {
    NSString * info = [[NSUserDefaults standardUserDefaults] objectForKey:@"__outputFolderPath"];
    return info;
}


@end

