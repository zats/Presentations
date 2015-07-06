//
//  UIKit+Kitty
//  UIKitty
//
//  Created by Sash Zats on 6/28/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

@import UIKit;

@interface UIPopoverController (Kitty)
@property (nonatomic, readonly) UIPopoverPresentationController *presentationController;
@end


@interface UIPopoverPresentationController (Kitty)
- (UIEdgeInsets)_dimmingViewTopEdgeInset;
- (void)_setDimmingViewTopEdgeInset:(UIEdgeInsets)insets;
@end
