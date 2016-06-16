//
//  LaunchView.h
//  Tiaooo
//
//  Created by ClaudeLi on 16/6/14.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

// 启动屏类型
typedef NS_ENUM(NSInteger, StartupScreenType) {
    StartupScreenTypeNone,
    StartupScreenTypeScrollView,
    StartupScreenTypeVideo,
};

@interface LaunchView : UIView

+ (LaunchView *)launchView;

- (instancetype)initWithType:(StartupScreenType)type;

- (void)setStartupType:(StartupScreenType)type;

- (void)show;

- (void)hide;

@end
