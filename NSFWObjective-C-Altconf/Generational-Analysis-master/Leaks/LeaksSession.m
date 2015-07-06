//
//  LeaksSession.m
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "LeaksSession.h"
#import "LeaksSession+Private.h"


@implementation LeaksSession

- (NSString *)description {
    if (!self.leaks.count) {
        return [NSString stringWithFormat:@"<%@:%p> {index = %tu; no leaks}", [self class], self, self.index];
    }
    return [NSString stringWithFormat:@"<%@:%p> {index=%tu; leaks=%@}", [self class], self, self.index, [[self.leaks allObjects] componentsJoinedByString:@", "]];
}

@end
