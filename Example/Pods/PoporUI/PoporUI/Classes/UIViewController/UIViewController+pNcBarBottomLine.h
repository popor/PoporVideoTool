//
//  UIViewController+pNcBarBottomLine.h
//  hywj
//
//  Created by popor on 2020/6/11.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - NC 部分
@interface UINavigationController (pNcBarBottomLine)
@property (strong, nonatomic) UIImage * ncbarShadowImageDefault;
//@property (strong, nonatomic) UIImage * ncbarBgImageDefault;

@property (strong, nonatomic) UIImage * ncbarShadowImageCustom;
//@property (strong, nonatomic) UIImage * ncbarBgImageCustom;

- (void)getSystemDefaultImage;

@end

#pragma mark - VC 部分
@interface UIViewController (pNcBarBottomLine)

// 隐藏ncBar下面的一条线 - (void)viewWillAppear:(BOOL)animated
- (void)hiddenSystemBottomLine;

// 恢复ncBar下面的一条线 - (void)viewWillDisappear:(BOOL)animated
- (void)showSystemBottomLine;

@end

NS_ASSUME_NONNULL_END
