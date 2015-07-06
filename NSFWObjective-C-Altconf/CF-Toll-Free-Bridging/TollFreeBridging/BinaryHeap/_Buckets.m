//
//  _BinaryHeapBuckets.m
//  TollFreeBridging
//
//  Created by Sash Zats on 2/15/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "_Buckets.h"


const void *BKT_keyRetain(CFAllocatorRef allocator, const void *value) {
    return value;
}

void BKT_keyRelease(CFAllocatorRef allocator, const void *value) {
}

Boolean BKT_keyEquality(const void *value1, const void *value2) {
    return (NSUInteger)value1 == (NSUInteger)value2;
}

CFHashCode BKT_hash(const void *value) {
    return 31 + (NSUInteger)value;
}


@interface _Buckets ()
@property (nonatomic) CFMutableDictionaryRef dictionary;
@end

@implementation _Buckets

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    CFDictionaryKeyCallBacks keyCallBacks;
    keyCallBacks.retain = BKT_keyRetain;
    keyCallBacks.release = BKT_keyRelease;
    keyCallBacks.equal = BKT_keyEquality;
    keyCallBacks.hash = BKT_hash;
    self.dictionary = (__bridge CFMutableDictionaryRef)CFBridgingRelease(CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keyCallBacks, &kCFTypeDictionaryValueCallBacks));
    return self;
}

#pragma mark - Public

- (NSUInteger)count {
    return CFDictionaryGetCount(self.dictionary);
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    [self setObject:obj atIndex:idx];
}

- (id)objectAtIndexSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

- (void)setObject:(id)obj atIndex:(NSUInteger)idx {
    NSParameterAssert(obj);
    CFDictionarySetValue(self.dictionary, (void *)idx, (__bridge void *)obj);
}

- (void)removeObjectAtIndex:(NSUInteger)idx {
    CFDictionaryRemoveValue(self.dictionary, (void *)idx);
}

- (void)removeAllObjects {
    CFDictionaryRemoveAllValues(self.dictionary);
}

- (id)objectAtIndex:(NSUInteger)idx {
    return CFDictionaryGetValue(self.dictionary, (void *)idx);
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

- (id)copyWithZone:(NSZone *)zone {
    _Buckets *buckets = [[_Buckets allocWithZone:zone] init];
    buckets.dictionary = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, self.dictionary);
    return buckets;
}

- (NSString *)description {
    return CFBridgingRelease(CFCopyDescription(self.dictionary));
}

@end
