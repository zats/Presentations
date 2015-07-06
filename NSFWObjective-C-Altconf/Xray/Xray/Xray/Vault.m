//
//  Vault.m
//  Objective Superman
//
//  Created by Sash Zats on 11/21/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Vault.h"

#import "Passwords.h"

@import UIKit;


@interface Vault ()

@property (nonatomic, strong) NSTimer *codeChangeTimer;

@property (nonatomic, copy) NSString *code;

@end


@implementation Vault

+ (instancetype)mainVault {
    static Vault *mainVault;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainVault = [[Vault alloc] init];
    });
    return mainVault;
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.contents = [UIImage imageNamed:@"superman-1"];    
    return self;
}

- (void)dealloc {
    [self.codeChangeTimer invalidate];
}

#pragma mark - Public

- (void)startVault {
    self.codeChangeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_changeCodeTimerHandler) userInfo:nil repeats:YES];
}

- (void)stopVault {
    [self.codeChangeTimer invalidate];
    self.codeChangeTimer = nil;
}

#pragma mark - Actions

- (void)_changeCodeTimerHandler {
    NSString *code = RandomPassowrd();
    self.code = code;
}

@end
