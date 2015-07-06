//
//  RootViewController.h
//  Leaks
//
//  Created by Sash Zats on 2/11/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

- (void)pushLeakingViewController;

- (void)pushNotLeakingViewController;

@end
