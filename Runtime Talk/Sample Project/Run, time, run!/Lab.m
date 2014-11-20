//
//  Lab.m
//  Run, time, run!
//
//  Created by Sash Zats on 11/15/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Lab.h"

@interface NSMutableOrderedSet (Lab)
- (void)xorOrderedSet:(NSOrderedSet *)set;
@end

@implementation NSMutableOrderedSet (Lab)

- (void)xorOrderedSet:(NSOrderedSet *)set {
    NSMutableOrderedSet *copy = [set mutableCopy];
    [copy minusOrderedSet:self];
    [self unionOrderedSet:copy];
}

@end

IMP imp_isKindOfClassesArray(NSSet *classes) {
    NSMutableSet *allClasses = [classes mutableCopy];
    for (Class class in classes) {
        if ([class respondsToSelector:@selector(isMutant)] &&
            [class isMutant]) {
            [allClasses unionSet:[class protoclasses]];
        }
    }
    return imp_implementationWithBlock(^BOOL(id self, Class otherClass){
        return [allClasses containsObject:otherClass];
    });
}

IMP imp_isKindOfClasses(Class class1, ...) {
    NSMutableArray *classes = [NSMutableArray array];
    va_list args;
    va_start(args, class1);
    for (Class arg = class1; arg != nil; arg = va_arg(args, Class)) {
        [classes addObject:arg];
    }
    va_end(args);
    return imp_isKindOfClassesArray([classes copy]);
}

const char *zts_typesSignature(char *type1 ,...) {
    NSMutableString *string = [NSMutableString string];
    va_list args;
    va_start(args, type1);
    for (char *arg = type1; arg != nil; arg = va_arg(args, char *)) {
        [string appendFormat:@"%s", arg];
    }
    va_end(args);
    return [string UTF8String];
}

void zts_copyMethodsFrom(Class source, Class target) {
    unsigned int methodsCount;
    Method *methods = zts_classMethods(source, &methodsCount);
    for (unsigned int i = 0; i < methodsCount; ++i) {
        Method method = methods[i];
        IMP imp = method_getImplementation(method);
        SEL sel = method_getName(method);
        const char *types = method_getDescription(method)->types;
        class_addMethod(target, sel, imp, types);
    }
}

void zts_signMutantClass(Class class, NSArray *classes) {
    Class metaclass = object_getClass(class);
    class_addMethod(metaclass, @selector(isMutant), imp_implementationWithBlock(^BOOL(id self){
        return YES;
    }), zts_typesSignature(@encode(BOOL), @encode(id), nil));
    
    class_addMethod(metaclass, @selector(protoclasses), imp_implementationWithBlock(^NSSet *(id self){
        return [NSSet setWithArray:classes];
    }), zts_typesSignature(@encode(NSArray *), @encode(id), nil));
}

Method *zts_classMethods(Class class, unsigned int *count) {
    return class_copyMethodList(class, count);
}

NSOrderedSet *zts_superclassesChain(Class class) {
    NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
    do {
        [set addObject:class];
    } while ((class = class_getSuperclass(class)));
    return [set copy];
}

NSOrderedSet *zts_allSuperclassesChain(NSArray *classes) {
    NSMutableOrderedSet *allClasses = [NSMutableOrderedSet orderedSet];
    for (Class class in classes) {
        [allClasses xorOrderedSet:zts_superclassesChain(class)];
    }
    return [allClasses copy];
}

Class zts_mutantClass(NSString *mutantName, Class class1, ...) {
    Class result = objc_allocateClassPair([NSObject class], [mutantName UTF8String], 0);

    // list of classes
    NSMutableArray *classes = [NSMutableArray array];
    va_list args;
    va_start(args, class1);
    for (Class arg = class1; arg != nil; arg = va_arg(args, Class)) {
        [classes addObject:arg];
    }
    va_end(args);

    
    // Is kind of class
    ({
        IMP imp = imp_isKindOfClassesArray([NSSet setWithArray:classes]);
        const char *signature = zts_typesSignature(@encode(BOOL), @encode(id), @encode(SEL), nil);
        class_addMethod(result, @selector(isKindOfClass:), imp, signature);
    });
    
    // All superclasses
    NSMutableOrderedSet *allClasses = [zts_allSuperclassesChain(classes) mutableCopy];
    [allClasses removeObject:[NSObject class]];
    
    // Copy all methods from all superclasses
    for (Class class in allClasses) {
        zts_copyMethodsFrom(class, result);
    }
    
    zts_signMutantClass(result, classes);

    objc_registerClassPair(result);

    return result;
}

@implementation Lab

+ (Spiderpig)spiderpig {
    static Class SpiderpigClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SpiderpigClass = zts_mutantClass(@"Spiderpig", NSClassFromString(@"Spiderman"), [Pig class], nil);
        
        // quick info
        IMP imp = imp_implementationWithBlock(^id(id self){
            return [UIImage imageNamed:@"spider-pig"];
        });
        const char *types = zts_typesSignature(@encode(id),@encode(id),nil);
        class_addMethod(SpiderpigClass, sel_getUid("debugQuickLookObject"), imp, types);
    });
    
    return [[SpiderpigClass alloc] init];
}

+ (Pig *)pig {
    return [Pig new];
}

+ (Spiderman)spiderman {
    static Class SpidermanClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SpidermanClass = zts_mutantClass(@"Spiderman", [PeterParker class], [Spider class], nil);
    });
    return [[SpidermanClass alloc] init];
}

@end
