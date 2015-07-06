//
//  ViewController.m
//  TollFreeBridging
//
//  Created by Sash Zats on 2/7/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "ViewController.h"

#import "BinaryHeap.h"

static NSComparisonResult ReverseComparisonResult(NSComparisonResult result) {
    switch (result) {
        case NSOrderedDescending:
            return NSOrderedAscending;
        case NSOrderedAscending:
            return NSOrderedDescending;
        case NSOrderedSame:
            return NSOrderedSame;
    }
}


static CFComparisonResult TFBMaximumHeapComparison(const void *ptr1, const void *ptr2, void *context) {
    switch ([(__bridge NSNumber *)ptr1 compare:(__bridge NSNumber *)ptr2]) {
        case NSOrderedSame:
            return kCFCompareEqualTo;
        case NSOrderedAscending:
            return kCFCompareGreaterThan;
        case NSOrderedDescending:
            return kCFCompareLessThan;
    }
}

static const void *TFBRetain(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void TFBRelease(CFAllocatorRef allocator, const void *value) {
    // no-op
}


@interface ViewController ()
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // OEIS: A104101
    NSArray *numbers = @[@4, @8, @15, @16, @23, @42];
    

    // CF
    CFBinaryHeapCallBacks binaryHeapCallBacks = (CFBinaryHeapCallBacks){
        .compare = TFBMaximumHeapComparison,
        .retain = TFBRetain,
        .release = TFBRelease
    };
    
    CFBinaryHeapRef cfHeap = CFBinaryHeapCreate(kCFAllocatorDefault, 6, &binaryHeapCallBacks, NULL);
    for (NSNumber *number in numbers) {
        CFBinaryHeapAddValue(cfHeap, (__bridge const void *)number);
    }
    NSLog(@"CFBinaryHeapGetMinimum: %@", CFBinaryHeapGetMinimum(cfHeap));

    
    // Objective-C
    BinaryHeap *heap = [BinaryHeap maximumHeap];
    for (NSNumber *number in numbers) {
        [heap addObject:number];
    }
    NSLog(@"-[BinaryHeap peek]: %@", heap.peek);

    
}

@end
