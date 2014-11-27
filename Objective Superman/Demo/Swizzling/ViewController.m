//
//  ViewController.m
//  Swizzling
//
//  Created by Sash Zats on 11/26/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "ViewController.h"

#import "Swizzling.h"
#import "BadGuy.h"
#import "BadGuy+JRSwizzle.h"
#import <JRSwizzle/JRSwizzle.h>

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    BadGuy *badGuy = [[BadGuy alloc] init];
//    [badGuy doBadStuff];
    
//    [self _jr_swizzle];
    [self _super_swizzle];
    [badGuy doBadStuff];
}

- (void)_jr_swizzle {
    NSError *error;
    
    BOOL didSwizzle = [BadGuy jr_swizzleMethod:@selector(doBadStuff)
                                    withMethod:@selector(superman_catchBadGuysDoingBadStuff)
                                         error:&error];
    NSAssert(didSwizzle, @"Failed to swizzle: %@", error);
}

- (void)_super_swizzle {
    SEL badStuffSelector = @selector(doBadStuff);
    typedef void(*bad_stuff_t)(id, SEL);
    __block bad_stuff_t badStuff = (bad_stuff_t)[BadGuy S_replaceInstanceMethod:badStuffSelector withBlock:^(BadGuy *self){
        NSLog(@"Now be quiet, %@ is about to do bad stuff", self);
        badStuff(self, badStuffSelector);
        NSLog(@"A-ha! Hold it right there!");
    }];
}

@end
