//
//  Spiderman.m
//  Run, time, run!
//
//  Created by Sash Zats on 11/15/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Spiderman.h"

#import "PeterParker.h"
#import "Spider.h"
#import "Lab.h"
#import <objc/runtime.h>

Class CreateSpidermanClass() {
    static Class SpidermanClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SpidermanClass = zts_mutantClass(@"Spiderman", [PeterParker class], [Spider class], nil);
    });
    return SpidermanClass;
}

id CreateSpiderman() {
    Class spidermanClass = CreateSpidermanClass();
    return [[spidermanClass alloc] init];
}
