//
//  Superman.m
//  Objective Superman
//
//  Created by Sash Zats on 11/22/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Superman.h"

@implementation Superman

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p name=\"%@\"; isBird=%@; isPlane=%@>", [self class], self, self.name, self.isBird ? @"YES" : @"NO", self.isPlane ? @"YES" : @"NO"];
}

@end
