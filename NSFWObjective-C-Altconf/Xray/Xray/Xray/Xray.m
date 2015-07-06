//
//  Xray.m
//  Objective Superman
//
//  Created by Sash Zats on 11/21/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "Xray.h"

#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>



@interface Xray : NSObject
@end

@implementation Xray

#pragma mark - Public

+ (void)xrayObject:(id)target forProperty:(NSString *)property options:(XrayOptions)options handler:(xray_handler_t)handler {
    if (![self _hasXrayedObject:target]) {
        [self _prepareObjectForXray:target];
    }
    
    // Defaults
    if (!options) {
        options = XrayOptionSetter;
    }
    if ((options & XrayOptionsDidAccess) != XrayOptionsDidAccess &&
        (options & XrayOptionsWillAccess) != XrayOptionsWillAccess) {
        options |= XrayOptionsDidAccess;
    }
    
    // Setup
    if (options & XrayOptionSetter) {
        [self _xraySetterForObject:target property:property options:options handler:handler];
    }
    
    if (options & XrayOptionGetter) {
        [self _xrayGetterForObject:target property:property options:options handler:handler];
    }
}

+ (void)stopXrayingObject:(id)object {
    // Was object under Xray?
    Class objectClass = object_getClass(object);
    NSString *objectClassName = NSStringFromClass(objectClass);
    if (![objectClassName hasPrefix:@"Xray_"]) {
        return;
    }
    
    // Original class
    NSString *originalClassName = [objectClassName substringFromIndex:@"Xray_".length];
    Class originalClass = NSClassFromString(originalClassName);

    // Restoring original class
    object_setClass(object, originalClass);
}

#pragma mark - Private

+ (BOOL)_hasXrayedObject:(id)target {
    return [NSStringFromClass(object_getClass(target)) hasPrefix:@"Xray_"];
}

+ (void)_prepareObjectForXray:(id)target {
    // Create a new class
    Class targetClass = object_getClass(target);
    NSString *xrayedClassName = [NSString stringWithFormat:@"Xray_%@", targetClass];
    Class xrayedClass = objc_allocateClassPair(targetClass, xrayedClassName.UTF8String, 0);

    // Override -[target class]
    SEL selector = @selector(class);
    Method method = class_getInstanceMethod(targetClass, selector);
    const char *methodSignature = method_getTypeEncoding(method);
    IMP implementation = imp_implementationWithBlock(^(id self){
        return targetClass;
    });
    class_addMethod(xrayedClass, selector, implementation, methodSignature);
    
    // Register the class with runtime
    objc_registerClassPair(xrayedClass);
    // and set target's isa to point to our dynamic subclass
    object_setClass(target, xrayedClass);
}

+ (void)_xraySetterForObject:(id)object property:(NSString *)property options:(XrayOptions)options handler:(xray_handler_t)handler {
    Class xrayedClass = object_getClass(object);

    // Conventionally, setter for "property" is a "setProperty:",
    // TODO: but we also can read a 'S' (setter) attribute
    NSString *setterSelectorName = [NSString stringWithFormat:@"set%@%@:", [[property substringToIndex:1] capitalizedString], [property substringFromIndex:1]];
    SEL setterSelector = NSSelectorFromString(setterSelectorName);
    
    // Original setter and all meta information about it
    Method setterMethod = class_getInstanceMethod(xrayedClass, setterSelector);
    const char *setterSignature = method_getTypeEncoding(setterMethod);
    IMP setterIMP = method_getImplementation(setterMethod);
    
    // Create a new implementation of a setter
    __weak id weakObject = object;
    IMP newSetterIMP = imp_implementationWithBlock(^(id self, id value){
        id object = weakObject;
        // cast a function type on original IMP
        if ((options & XrayOptionsWillAccess) == XrayOptionsWillAccess) {
            handler(object, property, value, XrayAccessTimeWill);
        }
        ((void(*)(id, SEL, id))setterIMP)(object, setterSelector, value);
        if ((options & XrayOptionsDidAccess) == XrayOptionsDidAccess) {
            handler(object, property, value, XrayAccessTimeDid);
        }
    });

    // Attach new implementation to our dynamic subclass
    BOOL didAddMethod = class_addMethod(xrayedClass, setterSelector, newSetterIMP, setterSignature);
    if (!didAddMethod) {
        method_setImplementation(setterMethod, newSetterIMP);
    }
}

+ (void)_xrayGetterForObject:(id)object property:(NSString *)property options:(XrayOptions)options handler:(xray_handler_t)handler {
    Class originalClass = [object class];
    Class xrayedClass = object_getClass(object);
    
    // Getter name
    // Checking if custom getter was specified, i.e.
    // @property (nonatomic, getter=isHidden) BOOL hidden;
    objc_property_t objcProperty = class_getProperty(originalClass, [property cStringUsingEncoding:NSUTF8StringEncoding]);
    char *getterName = property_copyAttributeValue(objcProperty, "G");
    NSString *getterSelectorName = property;
    if (getterName) {
        getterSelectorName = [NSString stringWithCString:getterName encoding:NSUTF8StringEncoding];
        free(getterName);
    }
    SEL getterSelector = NSSelectorFromString(getterSelectorName);

    // Original getter
    Method getterMethod = class_getInstanceMethod(xrayedClass, getterSelector);
    const char *getterSignature = method_getTypeEncoding(getterMethod);
    IMP getterIMP = method_getImplementation(getterMethod);
    
    // Creating a new implementation
    __weak id weakObject = object;
    IMP newGetterIMP = imp_implementationWithBlock(^id(id self){
        id object = weakObject;
        // cast a function type on original IMP
        if ((options & XrayOptionsWillAccess) == XrayOptionsWillAccess) {
            handler(object, property, nil, XrayAccessTimeWill);
        }
        id result = ((id(*)(id, SEL))getterIMP)(self, getterSelector);
        if ((options & XrayOptionsDidAccess) == XrayOptionsDidAccess) {
            handler(object, property, result, XrayAccessTimeDid);
        }
        return result;
    });
    
    // Attach new implementation to our dynamic subclass
    BOOL didAddMethod = class_addMethod(xrayedClass, getterSelector, newGetterIMP, getterSignature);
    if (!didAddMethod) {
        method_setImplementation(getterMethod, newGetterIMP);
    }
}

@end

@implementation NSObject (Xray)

- (void)xrayProperty:(NSString *)property withOptions:(XrayOptions)options handler:(xray_handler_t)handler {
    [Xray xrayObject:self forProperty:property options:options handler:handler];
}

- (void)stopXraying {
    [Xray stopXrayingObject:self];
}

@end
