//
//  NotLeakingViewController.m
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "NotLeakingViewController.h"

@implementation NotLeakingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.243 green:0.745 blue:0.600 alpha:1.000];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak id weak_self = self;
    self.handler = ^{
        NSLog(@"%@", weak_self);
    };
}


@end
