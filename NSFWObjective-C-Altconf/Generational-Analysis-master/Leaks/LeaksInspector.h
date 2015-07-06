//
//  InstancesManager.h
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LeaksInspectorTypes.h"

@interface LeaksInspector : NSObject

- (NSHashTable *)allInstancesWithOptions:(NSPointerFunctionsOptions)options;

- (void)enumerateAllInstancesUsingBlock:(leaks_inspector_enumeration_t)block;

@end
