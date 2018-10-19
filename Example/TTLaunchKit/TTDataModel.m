//
//  TTDataModel.m
//  TTLaunchKit_Example
//
//  Created by ClaudeLi on 2018/10/18.
//  Copyright © 2018年 claudeli@yeah.net. All rights reserved.
//

#import "TTDataModel.h"
#import <TTLaunchKit/TTLaunchAdItem.h>

@implementation TTDataModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [TTLaunchAdItem class]};
}

@end
