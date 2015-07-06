//
//  RootViewController.m
//  Leaks
//
//  Created by Sash Zats on 2/11/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "RootViewController.h"

#import "LeaksInstrument.h"

#import "LeakingViewController.h"
#import "NotLeakingViewController.h"

@interface RootViewController ()
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.925 green:0.624 blue:0.071 alpha:1.000];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
    });
    
}

- (IBAction)_addButtonAction:(id)sender {
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushLeakingViewController {
    [self.navigationController pushViewController:[LeakingViewController new]
                                         animated:YES];
}

- (void)pushNotLeakingViewController {
    [self.navigationController pushViewController:[NotLeakingViewController new]
                                         animated:YES];
}

@end
