//
//  SpiderPig.m
//  Run, time, run!
//
//  Created by Sash Zats on 11/15/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "SpiderPig.h"

#import "PeterParker.h"
#import "Spider.h"
#import "Lab.h"
#import <objc/runtime.h>

Class CreateSpiderPigClass() {
    static Class SpiderpigClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class SpidermanClass = NSClassFromString(@"Spiderman");
        Class PigClass = [Pig class];

        SpiderpigClass = zts_mutantClass(@"Spiderpig", SpidermanClass, PigClass, nil);
        
    });
    return SpiderpigClass;
}

Spiderpig CreateSpiderpig() {
    Class spiderpigClass = CreateSpiderPigClass();
    return [[spiderpigClass alloc] init];
}
