//
//  TTAppDelegate.m
//  TTLaunchKit
//
//  Created by claudeli@yeah.net on 10/18/2018.
//  Copyright (c) 2018 claudeli@yeah.net. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TTViewController.h"
#import <TTLaunchKit/TTLaunchKit.h>
#import <TTNetworking/TTNetworking.h>
#import <YYKit/YYKit.h>
#import "TTDataModel.h"
#import <CLTools/CLTools.h>

static NSString *AdsURL = @"https://api.tiaooo.com/ads/screen_storage";

@implementation TTAppDelegate{
    NSTimeInterval _enterBackgroundTime;
}


- (UIWindow *)window{
    if (!_window) {
        _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        [_window makeKeyAndVisible];
    }
    return _window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    TTVideoLaunchController *launchController = [[TTVideoLaunchController alloc]init];
    launchController.moviePath = [[NSBundle mainBundle] pathForResource:@"tt_launch_start" ofType:@"mp4"];
    launchController.playFinished = ^{
        [self registRootViewController];
    };
    self.window.rootViewController = launchController;
    return YES;
}

- (void)registRootViewController{
    self.window.rootViewController = [[TTViewController alloc] init];
    [self registAds];
    // 开启网络检测
    [TTNetworkManager checkNetworkStatus:^(NSInteger status) {
        if (status == 2) {
            if (TTLaunchShared.failedLoad) {
                // 请求广告
                [self requsetAds];
            }
        }
    }];
}

// 注册广告
- (void)registAds{
    TTLaunchAdItem *item = [TTLaunchManager getLastLaunchModel];
    if (item && [TTLaunchManager hasAd:item]) {
        if ((item.style_type == 1 && [TTLaunchManager shouldShow:item])
            || item.style_type == 2) {
            TTLaunchShared.hasAtStartup = YES;
            TTLaunchShared.model = item;
            [TTLaunchShared setDidHideViewBlock:^{
                // 请求广告
                [self requsetAds];
            }];
            [TTLaunchShared showWithMode:TTLaunchViewShowModeLaunchScreen];
        }
    }
    
    // 启动时 请求广告
    // 为避免影响启动时间，可以放在第一个页面加载完成
    if (!TTLaunchShared.hasAtStartup) {
        [self requsetAds];
    }
}

- (void)requsetAds{
    [TTLaunchManager requestLaunchAdsWithURL:AdsURL parameters:nil success:^TTLaunchAdItem *(id response) {
        TTDataModel *data = [TTDataModel modelWithJSON:response];
        return data.data;
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _enterBackgroundTime = [[NSDate date] timeIntervalSince1970];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 刷新广告
    [self reloadLaunchView];
}

static NSTimeInterval backgroundReloadADTime = 4.0;

- (void)reloadLaunchView{
    if (!TTLaunchShared.hasNewAds) {
        return;
    }
    // 当前是否竖屏
    if (KScreenHeight < KScreenWidth) {
        return;
    }
    if (!_enterBackgroundTime) {
        return;
    }
    if (!TTLaunchShared.hidden) {
        return;
    }
    if (([[NSDate date] timeIntervalSince1970] - _enterBackgroundTime) > backgroundReloadADTime) {
        TTLaunchAdItem *m = [TTLaunchManager getLastLaunchModel];
        if (m && [TTLaunchManager hasAd:m]) {
            TTLaunchShared.hasNewAds = NO;
            TTLaunchShared.model = [TTLaunchManager getLastLaunchModel];
            [TTLaunchShared showWithMode:TTLaunchViewShowModeEnterForeground];
        }
        return;
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
