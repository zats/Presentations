//
//  Xray.h
//  Objective Superman
//
//  Created by Sash Zats on 11/21/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^xray_handler_t)(id target, NSString *property, id object);

typedef NS_OPTIONS(NSInteger, XrayOptions) {
    XrayOptionSetter = 1 << 0,
    XrayOptionGetter = 1 << 1
};

@interface NSObject (Xray)

- (void)xrayProperty:(NSString *)property withOptions:(XrayOptions)options handler:(xray_handler_t)handler;

- (void)stopXraying;

@end