//
//  LeaksInstrument.m
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "LeaksInstrument.h"

#import "LeaksInspector.h"
#import "_LeaksInspectorContext.h"
#import "LeaksSession.h"
#import "LeaksSession+Private.h"


static const NSPointerFunctionsOptions LeaksInstrumentOptions = NSPointerFunctionsWeakMemory | NSPointerFunctionsOpaquePersonality;


@interface LeaksInstrument ()
@property (nonatomic) LeaksInspector *inspector;
@property (nonatomic) NSMutableArray *storage;
@property (nonatomic) NSHashTable *cumulativeLeaks;
@end


@implementation LeaksInstrument

+ (instancetype)sharedInstrument {
    static LeaksInstrument *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LeaksInstrument alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.inspector = [LeaksInspector new];
    self.storage = [NSMutableArray array];
    self.cumulativeLeaks = [NSHashTable weakObjectsHashTable];
    return self;
}

#pragma mark - Public

- (void)measure {
    NSHashTable *currentRun = [self _instancesAliveFromMyBundleExcludingMyClasses];
    NSHashTable *previousRun = self.storage.lastObject;
    if (previousRun) {
        NSHashTable *delta = [currentRun copy];
        [delta minusHashTable:self.cumulativeLeaks];
        currentRun = delta;
    }
    LeaksSession *session = [LeaksSession new];
    session.leaks = currentRun;
    session.index = self.storage.count;
    
    for (id obj in session.leaks) [self.cumulativeLeaks addObject:obj];
    
    [self.storage addObject:session];
}

- (void)reset {
    [self.storage removeAllObjects];
}

#pragma mark - Properties

- (NSUInteger)count {
    return self.storage.count;
}

- (NSArray *)allSession {
    return [self.storage copy];
}

- (NSArray *)representativeSessions {
    if (self.storage.count > 2) {
        NSArray *result = [self.storage subarrayWithRange:NSMakeRange(1, self.storage.count - 2)];;
        return result;
    }
    return nil;
}

- (NSHashTable *)cumulativeLeaksFromRepresentativeSessions {
    NSHashTable *result = [[NSHashTable alloc] initWithOptions:LeaksInstrumentOptions capacity:0];
    for (LeaksSession *session in self.representativeSessions) {
        for (id obj in session.leaks) {
            [result addObject:obj];
        }
    }
    return result;
}

- (BOOL)hasLeaksInRepresentativeSession {
    for (LeaksSession *session in self.representativeSessions) {
        if (session.leaks.count) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Private

- (NSHashTable *)_instancesAliveFromMyBundleExcludingMyClasses {
    // our classes are still going to be around to measure stuff, ignore them
    static NSSet *blacklistedClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blacklistedClasses = [NSSet setWithObjects:
            [LeaksInstrument class], [LeaksSession class], [LeaksInspector class], [_LeaksInspectorContext class]
        , nil];
    });

    NSHashTable *result = [[NSHashTable alloc] initWithOptions:LeaksInstrumentOptions capacity:0];
    [self.inspector enumerateAllInstancesUsingBlock:^(__unsafe_unretained Class cls, void *instance, BOOL *stop) {
        if ([blacklistedClasses containsObject:cls]) {
            return;
        }
        // Only classes from our app.
        // TODO: will not work for frameworks?
        if ([[NSBundle bundleForClass:cls] isEqual:[NSBundle mainBundle]]) {
            [result addObject:(__bridge id)instance];
        }
    }];
    
    return result;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p {sessions=%@}>", [self class], self, [self.representativeSessions componentsJoinedByString:@"; "]];
}

@end
