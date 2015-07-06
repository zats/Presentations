//
//  LeaksInstrument.h
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaksInstrument : NSObject

+ (instancetype)sharedInstrument;

@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, copy, readonly) NSArray *allSession;

/**
 *  Sessions excluding first and last ones
 */
@property (nonatomic, copy, readonly) NSArray *representativeSessions;

/**
 *  @return @c YES if @c representativeSessions contains at least one leaked
 */
@property (nonatomic, readonly) BOOL hasLeaksInRepresentativeSession;

/**
 *  One hash table containing all the leaks from representative sessions
 *  @see representativeSessions
 */
@property (nonatomic, readonly) NSHashTable *cumulativeLeaksFromRepresentativeSessions;

- (void)measure;

- (void)reset;

@end
