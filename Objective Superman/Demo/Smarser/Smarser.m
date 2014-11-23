//
//  Smarser.m
//  Objective Superman
//
//  Created by Sash Zats on 11/22/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Smarser.h"

#import <objc/runtime.h>

@implementation Smarser

+ (id)objectOfKind:(Class)superclass withDictionary:(NSDictionary *)dictionary {
    NSSet *possibleClasses = [self _subclassesOfClass:superclass];
    for (Class class in possibleClasses) {
        if ([self _isClass:class matchingDictionary:dictionary]) {
            return [self _instanceOfClass:class withDictionary:dictionary];
        }
    }
    return nil;
}

#pragma mark - Private

+ (NSSet *)_subclassesOfClass:(Class)superclass {
    NSMutableSet *results = [NSMutableSet set];
    unsigned int classesCount;
    Class *classList = objc_copyClassList(&classesCount);
    // Find all classes that have specified superclass
    for (unsigned int i = 0; i < classesCount; ++i) {
        Class class = classList[i];
        if (class_getSuperclass(class) == superclass) {
            [results addObject:class];
        }
    }
    free(classList);
    return [results copy];
}

+ (BOOL)_isClass:(Class)class matchingDictionary:(NSDictionary *)dictionary {
    NSDictionary *objectPropertiesMap = [self _classPropertiesMap:class];
    __block BOOL isMatching = YES;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
        if (!objectPropertiesMap[property]) {
            isMatching = NO;
            *stop = YES;
            return;
        }
        NSString *expectedType = objectPropertiesMap[property];
        if (![self _value:value fitsPropertyOfType:expectedType]) {
            isMatching = NO;
            *stop = YES;
            return;
        }
    }];
    return isMatching;
}

+ (id)_instanceOfClass:(Class)class withDictionary:(NSDictionary *)dictionary {
    id instance = [[class alloc] init];
    [dictionary  enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [instance setValue:obj forKey:key];
    }];
    return instance;
}

+ (NSDictionary *)_classPropertiesMap:(Class)class {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    unsigned int propertiesCount;
    objc_property_t *propertyList = class_copyPropertyList(class, &propertiesCount);
    for (unsigned int i = 0; i < propertiesCount; ++i) {
        objc_property_t property = propertyList[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *type = [NSString stringWithCString:property_copyAttributeValue(property, "T") encoding:NSUTF8StringEncoding];
        properties[name] = type;
    }
    Class superclass = class_getSuperclass(class);
    if (superclass != [NSObject class]) {
        NSDictionary *superclassProperties = [self _classPropertiesMap:superclass];
        [properties addEntriesFromDictionary:superclassProperties];
    }
    return properties;
}

+ (BOOL)_value:(id)value fitsPropertyOfType:(NSString *)type {
    // BOOL
    if (value == (__bridge id)kCFBooleanFalse || value == (__bridge id)kCFBooleanTrue) {
        return [type isEqualToString:@"B"];
    }
    
    if (![type hasPrefix:@"@"]) {
        // Unknown type
        return NO;
    }
    
    // Any object
    type = [type stringByReplacingOccurrencesOfString:@"@\"(.+)\""
                                           withString:@"$1"
                                              options:NSRegularExpressionSearch
                                                range:NSMakeRange(0, type.length)];
    Class typeClass = NSClassFromString(type);
    return [value isKindOfClass:typeClass];
}

@end
