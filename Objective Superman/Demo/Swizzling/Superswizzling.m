//
//  Superswizzling.m
//  Objective Superman
//
//  Created by Sash Zats on 11/26/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Superswizzling.h"

#import <objc/runtime.h>

@implementation NSObject (Superswizzling)

+ (IMP)S_replaceInstanceMethod:(SEL)originalSelector withBlock:(id)block {
    Class cls = self;
    return [self _S_replaceMethod:originalSelector inClass:cls withBlock:block];
}

+ (IMP)S_replaceClassMethod:(SEL)originalSelector withBlock:(id)block {
    Class cls = object_getClass(self);
    return [self _S_replaceMethod:originalSelector inClass:cls withBlock:block];
}

+ (IMP)_S_replaceMethod:(SEL)originalSelector inClass:(Class)cls withBlock:(id)block {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP newIMP = imp_implementationWithBlock(block);
    const char *originalMethodEncoding = method_getTypeEncoding(originalMethod);
    class_replaceMethod(cls, originalSelector, newIMP, originalMethodEncoding);
    return originalIMP;
}

@end
