//
//  TTLaunchManager.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/9/18.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTLaunchManager.h"
#import "TTLaunchAdItem.h"
#import <CLTools/CLTools.h>
#import <YYKit/YYKit.h>
#import <TTNetworking/TTNetworking.h>
#import "TTLaunchView.h"

NSString *const TTLaunchAdsKey = @"com.launch.ads";
NSInteger const TTMaxAdsCount  = 6;

NSString *TTLaunchAdsPath(void){
    static NSString *adsPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adsPath = [NSLibraryDirPath() stringByAppendingPathComponent:TTLaunchAdsKey];
        if (![[NSFileManager defaultManager] fileExistsAtPath:adsPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:adsPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return adsPath;
}

@implementation TTLaunchManager

+ (NSString *)pathWithModel:(TTLaunchAdItem *)model{
    return [TTLaunchAdsPath() stringByAppendingPathComponent:model.fileName];
}

+ (TTLaunchAdItem *)getLastLaunchModel{
    NSArray *ads = [[NSUserDefaults standardUserDefaults] objectForKey:TTLaunchAdsKey];
    if (ads.count) {
         return [TTLaunchAdItem modelWithJSON:ads.lastObject];
    }
    return nil;
}

+ (BOOL)hasAd:(TTLaunchAdItem *)model{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self pathWithModel:model]];
}

+ (BOOL)shouldShow:(TTLaunchAdItem *)model{
    if ([self hasAd:model]) {
        NSError *error;
        NSDictionary<NSFileAttributeKey, id> *file = [[NSFileManager defaultManager] attributesOfItemAtPath:[self pathWithModel:model] error:&error];
        if (error) {
            return NO;
        }
        unsigned long long size = file.fileSize;
        if (size > 0 && size < 1024 * 1024 * 5) {
            return YES;
        }
    }
    return NO;
}

+ (unsigned long long)fileSizeWithPath:(NSString *)path{
    // 总大小
    unsigned long long size = 0;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL exist = [manager fileExistsAtPath:path isDirectory:&isDir];
    
    // 判断路径是否存在
    if (!exist) return size;
    if (isDir) { // 是文件夹
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [path stringByAppendingPathComponent:subPath];
            size += [manager attributesOfItemAtPath:fullPath error:nil].fileSize;
            
        }
    }else{ // 是文件
        size += [manager attributesOfItemAtPath:path error:nil].fileSize;
    }
    return size;
}

+ (void)requestLaunchAdsWithURL:(NSString *)url parameters:(id)parameters success:(TTLaunchAdItem * (^)(id response))success{
    [TTNetworkManager POST:url parameters:parameters success:^(id responseObject) {
        TTLaunchShared.failedLoad = NO;
        if (success) {
            TTLaunchAdItem *item = success(responseObject);
            if ([NSString isNilOrEmptyString:item.id] ||
                [item.id isEqual:@"0"] ||
                (item.style_type!=1 && item.style_type!=2)) {
                // 0/nil/style_type不是图片/视频时 广告不存在/不处理
                // 删除广告
                [self removeAllAds];
            }else{
                // 判断广告池中是否包含此广告
                NSArray *ads = [[NSUserDefaults standardUserDefaults] objectForKey:TTLaunchAdsKey];
                for (int i = 0; i < ads.count; i++) {
                    TTLaunchAdItem *m = [TTLaunchAdItem modelWithJSON:ads[i]];
                    if ([m.id isEqual:item.id]) {
                        NSString *mediaPath = [self pathWithModel:m];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:mediaPath]) {
                            if ((ads.count-1) != i) {
                                NSMutableArray *mutableAds = ads.mutableCopy;
                                [mutableAds exchangeObjectAtIndex:ads.count-1 withObjectAtIndex:i];
                                [[NSUserDefaults standardUserDefaults] setObject:mutableAds forKey:TTLaunchAdsKey];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                TTLaunchShared.hasNewAds = YES;
                            }
                            return;
                        }else{
                            NSMutableArray *array = ads.mutableCopy;
                            [array removeObject:m];
                            [self downloadScreenImageWithModel:item ads:array];
                            return;
                        }
                    }
                }
                // id不同 下载本次广告
                [self downloadScreenImageWithModel:item ads:ads];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self loadFailedOrNoAd];
    }];
}

+ (void)downloadScreenImageWithModel:(TTLaunchAdItem *)model ads:(NSArray *)ads{
    if (model.style_type == 2 &&
        [TTNetworkManager currentNetworkStatus] != 2) {
        NSLog(@"video ad must WI-FI");
        [self loadFailedOrNoAd];
        return;
    }
    if ([model.style_value containsString:@"://"]) {
        [TTNetworkManager downloadWithURLString:model.style_value outputPath:^NSString *(NSURLResponse *response) {
            return [self pathWithModel:model];
        }  progress:nil completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            if (resp.statusCode == 404 || error) {
                [self loadFailedOrNoAd];
            }else{
                NSLog(@"ad download finished");
                NSMutableArray *mutableAds = [NSMutableArray arrayWithArray:ads];
                if (mutableAds.count >= TTMaxAdsCount) {
                    TTLaunchAdItem *m = [TTLaunchAdItem modelWithJSON:mutableAds.firstObject];
                    unlink([[self pathWithModel:m] UTF8String]);
                    [mutableAds removeFirstObject];
                }
                [mutableAds addObject:model.modelToJSONString];
                [[NSUserDefaults standardUserDefaults] setObject:mutableAds forKey:TTLaunchAdsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                TTLaunchShared.hasNewAds = YES;
            }
        }];
    }else{
        [self loadFailedOrNoAd];
    }
}

+ (void)loadFailedOrNoAd{
    TTLaunchShared.failedLoad = YES;
}

+ (void)removeAllAds{
    NSArray *ads = [[NSUserDefaults standardUserDefaults] objectForKey:TTLaunchAdsKey];
    for (NSData *data in ads) {
        TTLaunchAdItem *m = [TTLaunchAdItem modelWithJSON:data];
        unlink([[self pathWithModel:m] UTF8String]);
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TTLaunchAdsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeOldAds{
    NSArray *ads = [[NSUserDefaults standardUserDefaults] objectForKey:TTLaunchAdsKey];
    if (ads.count) {
        for (int i=0; i < ads.count-1; i++) {
            TTLaunchAdItem *m = [TTLaunchAdItem modelWithJSON:ads[i]];
            unlink([[self pathWithModel:m] UTF8String]);
        }
        [[NSUserDefaults standardUserDefaults] setObject:@[ads.lastObject] forKey:TTLaunchAdsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
