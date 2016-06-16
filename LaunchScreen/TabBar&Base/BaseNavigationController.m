//
//  BaseNavigationController.m
//  LaunchScreen
//
//  Created by ClaudeLi on 16/6/16.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setShadowImage:[UIImage new]];
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationBar setBarTintColor:[[UIColor blueColor] colorWithAlphaComponent:0.6]];
    [self.navigationBar setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.6]];
    
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:17]};
    [self.navigationBar setTitleTextAttributes:dic];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
