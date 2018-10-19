//
//  TTLaunchAdItem.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/12/5.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTLaunchAdItem : NSObject

@property (nonatomic, copy) NSString *id;

/**
 广告类型，1：image，2：video
 */
@property (nonatomic, assign) NSInteger style_type;
@property (nonatomic, copy) NSString *style_value;

@property (nonatomic, copy) NSString *skip_type;
@property (nonatomic, copy) NSString *skip_value;

// 下载广告后保存在本地文件名
@property (nonatomic, copy) NSString *fileName;

@end
