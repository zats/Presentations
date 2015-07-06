//
//  BinaryHeap.m
//  TollFreeBridging
//
//  Created by Sash Zats on 2/11/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BinaryHeap.h"


@interface Box : NSObject
+ (instancetype)boxWithData:(NSNumber *)data;
@property (nonatomic) NSNumber *data;
@end


static CFComparisonResult TestComparison(const void *ptr1, const void *ptr2, void *context) {
    switch ([((__bridge Box *)ptr1).data compare:((__bridge Box *)ptr2).data]) {
        case NSOrderedSame:
            return kCFCompareEqualTo;
        case NSOrderedAscending:
            return kCFCompareLessThan;
        case NSOrderedDescending:
            return kCFCompareGreaterThan;
    }
}
static const void *TestRetain(CFAllocatorRef allocator, const void *ptr) {
    return ptr;
}
const void *TestCompareRetain(const void *info) {
    return info;
}
void TestRelease(CFAllocatorRef allocator, const void *ptr) {
}
void TestCompareRelease(const void *ptr) {
}


@implementation Box
+ (instancetype)boxWithData:(id)data {
    Box *instance = [Box new];
    instance.data = data;
    return instance;
}
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Box class]]) {
        return [self.data isEqual:((Box *)object).data];
    }
    return [super isEqual:object];
}
- (NSUInteger)hash {
    return [self.data hash];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p {data=%@}>", [self class], self, self.data];
}
@end


@interface BinaryHeapTests : XCTestCase
@property (nonatomic) CFBinaryHeapRef cfHeap;
@property (nonatomic) BinaryHeap *heap;
@end


@implementation BinaryHeapTests

- (void)setUp {
    [super setUp];

    self.heap = [[BinaryHeap alloc] initWithComparator:^NSComparisonResult(Box *obj1, Box *obj2) {
        return [obj1.data compare:obj2.data];
    }];
    
    CFBinaryHeapCallBacks callBacks;
    callBacks.compare = TestComparison;
    callBacks.retain = TestRetain;
    callBacks.release = TestRelease;
    CFBinaryHeapCompareContext compareContext;
    compareContext.release = TestCompareRelease;
    compareContext.retain = TestCompareRetain;
    CFBinaryHeapRef heap = CFBinaryHeapCreate(kCFAllocatorDefault, 0, &callBacks, &compareContext);
    
    CFBinaryHeapAddValue(heap, (__bridge void *)[Box boxWithData:@10]);
    CFBinaryHeapAddValue(heap, (__bridge void *)[Box boxWithData:@20]);
    CFBinaryHeapAddValue(heap, (__bridge void *)[Box boxWithData:@30]);
    self.cfHeap = heap;
    
    self.heap = [BinaryHeap heapWithComparator:^NSComparisonResult(Box *obj1, Box *obj2) {
        return [obj1.data compare:obj2.data];
    }];
    [self.heap addObject:[Box boxWithData:@10]];
    [self.heap addObject:[Box boxWithData:@20]];
    [self.heap addObject:[Box boxWithData:@30]];
}

- (void)testAddingObjectsUpdatesCount {
    Box *minusTwo = [Box boxWithData:@-2];

    [self.heap addObject:minusTwo];
    XCTAssertEqual(self.heap.count, 4);
}

- (void)testAdddingObjectsInCorrectOrder {
    Box *minusTwo = [Box boxWithData:@-2];

    [self.heap addObject:minusTwo];
    XCTAssertEqualObjects(self.heap.peek, minusTwo);
}

- (void)testRemovingMinimumObject {
    Box *minusTwo = [Box boxWithData:@-2];
    Box *ten = [Box boxWithData:@10];

    [self.heap addObject:minusTwo];
    [self.heap removeMinimumObject];
    XCTAssertEqual(self.heap.count, 3);
    XCTAssertEqualObjects(self.heap.peek, ten);
}

- (void)testRemoveAllObjects {
    [self.heap removeAllObjects];
    XCTAssertEqual(self.heap.count, 0);
    XCTAssertFalse([self.heap containsObject:[Box boxWithData:@10]]);
    XCTAssertFalse([self.heap containsObject:[Box boxWithData:@20]]);
    XCTAssertFalse([self.heap containsObject:[Box boxWithData:@30]]);
}

- (void)_testRemovingMinimumObjectReleasesIt {
    XCTestExpectation *releaseExpectation = [self expectationWithDescription:@"instance released"];
    __weak id minimum = self.heap.peek;
    [self.heap removeMinimumObject];

    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertNil(minimum);
        [releaseExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testCountBridging {
    NSUInteger cfCount = CFBinaryHeapGetCount((__bridge CFBinaryHeapRef)self.heap);
    NSUInteger objcCount = [(BinaryHeap *)self.cfHeap count];
    XCTAssertEqual(cfCount, objcCount);
}

- (void)testCountOfValueBridging {
    Box *ten = [Box boxWithData:@10];
    Box *minusTen = [Box boxWithData:@-10];

    XCTAssertEqual(CFBinaryHeapGetCountOfValue((__bridge CFBinaryHeapRef)self.heap, (__bridge void *)ten),
                   [(BinaryHeap *)self.cfHeap countForObject:ten]);

    XCTAssertEqual(CFBinaryHeapGetCountOfValue((__bridge CFBinaryHeapRef)self.heap, (__bridge void *)minusTen),
                   [(BinaryHeap *)self.cfHeap countForObject:minusTen]);
}

- (void)testContainsValueBridging {
    Box *ten = [Box boxWithData:@10];
    Box *minusTen = [Box boxWithData:@-10];

    XCTAssertEqual(CFBinaryHeapContainsValue((__bridge CFBinaryHeapRef)self.heap, (__bridge void *)ten),
                   [(BinaryHeap *)self.cfHeap containsObject:ten]);

    XCTAssertEqual(CFBinaryHeapContainsValue((__bridge CFBinaryHeapRef)self.heap, (__bridge void *)minusTen),
                   [(BinaryHeap *)self.cfHeap containsObject:minusTen]);
}

- (void)testGetMinimumBridging {
    XCTAssertEqualObjects((__bridge id)CFBinaryHeapGetMinimum((__bridge CFBinaryHeapRef)self.heap),
                          ((BinaryHeap *)self.cfHeap).peek);
    
}

- (void)testAddValueBridging {
    Box *newMinimum = [Box boxWithData:@-100];
    CFBinaryHeapAddValue((__bridge CFBinaryHeapRef)self.heap, (__bridge void *)newMinimum);
    [(BinaryHeap *)self.cfHeap addObject:newMinimum];
    XCTAssertEqualObjects(self.heap.peek, newMinimum);
    XCTAssertTrue(CFEqual(CFBinaryHeapGetMinimum(self.cfHeap), (__bridge void *)newMinimum));
}

- (void)testRemoveMinimumBridging {
    Box *twenty = [Box boxWithData:@20];
    CFBinaryHeapRemoveMinimumValue((__bridge CFBinaryHeapRef)self.heap);
    [(BinaryHeap *)self.cfHeap removeMinimumObject];
    XCTAssertEqualObjects(self.heap.peek, twenty);
    XCTAssertTrue(CFEqual(CFBinaryHeapGetMinimum(self.cfHeap), (__bridge void *)twenty));
}

- (void)testRemoveAllValuesBridging {
    CFBinaryHeapRemoveAllValues((__bridge CFBinaryHeapRef)self.heap);
    [(BinaryHeap *)self.cfHeap removeAllObjects];
    XCTAssertEqual(self.heap.count, 0);
    XCTAssertEqual(CFBinaryHeapGetCount(self.cfHeap), 0);
}

@end
