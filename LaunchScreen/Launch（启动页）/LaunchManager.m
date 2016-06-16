//
//  LaunchManager.m
//  tiaooo
//
//  Created by ClaudeLi on 16/5/21.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "LaunchManager.h"

// 缓存路径
static inline NSString *cachePath() {
    return [NSString cachesPathString];
}
@implementation LaunchManager

+(BOOL)isFileExists{
    return [FILEManager fileExistsAtPath:LaunchImagePath];
}

+ (void)launchRequestWithUrl:(NSString *)urlString parameters:(id)parameters{
    id cacheData = [self cahceResponseWithURL:urlString parameters:parameters];
    id dicEd;
    if (cacheData) {
        // 如果本地数据存在，读取本地数据，解析并返回给首页
        dicEd = [NSJSONSerialization JSONObjectWithData:cacheData options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // GET请求
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self cacheResponseObject:responseObject urlString:urlString parameters:parameters];
        id dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
        
        if ([dict[@"data"][@"id"] isEqual:@0]) {
            // 删除 广告
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:Launch_Key];
            unlink([LaunchImagePath UTF8String]);
        }else{
            if ([dict[@"data"][@"id"] isEqual:dicEd[@"data"][@"id"]]) {
                if (![LaunchManager isFileExists]) {
                    // 下载图片
                    [LaunchManager downloadLaunchImageWithUrl:dict[@"data"][@"picture"] tapUrl:dict[@"data"][@"url"]];
                }
            }else{
                // 下载图片
                [LaunchManager downloadLaunchImageWithUrl:dict[@"data"][@"picture"] tapUrl:dict[@"data"][@"url"]];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}


+ (void)downloadLaunchImageWithUrl:(NSString *)url tapUrl:(NSString *)tapUrl{
    //设置下载临时路径
    NSString *temPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"launchImage.jpg"];
    unlink([temPath UTF8String]);
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //2.确定请求的URL地址
    NSURL *URL = [NSURL URLWithString:url];
    //3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    //下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //打印下下载进度
//        NSLog(@"%lf",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //下载地址
        return [NSURL fileURLWithPath:temPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        // 假如错误为404，删除目录中的图片
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        NSLog(@"%ld", (long)resp.statusCode);
        if (resp.statusCode == 404) {
            [LaunchDefaults removeObjectForKey:Launch_Key];
            unlink([LaunchImagePath UTF8String]);
        }else{
            if (filePath) {
                unlink([LaunchImagePath UTF8String]);
                [LaunchDefaults setObject:tapUrl forKey:Launch_Key];
                [FILEManager moveItemAtPath:temPath toPath:LaunchImagePath error:nil];
            }
        }
    }];
    //开始启动任务
    [task resume];
}


#pragma mark -- 缓存处理 --
/**
 *  缓存文件夹下某地址的文件名，及UserDefaulets中的key值
 *
 *  @param urlString 请求地址
 *  @param params    请求参数
 *
 *  @return 返回一个MD5加密后的字符串
 */
+ (NSString *)cacheKey:(NSString *)urlString params:(id)params{
    NSString *absoluteURL = [NSString generateGETAbsoluteURL:urlString params:params];
    NSString *key = [NSString networkingUrlString_md5:absoluteURL];
    return key;
}

/**
 *  读取缓存
 *
 *  @param url    请求地址
 *  @param params 拼接的参数
 *
 *  @return 数据data
 */
+ (id)cahceResponseWithURL:(NSString *)url parameters:(id)params {
    id cacheData = nil;
    if (url) {
        // 读取本地缓存
        NSString *key = [self cacheKey:url params:params];
        NSString *path = [cachePath() stringByAppendingPathComponent:key];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        if (data) {
            cacheData = data;
        }
    }
    return cacheData;
}
/**
 *  添加缓存
 *
 *  @param responseObject 请求成功数据
 *  @param urlString      请求地址
 *  @param params         拼接的参数
 */
+ (void)cacheResponseObject:(id)responseObject urlString:(NSString *)urlString parameters:(id)params {
    NSString *key = [self cacheKey:urlString params:params];
    NSString *path = [cachePath() stringByAppendingPathComponent:key];
    [self deleteFileWithPath:path];
    BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:responseObject attributes:nil];
    if (isOk) {
        NSLog(@"cache file success: %@\n", path);
    } else {
        NSLog(@"cache file error: %@\n", path);
    }
}

/**
 *  判断文件是否已经存在，若存在删除
 *
 *  @param path 文件路径
 */
+ (void)deleteFileWithPath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted success");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}

@end

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Network)

// 仅对一级字典结构起作用
+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params {
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [params count] == 0) {
        return url;
    }
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}

+ (NSString *)networkingUrlString_md5:(NSString *)string {
    if (string == nil || [string length] == 0) {
        return nil;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    return [ms copy];
}

+ (NSString *)cachesPathString{
    //Caches目录
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *pathcaches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *createPath = [pathcaches stringByAppendingPathComponent:NetworkCache];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return createPath;
}

@end

