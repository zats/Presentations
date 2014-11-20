//
//  Lab.h
//  Run, time, run!
//
//  Created by Sash Zats on 11/15/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Spiderman.h"
#import "SpiderPig.h"

#import <objc/runtime.h>

extern IMP imp_isKindOfClasses(Class class1, ...) NS_REQUIRES_NIL_TERMINATION;

extern const char *zts_typesSignature(char *type1 ,...) NS_REQUIRES_NIL_TERMINATION;

extern Method *zts_classMethods(Class class, unsigned int *count);

extern void zts_copyMethodsFrom(Class source, Class target);

extern Class zts_mutantClass(NSString *mutantName, Class class1, ...) NS_REQUIRES_NIL_TERMINATION;


@interface Lab : NSObject

+ (Spiderman)spiderman;

+ (Spiderpig)spiderpig;

+ (Pig *)pig;

@end

@protocol IsMutant <NSObject>

@required
+ (BOOL)isMutant;

+ (NSSet *)protoclasses;

@end
