//
//  Playground.m
//  Run, time, run!
//
//  Created by Sash Zats on 11/15/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Playground.h"
#import <UIKit/UIKit.h>
#import "Lab.h"


@implementation Playground

- (void)run {
    Pig *pig = [Lab pig];
    [pig pullTail];
    printf("\n");
    
    
    
    
    
    
    
    
    
    
    
    Spiderman spiderman = [Lab spiderman];
    [spiderman shootWeb];
    [spiderman addPower:NSUIntegerMax withResponsibilty:NSUIntegerMax];
    printf("Spiderman is%s a pig!\n", [spiderman isKindOfClass:[Pig class]] ? "" : " not");
    printf("\n");
    
    
    
    
    
    
    
    
    
    
    Spiderpig spiderpig = [Lab spiderpig];
    [spiderpig shootWeb];
    [spiderpig addPower:NSUIntegerMax withResponsibilty:NSUIntegerMax];
    [spiderpig pullTail];
    printf("\n");
    
    [spiderman foo];
    
    printf("Spider? %s\n", [spiderpig isKindOfClass:[Spider class]] ? "Yes" : "No");
    printf("Peter Parker? %s\n", [spiderpig isKindOfClass:[PeterParker class]] ? "Yes" : "No");
    printf("Pig? %s\n", [spiderpig isKindOfClass:[Pig class]] ? "Yes" : "No");
}

@end
