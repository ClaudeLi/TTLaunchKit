//
//  TTLaunchView.h
//  Tiaooo
//
//  Created by ClaudeLi on 2018/3/21.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString * const TTNotificationClickLaunchAds;
FOUNDATION_EXTERN NSString * const TTNotificationHideLaunchAds;

typedef NS_ENUM(NSInteger, TTLaunchViewShowMode) {
    TTLaunchViewShowModeEnterForeground,    // 进入前台
    TTLaunchViewShowModeLateralSpreads,     // 侧滑
    TTLaunchViewShowModeLaunchScreen,       // 启动屏
};

#define TTLaunchShared    [TTLaunchView defaultShared]

@class TTLaunchAdItem;
@interface TTLaunchView : UIImageView

+ (TTLaunchView *)defaultShared;

@property (nonatomic, strong) TTLaunchAdItem        *model;
@property (nonatomic, strong) NSString              *closeTitle;
@property (nonatomic, assign) TTLaunchViewShowMode  showMode;

/**
 启动时是否有广告
 */
@property (nonatomic, assign) BOOL     hasAtStartup;

/**
 是否有新广告
 */
@property (nonatomic, assign) BOOL     hasNewAds;

/**
 是否应该请求广告
 */
@property (nonatomic, assign) BOOL     failedLoad;

/**
 当前是否正在显示
 */
@property (nonatomic, assign) BOOL     showing;

@property (nonatomic, copy) void(^didHideViewBlock)(void);
@property (nonatomic, copy) void(^didClickAdsBlock)(TTLaunchAdItem *item);

- (void)showWithMode:(TTLaunchViewShowMode)mode;

@end
