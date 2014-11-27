//
//  BadGuy+JRSwizzle.m
//  Objective Superman
//
//  Created by Sash Zats on 11/26/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "BadGuy+JRSwizzle.h"

@implementation BadGuy (JRSwizzle)

- (void)superman_catchBadGuysDoingBadStuff {
    NSLog(@"Be quiet now, they are about to do bad stuff!");
    
    [self superman_catchBadGuysDoingBadStuff];

    NSLog(@"A-ha!");
}

@end
