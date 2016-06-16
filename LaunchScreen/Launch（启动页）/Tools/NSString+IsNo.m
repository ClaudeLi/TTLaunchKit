//
//  NSString+IsNo.m
//  Trip
//
//  Created by ClaudeLi on 16/6/15.
//  Copyright © 2016年 MonetWu. All rights reserved.
//

#import "NSString+IsNo.h"

@implementation NSString (IsNo)

+ (BOOL)isNilOrEmptyString:(NSString *)_str{
    if ([_str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    _str = [NSString stringWithFormat:@"%@", _str];
    if (![_str isKindOfClass:[NSString class]]) {
        return YES;
    }
    if(_str==nil||_str==NULL||[_str isEqual:@"null"]||[_str isEqual:[NSNull null]]||[_str isKindOfClass:[NSNull class]]){
        return YES;
    }
    if([_str isEqualToString:@"(null)"]){
        return YES;
    }
    if ([_str isEqualToString:@""]) {
        return YES;
    }
    if ([_str isEqualToString:@"<null>"]) {
        return YES;
    }
    return NO;
}

@end
