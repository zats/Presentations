//
//  Superswizzling.h
//  Objective Superman
//
//  Created by Sash Zats on 11/26/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Superswizzling)

+ (IMP)S_replaceInstanceMethod:(SEL)originalSelector withBlock:(id)block;

+ (IMP)S_replaceClassMethod:(SEL)originalSelector withBlock:(id)block;

@end
