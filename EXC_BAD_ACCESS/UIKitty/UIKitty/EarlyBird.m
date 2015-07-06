//
//  EarlyBird.m
//  
//
//  Created by Sash Zats on 6/28/15.
//
//

#import "EarlyBird.h"
#import <objc/runtime.h>


@interface EarlyBird : NSObject

@end

@implementation EarlyBird

+ (void)load {
    @autoreleasepool {
        [self _enumerateAllClasses];
    }
}

+ (void)_enumerateAllClasses {
    unsigned int classesCount = 0;
    Class *classList = objc_copyClassList(&classesCount);
    for (unsigned int i = 0; i < classesCount; ++i) {
        Class cls = classList[i];
        if (class_conformsToProtocol(cls, @protocol(EarlyBird))) {
            [[[cls alloc] init] getTheWorm];
        }
    }
    free(classList);
}

@end
