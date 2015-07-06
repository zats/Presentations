//
//  LeaksInspectorContext.m
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "_LeaksInspectorContext.h"

@implementation _LeaksInspectorContext

+ (instancetype)contextForEnumerationWithBlock:(leaks_inspector_enumeration_t)block {
    _LeaksInspectorContext *context = [_LeaksInspectorContext new];
    context->_block = block;
    context->_type = LeaksInspectorTypeEnumeration;
    return context;
}

+ (instancetype)contextForAllResultsWithOptions:(NSPointerFunctionsOptions)options {
    _LeaksInspectorContext *context = [_LeaksInspectorContext new];
    context->_results = [[NSHashTable alloc] initWithOptions:options capacity:0];
    context->_type = LeaksInspectorTypeAllResults;
    return context;
}

- (BOOL)stop {
    // only return YES if we're enumerating
    return self.type == LeaksInspectorTypeEnumeration && _stop;
}

@end
