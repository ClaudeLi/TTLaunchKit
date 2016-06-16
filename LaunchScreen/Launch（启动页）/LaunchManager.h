//
//  LaunchManager.h
//  tiaooo
//
//  Created by ClaudeLi on 16/5/21.
//  Copyright © 2016年 dali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
// 网络缓存文件夹名
#define NetworkCache        @"NetworkCache"

#define FILEManager     [NSFileManager defaultManager]

#define LaunchDefaults  [NSUserDefaults standardUserDefaults]

#define LaunchImagePath [NSString stringWithFormat:@"%@/Documents/launchImage.jpg",NSHomeDirectory()]

@interface LaunchManager : NSObject

+ (BOOL)isFileExists;

+ (void)downloadLaunchImageWithUrl:(NSString *)url tapUrl:(NSString *)tapUrl;

+ (void)launchRequestWithUrl:(NSString *)urlString parameters:(id)parameters;

@end

@interface NSString (Network)

/**
 *  生成AbsoluteURL（仅对一级字典结构起作用）
 *
 *  @param url    请求地址
 *  @param params 拼接参数
 *
 *  @return urlString
 */
+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params;

/**
 *  MD5加密，用于缓存文件名
 *
 *  @param string 要加密的字符串
 *
 *  @return 加密后的字符串
 */
+ (NSString *)networkingUrlString_md5:(NSString *)string;

/**
 *  网络缓存地址
 *
 *  @return Caches路径
 */
+ (NSString *)cachesPathString;

@end
