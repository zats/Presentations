//
//  BadGuy.m
//  Objective Superman
//
//  Created by Sash Zats on 11/28/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "BadGuy.h"

#import "Vault.h"
#import "Passwords.h"

@interface BadGuy ()

@end

@implementation BadGuy

+ (instancetype)theBadGuy {
    static BadGuy *instnace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instnace = [[BadGuy alloc] init];
    });
    return instnace;
}

- (void)startPickingLock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _pickLock];
    });
}

- (void)_pickLock {
    NSString *code = RandomPassowrd();
    if ([[Vault mainVault].code isEqualToString:code]) {
        printf("\n%s picked the code: %s\n", self.description.UTF8String, code.UTF8String);
        id context = [Vault mainVault].contents;
        [self sendVaultContent:context];
    }
    [self performSelector:@selector(_pickLock) withObject:nil afterDelay:arc4random_uniform(10)/5.0f + 1];
}

- (void)sendVaultContent:(id)content {

}

@end
