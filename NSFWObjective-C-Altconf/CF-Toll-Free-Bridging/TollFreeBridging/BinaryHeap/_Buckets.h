//
//  _BinaryHeapBuckets.h
//  TollFreeBridging
//
//  Created by Sash Zats on 2/15/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface _Buckets : NSObject <NSCopying>

@property (nonatomic, readonly) NSUInteger count;

- (id)objectAtIndex:(NSUInteger)idx;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

- (void)setObject:(id)obj atIndex:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

- (void)removeObjectAtIndex:(NSUInteger)idx;
- (void)removeAllObjects;

@end
