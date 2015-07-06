//
//  InstanceInspectorTypes.h
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^leaks_inspector_enumeration_t)(Class cls, void *instance, BOOL *stop);
