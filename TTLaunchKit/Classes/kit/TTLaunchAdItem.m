//
//  TTLaunchAdItem.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/12/5.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTLaunchAdItem.h"

@implementation TTLaunchAdItem

- (NSString *)fileName{
    if (!_fileName) {
        _fileName = [NSString stringWithFormat:@"launch_ad_%@", _id];
        if(_style_type == 2){
            _fileName = [NSString stringWithFormat:@"%@.mp4", _fileName];
        }
    }
    return _fileName;
}

@end
