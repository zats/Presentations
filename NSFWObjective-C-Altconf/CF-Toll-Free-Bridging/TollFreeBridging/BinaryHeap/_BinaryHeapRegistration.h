//
//  _BinaryHeapRegistration.h
//  TollFreeBridging
//
//  Created by Sash Zats on 2/15/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _BinaryHeapRegistration : NSObject

+ (instancetype)sharedHeapRegistration;

- (void)registerBridging;

- (void)swizzleCoreFoundation;

@end
