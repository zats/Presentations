//
//  LeakingViewController.m
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "LeakingViewController.h"

@implementation LeakingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.875 green:0.282 blue:0.235 alpha:1.000];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id sself = self;
    self.handler = ^{
        // intentional retain cycle
        NSLog(@"%@", sself);
    };
}

@end
