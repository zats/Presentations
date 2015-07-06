//
//  LeaksInspectorContext.h
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LeaksInspectorTypes.h"


typedef NS_ENUM(NSInteger, LeaksInspectorType) {
    LeaksInspectorTypeAllResults,
    LeaksInspectorTypeEnumeration
};


@interface _LeaksInspectorContext : NSObject

+ (instancetype)contextForEnumerationWithBlock:(leaks_inspector_enumeration_t)block;
+ (instancetype)contextForAllResultsWithOptions:(NSPointerFunctionsOptions)options;
@property (nonatomic, readonly) NSHashTable *results;
@property (nonatomic, copy, readonly) leaks_inspector_enumeration_t block;
@property (nonatomic) BOOL stop;
@property (nonatomic, readonly) LeaksInspectorType type;

@end
