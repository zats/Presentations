//
//  Lab.m
//  Run, time, run!
//
//  Created by Sash Zats on 11/15/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Lab.h"


IMP imp_isKindOfClasses(Class class1, ...) NS_REQUIRES_NIL_TERMINATION;

const char *zts_typesSignature(char *type1 ,...) NS_REQUIRES_NIL_TERMINATION;

Method *zts_classMethods(Class class, unsigned int *count);

void zts_copyMethodsFrom(Class source, ClassBuilder *builder);

Class zts_mutantClass(NSString *mutantName, Class class1, ...) NS_REQUIRES_NIL_TERMINATION;


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

static const char *signature(char *type1 ,...) {
    NSMutableString *string = [NSMutableString string];
    va_list args;
    va_start(args, type1);
    for (char *arg = type1; arg != nil; arg = va_arg(args, char *)) {
        [string appendFormat:@"%s", arg];
    }
    va_end(args);
    return [string UTF8String];
}

void zts_copyMethodsFrom(Class cls, ClassBuilder *builder) {
    unsigned int methodsCount;
    Method *methods = class_copyMethodList(cls, &methodsCount);
    for (unsigned int i = 0; i < methodsCount; ++i) {
        Method method = methods[i];
        SEL s = method_getName(method);
        [builder copyMethod:s fromClass:cls];
    }
    free(methods);
    
    cls = object_getClass(cls);
    methods = class_copyMethodList(cls, &methodsCount);
    for (unsigned int i = 0; i < methodsCount; ++i) {
        Method method = methods[i];
        [builder copyMethod:method_getName(method) fromClass:cls];
    }
    free(methods);
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
    [allClasses removeObject:[NSObject class]];
    return [allClasses copy];
}

Class zts_mutantClass(NSString *mutantName, Class class1, ...) {
    // list of classes
    NSMutableSet *classes = [NSMutableSet set];
    va_list args;
    va_start(args, class1);
    for (Class arg = class1; arg != nil; arg = va_arg(args, Class)) {
        [classes addObject:arg];
    }
    va_end(args);

    return [[ClassFactory new] buildClass:mutantName withSuperclassNamed:NSStringFromClass(class1) usingBlock:^(ClassBuilder *builder) {
        // isKindOfClass:
        [builder addMethod:@selector(isKindOfClass:)
             withSignature:signature(@encode(BOOL), @encode(id), @encode(SEL), nil)
            implementation:imp_isKindOfClassesArray(classes)];
        
        // Copy all methods from all superclasses
        NSOrderedSet *superclasses = zts_allSuperclassesChain(classes.allObjects);
        for (Class class in superclasses) {
            zts_copyMethodsFrom(class, builder);
        }
        
        // Mutant protocol
        [builder addProtocol:@protocol(MutantClass)];
        
        [builder addClassMethod:@selector(isMutant)
                  withSignature:signature(@encode(BOOL), @encode(id), @encode(SEL), nil)
                          block:^{
            return YES;
        }];
        
        [builder addClassMethod:@selector(protoclasses)
                  withSignature:signature(@encode(NSSet *), @encode(id), @encode(SEL), nil)
                          block:^{
            return classes;
        }];
    }];
}

@implementation Lab

+ (Spiderpig)spiderpig {
    static Class SpiderpigClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SpiderpigClass = zts_mutantClass(@"Spiderpig", NSClassFromString(@"Spiderman"), [Pig class], nil);
        
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


@interface ClassBuilder ()
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *superclassName;
@property (nonatomic) Class rawClass;
@end


@implementation ClassFactory

- (Class)buildClass:(NSString *)className withSuperclassNamed:(NSString *)superclassName usingBlock:(void(^)(ClassBuilder *builder))block {
    ClassBuilder *builder = [[ClassBuilder alloc] init];
    builder.className = className;
    builder.superclassName = superclassName;
    Class result = objc_allocateClassPair([NSObject class], className.UTF8String, 0);
    builder.rawClass = result;
    block(builder);
    objc_registerClassPair(builder.rawClass);
    return builder.rawClass;
}

@end


@implementation ClassBuilder

@end


@implementation ClassBuilder (AddingMethods)

- (void)addMethod:(SEL)selector withSignature:(const char *)signature block:(id)block {
    [self addMethod:selector withSignature:signature implementation:imp_implementationWithBlock(block)];
}

- (void)addMethod:(SEL)selector withSignature:(const char *)signature implementation:(IMP)implementation {
    class_addMethod(self.rawClass, selector, implementation, signature);
}

- (void)addClassMethod:(SEL)selector withSignature:(const char *)signature block:(id)block {
    [self addClassMethod:selector withSignature:signature implementation:imp_implementationWithBlock(block)];
}

- (void)addClassMethod:(SEL)selector withSignature:(const char *)signature implementation:(IMP)implementation {
    class_addMethod(object_getClass(self.rawClass), selector, implementation, signature);
}

@end


@implementation ClassBuilder (CopyingMethods)

- (void)copyMethod:(SEL)selector fromClass:(Class)cls {
    Method method = class_getInstanceMethod(cls, selector);
    IMP implementation = method_getImplementation(method);
    const char *signature = method_getTypeEncoding(method);
    class_addMethod(self.rawClass, selector, implementation, signature);
}

- (void)copyClassMethod:(SEL)selector fromClass:(Class)cls {
    [self copyMethod:selector fromClass:object_getClass(cls)];
}

@end


@implementation ClassBuilder (Misc)

- (void)addProtocol:(Protocol *)protocol {
    class_addProtocol(self.rawClass, protocol);
}

@end
