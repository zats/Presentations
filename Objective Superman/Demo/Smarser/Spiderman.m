//
//  Spiderman.m
//  Objective Superman
//
//  Created by Sash Zats on 11/22/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Spiderman.h"

@implementation Spiderman

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p name=\"%@\"; power=%@; resposnibility=%@>", [self class], self, self.name, self.power, self.responsibility];
}

@end
