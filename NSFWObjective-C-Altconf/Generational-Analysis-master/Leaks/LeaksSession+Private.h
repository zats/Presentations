//
//  LeaksSession+Private.h
//  Leaks
//
//  Created by Sash Zats on 2/18/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "LeaksSession.h"

@interface LeaksSession ()
@property (nonatomic) NSHashTable *leaks;
@property (nonatomic) NSUInteger index;
@end
