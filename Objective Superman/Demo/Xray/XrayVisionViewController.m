//
//  XrayVisionViewController.m
//  Objective Superman
//
//  Created by Sash Zats on 11/21/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "XrayVisionViewController.h"

#import "Xray.h"
#import "Vault.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACBacktrace.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface XrayVisionViewController ()

@property (nonatomic, strong) Vault *vault;

@end

@implementation XrayVisionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVault];
//    [self xrayMeBaby];
//    [self someExtraXray];
}

- (void)setupVault {
    self.vault = [Vault mainVault];
    [self.vault startVault];
}

- (void)xrayMeBaby {
    [self.vault xrayProperty:@keypath(self.vault, code) withOptions:0 handler:^(id target, NSString *property, NSString *code) {
        NSLog(@"%@.%@ = %@", [target class], property, code);
    }];
}

- (void)someExtraXray {
    [self.vault xrayProperty:@keypath(self.vault, contents) withOptions:XrayOptionGetter handler:^(id target, NSString *property, id contents) {
        NSLog(@"%@.%@ was accessed:\n%@", [target class], property, [RACBacktrace backtrace].callStackSymbols[2]);
    }];
}

@end
