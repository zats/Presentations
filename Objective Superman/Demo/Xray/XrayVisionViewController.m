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
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface XrayVisionViewController ()

@property (nonatomic, strong) Vault *vault;

@end

@implementation XrayVisionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupVault];
}

- (void)dealloc {
    [self teardownVault];
}

#pragma mark - Private

- (void)teardownVault {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.vault stopXraying];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.vault stopVault];
        self.vault = nil;
    });
}

- (void)_setupVault {
    self.vault = [[Vault alloc] init];
    [self.vault startVault];
}

- (void)xrayMeBaby {
    [self.vault xrayProperty:@keypath(self.vault, code) withOptions:0 handler:^(id target, NSString *property, NSString *code) {
        NSLog(@"%@.%@ = %@", [target class], property, code);
    }];
}

- (void)someExtraXray {
    [self.vault xrayProperty:@keypath(self.vault, contents) withOptions:XrayOptionGetter handler:^(id target, NSString *property, id contents) {
        NSLog(@"%@.%@ = %@", [target class], property, contents);
    }];
}

@end
