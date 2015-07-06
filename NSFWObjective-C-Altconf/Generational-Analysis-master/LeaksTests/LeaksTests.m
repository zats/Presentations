//
//  LeaksTests.m
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "RootViewController.h"
#import "LeaksInstrument.h"


@interface LeaksTests : XCTestCase
@property (nonatomic) LeaksInstrument *leaksInstrument;
@end


@implementation LeaksTests

- (void)setUp {
    [super setUp];
    self.leaksInstrument = [[LeaksInstrument alloc] init];
}

- (void)testPassingNotLeakingExample {
    XCTestExpectation *leaksExpectation = [self expectationWithDescription:@"No leaks detected"];
    
    [self _pushPopLeakingViewController:NO nTimes:4 progressHandler:^{
        [self.leaksInstrument measure];
    } completionHandler:^{
        XCTAssertFalse(self.leaksInstrument.hasLeaksInRepresentativeSession, @"%@", self.leaksInstrument.representativeSessions);
        [leaksExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testFailingLeakingExample {
    XCTestExpectation *leaksExpectation = [self expectationWithDescription:@"No leaks detected"];
    
    [self _pushPopLeakingViewController:YES nTimes:4 progressHandler:^{
        [self.leaksInstrument measure];
    } completionHandler:^{
        XCTAssertFalse(self.leaksInstrument.hasLeaksInRepresentativeSession, @"%@", self.leaksInstrument.representativeSessions);
        [leaksExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)tearDown {
    // to make sure we are not holding leaked instances from the previous test.
    // Not that it matter if you use -[LeaksInstrument representativeSessions]
    self.leaksInstrument = nil;
    [super tearDown];
}

#pragma mark - Private

- (void)_pushPopLeakingViewController:(BOOL)isLeaking nTimes:(NSUInteger)nTimes progressHandler:(void(^)(void))progress completionHandler:(void(^)(void))completion {
    if (!nTimes) {
        completion();
        return;
    }

    [self _pushPopLeakingViewController:isLeaking withCompletionHandler:^{
        if (nTimes > 0) {
            progress();
        }
        [self _pushPopLeakingViewController:isLeaking nTimes:nTimes-1 progressHandler:progress completionHandler:completion];
    }];
}

- (void)_pushPopLeakingViewController:(BOOL)isLeaking withCompletionHandler:(void(^)(void))handler {
    UINavigationController *navigationController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    RootViewController *rootViewController = navigationController.viewControllers.firstObject;
    if (isLeaking) {
        [rootViewController pushLeakingViewController];
    } else {
        [rootViewController pushNotLeakingViewController];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [rootViewController.navigationController popToViewController:rootViewController animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            handler();
        });
    });
}

@end
