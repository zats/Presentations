//
//  BinaryHeap.h
//  TollFreeBridging
//
//  Created by Sash Zats on 2/11/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BinaryHeap : NSObject <NSCopying>

+ (instancetype)minimumHeap;

+ (instancetype)maximumHeap;

+ (instancetype)heapWithComparator:(NSComparator)comparator;

@property (nonatomic, copy, readonly) NSComparator comparator;

@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, readonly) id peek;

- (instancetype)initWithComparator:(NSComparator)comparator;

- (NSUInteger)countForObject:(id)object;

- (BOOL)containsObject:(id)object;

- (void)addObject:(id)object;

- (void)getObjects:(id __unsafe_unretained[])objects;

- (void)removeMinimumObject;

- (void)removeAllObjects;

@end
