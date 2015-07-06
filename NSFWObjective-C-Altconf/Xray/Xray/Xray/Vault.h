//
//  Vault.h
//  Objective Superman
//
//  Created by Sash Zats on 11/21/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Shoebox.h"

#import <CoreGraphics/CoreGraphics.h>

@interface Vault : Shoebox

+ (instancetype)mainVault;

@property (nonatomic, copy, readonly) NSString *code;

- (void)startVault;

- (void)stopVault;

@end
