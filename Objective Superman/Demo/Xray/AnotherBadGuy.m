//
//  AnotherBadGuy.m
//  Objective Superman
//
//  Created by Sash Zats on 11/28/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "AnotherBadGuy.h"

#import "Vault.h"

@interface AnotherBadGuy ()

@end

@implementation AnotherBadGuy

+ (void)load {
    @autoreleasepool {
        [[AnotherBadGuy theBadGuy] startPickingLock];
    }
}

+ (instancetype)theBadGuy {
    static AnotherBadGuy *instnace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instnace = [[AnotherBadGuy alloc] init];
    });
    return instnace;
}

- (void)startPickingLock {
    [self performSelector:@selector(_pickLock) withObject:nil afterDelay:arc4random_uniform(10)/5.0f + 1];
}

- (void)_pickLock {
    BOOL headsOrTails = arc4random_uniform(10) > 5;
    if (headsOrTails) {
        id context = [Vault mainVault].contents;
        [self sendVaultContent:context];
    }
    [self performSelector:@selector(_pickLock) withObject:nil afterDelay:arc4random_uniform(10)/5.0f + 1];
}

- (void)sendVaultContent:(id)content {

}

@end
