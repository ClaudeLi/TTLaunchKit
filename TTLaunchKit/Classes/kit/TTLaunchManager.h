//
//  TTLaunchManager.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/9/18.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const TTLaunchAdsKey;
UIKIT_EXTERN NSInteger const TTMaxAdsCount;
UIKIT_EXTERN NSString *TTLaunchAdsPath(void);

@class TTLaunchAdItem;
@interface TTLaunchManager : NSObject

+ (void)requestLaunchAdsWithURL:(NSString *)url
                     parameters:(id)parameters
                        success:(TTLaunchAdItem * (^)(id response))success;

+ (TTLaunchAdItem *)getLastLaunchModel;

+ (NSString *)pathWithModel:(TTLaunchAdItem *)model;

// 是否存在
+ (BOOL)hasAd:(TTLaunchAdItem *)model;

// 是否显示
+ (BOOL)shouldShow:(TTLaunchAdItem *)model;

// 删除
+ (void)removeOldAds;

@end
