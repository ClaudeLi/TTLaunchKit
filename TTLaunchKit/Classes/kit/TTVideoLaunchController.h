//
//  TTVideoLaunchController.h
//  Tiaooo
//
//  Created by ClaudeLi on 2018/4/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTVideoLaunchController : UIViewController

@property (nonatomic, copy) void (^playFinished)(void);
@property (nonatomic, strong) NSString *moviePath;   //视频路径

@end
