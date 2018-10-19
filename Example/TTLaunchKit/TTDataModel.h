//
//  TTDataModel.h
//  TTLaunchKit_Example
//
//  Created by ClaudeLi on 2018/10/18.
//  Copyright © 2018年 claudeli@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTLaunchAdItem;

NS_ASSUME_NONNULL_BEGIN

@interface TTDataModel : NSObject

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) TTLaunchAdItem *data;

@end

NS_ASSUME_NONNULL_END
