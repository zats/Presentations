//
//  Lab.h
//  Run, time, run!
//
//  Created by Sash Zats on 11/15/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Pig.h"
#import "SpiderPig.h"
#import "Spiderman.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface Lab : NSObject

+ (Spiderman)spiderman;

+ (Spiderpig)spiderpig;

+ (Pig *)pig;

@end


@protocol MutantClass <NSObject>

@required

+ (BOOL)isMutant;

+ (NSSet *)protoclasses;

@end


@class ClassBuilder;
@interface ClassFactory : NSObject

- (Class)buildClass:(NSString *)className withSuperclassNamed:(NSString *)superclassName usingBlock:(void(^)(ClassBuilder *builder))block;

@end


@interface ClassBuilder : NSObject

@property (nonatomic, copy, readonly) NSString *className;

@property (nonatomic, copy, readonly) NSString *superclassName;

@property (nonatomic, readonly) Class rawClass;

@end


@interface ClassBuilder (AddingMethods)

- (void)addMethod:(SEL)method withSignature:(const char *)signature block:(id)block;

- (void)addMethod:(SEL)method withSignature:(const char *)signature implementation:(IMP)implementation;

- (void)addClassMethod:(SEL)classMethod withSignature:(const char *)signature block:(id)block;

- (void)addClassMethod:(SEL)classMethod withSignature:(const char *)signature implementation:(IMP)implementation;

@end


@interface ClassBuilder (Misc)

- (void)addProtocol:(Protocol *)protocol;

@end


@interface ClassBuilder (CopyingMethods)

- (void)copyMethod:(SEL)selector fromClass:(Class)cls;

- (void)copyClassMethod:(SEL)selector fromClass:(Class)cls;

@end
