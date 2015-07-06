//
//  _BinaryHeapRegistration.m
//  TollFreeBridging
//
//  Created by Sash Zats on 2/15/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "_BinaryHeapRegistration.h"

#import "BinaryHeap.h"
#import "fishhook.h"
#import <objc/runtime.h>
#import <dlfcn.h>

extern void _CFRuntimeBridgeClasses(CFTypeID cfType, const char *className);


CFIndex (*orig_CFBinaryHeapGetCount)(CFBinaryHeapRef heap);
CFIndex repl_CFBinaryHeapGetCount(CFBinaryHeapRef heap) {
    if (CFGetTypeID(heap) == CFBinaryHeapGetTypeID()) {
        return orig_CFBinaryHeapGetCount(heap);
    }
    return ((__bridge BinaryHeap *)heap).count;
}

CFIndex (*orig_CFBinaryHeapGetCountOfValue)(CFBinaryHeapRef heap, const void *value);
CFIndex repl_CFBinaryHeapGetCountOfValue(CFBinaryHeapRef heap, const void *value) {
    if (CFGetTypeID(heap) == CFBinaryHeapGetTypeID()) {
        return orig_CFBinaryHeapGetCountOfValue(heap, value);
    }
    return [(__bridge BinaryHeap *)heap countForObject:(__bridge id)value];
}

Boolean (*orig_CFBinaryHeapContainsValue)(CFBinaryHeapRef heap, const void *value);
Boolean repl_CFBinaryHeapContainsValue(CFBinaryHeapRef heap, const void *value) {
    if (CFGetTypeID(heap) == CFBinaryHeapGetTypeID()) {
        return orig_CFBinaryHeapContainsValue(heap, value);
    }
    return [(__bridge BinaryHeap *)heap containsObject:(__bridge id)value];
}
const void *(*orig_CFBinaryHeapGetMinimum)(CFBinaryHeapRef heap);
const void *repl_CFBinaryHeapGetMinimum(CFBinaryHeapRef heap) {
    if (CFGetTypeID(heap) == CFBinaryHeapGetTypeID()) {
        return orig_CFBinaryHeapGetMinimum(heap);
    }
    return (__bridge void *)((__bridge BinaryHeap *)heap).peek;
}
Boolean (*orig_CFBinaryHeapGetMinimumIfPresent)(CFBinaryHeapRef heap, const void **value);
Boolean repl_CFBinaryHeapGetMinimumIfPresent(CFBinaryHeapRef heap, const void **value) {
    if (CFGetTypeID(heap) == CFBinaryHeapGetTypeID()) {
        return orig_CFBinaryHeapGetMinimumIfPresent(heap, value);
    }
    id minimum = ((__bridge BinaryHeap *)heap).peek;;
    if (value) {
        *value = (__bridge  void *)minimum;
    }
    return minimum != nil;
}
void (*orig_CFBinaryHeapAddValue)(CFBinaryHeapRef heap, const void *value);
void repl_CFBinaryHeapAddValue(CFBinaryHeapRef heap, const void *value) {
    if (CFGetTypeID(heap) == CFBinaryHeapGetTypeID()) {
        orig_CFBinaryHeapAddValue(heap, value);
        return;
    }
    [(__bridge BinaryHeap *)heap addObject:(__bridge id)value];
}
void (*orig_CFBinaryHeapRemoveMinimumValue)(CFBinaryHeapRef heap);
void repl_CFBinaryHeapRemoveMinimumValue(CFBinaryHeapRef heap) {
    if (CFGetTypeID(heap) == CFBinaryHeapGetTypeID()) {
        orig_CFBinaryHeapRemoveMinimumValue(heap);
        return;
    }
    [(__bridge BinaryHeap *)heap removeMinimumObject];
}
void (*orig_CFBinaryHeapRemoveAllValues)(CFBinaryHeapRef heap);
void repl_CFBinaryHeapRemoveAllValues(CFBinaryHeapRef heap) {
    if (CFGetTypeID(heap) == CFBinaryHeapGetTypeID()) {
        orig_CFBinaryHeapRemoveAllValues(heap);
        return;
    }
    [(__bridge BinaryHeap *)heap removeAllObjects];
}


@implementation _BinaryHeapRegistration

+ (instancetype)sharedHeapRegistration {
    static _BinaryHeapRegistration *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)registerBridging {
    _CFRuntimeBridgeClasses(CFBinaryHeapGetTypeID(), class_getName([BinaryHeap class]));
}

- (void)swizzleCoreFoundation {
    orig_CFBinaryHeapGetCount = dlsym(RTLD_DEFAULT, "CFBinaryHeapGetCount");
    orig_CFBinaryHeapGetCountOfValue = dlsym(RTLD_DEFAULT, "CFBinaryHeapGetCountOfValue");
    orig_CFBinaryHeapContainsValue = dlsym(RTLD_DEFAULT, "CFBinaryHeapContainsValue");
    orig_CFBinaryHeapGetMinimum = dlsym(RTLD_DEFAULT, "CFBinaryHeapGetMinimum");
    orig_CFBinaryHeapGetMinimumIfPresent = dlsym(RTLD_DEFAULT, "CFBinaryHeapGetMinimumIfPresent");
    orig_CFBinaryHeapAddValue = dlsym(RTLD_DEFAULT, "CFBinaryHeapAddValue");
    orig_CFBinaryHeapRemoveMinimumValue = dlsym(RTLD_DEFAULT, "CFBinaryHeapRemoveMinimumValue");
    orig_CFBinaryHeapRemoveAllValues = dlsym(RTLD_DEFAULT, "CFBinaryHeapRemoveAllValues");
    
    rebind_symbols((struct rebinding[8]){
        {"CFBinaryHeapGetCount", repl_CFBinaryHeapGetCount},
        {"CFBinaryHeapGetCountOfValue", repl_CFBinaryHeapGetCountOfValue},
        {"CFBinaryHeapContainsValue", repl_CFBinaryHeapContainsValue},
        {"CFBinaryHeapGetMinimum", repl_CFBinaryHeapGetMinimum},
        {"CFBinaryHeapGetMinimumIfPresent", repl_CFBinaryHeapGetMinimumIfPresent},
        {"CFBinaryHeapAddValue", repl_CFBinaryHeapAddValue},
        {"CFBinaryHeapRemoveMinimumValue", repl_CFBinaryHeapRemoveMinimumValue},
        {"CFBinaryHeapRemoveAllValues", repl_CFBinaryHeapRemoveAllValues},
    }, 8);

}

@end
