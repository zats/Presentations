//
//  Passwords.m
//  Objective Superman
//
//  Created by Sash Zats on 5/21/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "Passwords.h"

NSArray *const Passwords() {
    static NSArray *passwords;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        passwords = @[ @"123456", @"password", @"qwerty", @"abc123", @"admin"];
    });
    return passwords;
}

NSString *RandomPassowrd() {
    return Passwords()[arc4random_uniform((u_int32_t)Passwords().count)];
}