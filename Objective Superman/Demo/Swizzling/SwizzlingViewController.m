//
//  ViewController.m
//  Swizzling
//
//  Created by Sash Zats on 11/26/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "SwizzlingViewController.h"

#import "BadGuy.h"
#import "Superswizzling.h"
#import <JRSwizzle/JRSwizzle.h>

@implementation BadGuy (JRSwizzle)

- (void)swizzled_doInnocentStuff {
    NSLog(@"Tra-la-la");
}

- (void)swizzled_doBadStuff {
    NSLog(@"Be quiet now, they are about to do bad stuff!");
    
    [self swizzled_doBadStuff];
    
    NSLog(@"A-ha!");
}

@end


@interface SwizzlingViewController ()
@end


@implementation SwizzlingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    BadGuy *badGuy = [[BadGuy alloc] init];
    [badGuy doInnocentStuff];
    
    [self _jr_swizzleStuff];
//    [self _jr_swizzleBadStuff];
    
    [self _super_swizzleStuff];
    [self _super_swizzleBadStuff];
    
    [badGuy doInnocentStuff];
}

- (void)_jr_swizzleStuff {
    [BadGuy jr_swizzleMethod:@selector(doInnocentStuff)
                  withMethod:@selector(swizzled_doInnocentStuff)
                       error:nil];
}

- (void)_jr_swizzleBadStuff {
    [BadGuy jr_swizzleMethod:@selector(doBadStuff)
                  withMethod:@selector(swizzled_doBadStuff)
                       error:nil];
}

- (void)_super_swizzleStuff {
    
}

- (void)_super_swizzleBadStuff {
    SEL badStuffSelector = @selector(doBadStuff);
    typedef void(*bad_stuff_t)(id, SEL);
    __block bad_stuff_t badStuff = (bad_stuff_t)[BadGuy S_replaceInstanceMethod:badStuffSelector withBlock:^(BadGuy *self){
        NSLog(@"Now be quiet, %@ is about to do bad stuff", self);
        badStuff(self, badStuffSelector);
        NSLog(@"A-ha! Hold it right there!");
    }];
}

@end
