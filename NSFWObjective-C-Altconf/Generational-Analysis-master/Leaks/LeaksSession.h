//
//  LeaksSession.h
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaksSession : NSObject
@property (nonatomic, readonly) NSHashTable *leaks;
@property (nonatomic, readonly) NSUInteger index;
@end