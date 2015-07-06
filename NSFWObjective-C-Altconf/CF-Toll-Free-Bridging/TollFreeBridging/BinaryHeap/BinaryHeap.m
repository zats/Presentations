//
//  BinaryHeap.m
//  TollFreeBridging
//
//  Created by Sash Zats on 2/11/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "BinaryHeap.h"

#import "_BinaryHeapRegistration.h"
#import "_Buckets.h"



@interface BinaryHeap ()
@property (nonatomic, copy) NSComparator comparator;
@property (nonatomic) NSUInteger count;
@property (nonatomic) _Buckets *buckets;
@end


@implementation BinaryHeap

#pragma mark - Registration

+ (void)load {
    // We don't care if the class is us or any subclass,
    // but we do care for the registration code to be run only once.
    @autoreleasepool {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[_BinaryHeapRegistration sharedHeapRegistration] swizzleCoreFoundation];
            [[_BinaryHeapRegistration sharedHeapRegistration] registerBridging];
        });
    }
}

#pragma mark - Factories

+ (instancetype)minimumHeap {
    return [self heapWithComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
}

+ (instancetype)maximumHeap {
    return [self heapWithComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        switch ([obj1 compare:obj2]) {
            case NSOrderedDescending:
                return NSOrderedAscending;
                
            case NSOrderedAscending:
                return NSOrderedDescending;
            
            case NSOrderedSame:
                return NSOrderedSame;
        }
    }];
}

+ (instancetype)heapWithComparator:(NSComparator)comparator {
    return [[self alloc] initWithComparator:comparator];
}

#pragma mark - Lifecycle

- (instancetype)initWithComparator:(NSComparator)comparator {
    NSParameterAssert(comparator);
    self = [super init];
    if (!self) {
        return nil;
    }
    self.comparator = comparator;
    self.buckets = [[_Buckets alloc] init];
    return self;
}

- (instancetype)init {
    return [self initWithComparator:nil];
}

#pragma mark - Public

- (void)addObject:(id)obj {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        CFBinaryHeapAddValue((CFBinaryHeapRef)self, (void *)obj);
        return;
    }
    
    NSInteger idx = self.count;
    self.count++;
    NSInteger pidx = (idx - 1) >> 1;
    while (idx > 0) {
        id item = self.buckets[pidx];
        if (self.comparator(item, obj) != NSOrderedDescending) break;
        self.buckets[idx] = item;
        idx = pidx;
        pidx = (idx - 1) >> 1;
    }
    self.buckets[idx] = obj;
}

- (id)peek {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        return CFBinaryHeapGetMinimum((CFBinaryHeapRef)self);
    }

    return self.buckets[0];
}

- (void)removeMinimumObject {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        CFBinaryHeapRemoveMinimumValue((CFBinaryHeapRef)self);
        return;
    }

    if (!self.count) return;
    NSUInteger cnt = self.count, idx = 0, cidx;
    self.count--;
    [self.buckets removeObjectAtIndex:idx];
    id obj = self.buckets[cnt - 1];
    cidx = (idx << 1) + 1;
    while (cidx < self.count) {
        id item = self.buckets[cidx];
        if (cidx + 1 < self.count) {
            id item2 = self.buckets[cidx + 1];
            if (self.comparator(item, item2) == NSOrderedDescending) {
                cidx++;
                item = item2;
            }
        }
        if (self.comparator(item, obj) == NSOrderedDescending) break;
        self.buckets[idx] = item;
        idx = cidx;
        cidx = (idx << 1) + 1;
    }
    if (obj) {
        self.buckets[idx] = obj;
    }
}

- (void)removeAllObjects {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        CFBinaryHeapRemoveAllValues((CFBinaryHeapRef)self);
        return;
    }
    
    self.count = 0;
    [self.buckets removeAllObjects];
}

- (void)getObjects:(__unsafe_unretained id [])objects {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not implemented" userInfo:nil];
        return;
    }

    if (!self.count) return;
    BinaryHeap *heap = [self copy];
    NSUInteger idx = 0;
    while (heap.count) {
        objects[idx++] = heap.peek;
        [heap removeMinimumObject];
    }
}

- (BOOL)containsObject:(id)object {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        return CFBinaryHeapContainsValue((CFBinaryHeapRef)self, (void *)object);
    }
    
    for (NSUInteger i = 0; i < self.count; ++i) {
        if ([self.buckets[i] isEqual:object]) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)countForObject:(id)object {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        return CFBinaryHeapGetCountOfValue((CFBinaryHeapRef)self, (void *)object);
    }

    NSUInteger count = 0;
    for (NSUInteger i = 0; i < self.count; ++i) {
        if ([self.buckets[i] isEqual:object]) {
            count++;
        }
    }
    return count;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        return CFBridgingRelease(CFBinaryHeapCreateCopy(CFGetAllocator((CFBinaryHeapRef)self), 0, (CFBinaryHeapRef)self));
    }

    BinaryHeap *instance = [[BinaryHeap alloc] initWithComparator:self.comparator];
    instance.buckets = [self.buckets copy];
    instance.count = self.count;
    return instance;
}

@end
