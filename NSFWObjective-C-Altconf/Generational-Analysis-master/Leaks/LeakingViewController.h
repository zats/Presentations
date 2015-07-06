//
//  LeakingViewController.h
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeakingViewController : UIViewController

@property (nonatomic, copy) void(^handler)(void);

@end
