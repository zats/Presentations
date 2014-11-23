//
//  ViewController.m
//  Frankenstein
//
//  Created by Sash Zats on 11/23/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "ViewController.h"

#import "Lab.h"

#import "Pig.h"
#import "SpiderPig.h"
#import "Spiderman.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    Pig *pig = [Lab pig];
    NSLog(@"%@ says...", [pig class]);
    [pig pullTail];
    NSLog(@"\n");

    Spiderman spiderman = [Lab spiderman];
    NSLog(@"%@ shoots web...", [spiderman class]);
    [spiderman shootWeb];
    NSLog(@"%@'s add power with responsibility...", [spiderman class]);
    [spiderman addPower:NSUIntegerMax withResponsibilty:NSUIntegerMax];
    NSLog(@"\n");

    Spiderpig spiderpig = [Lab spiderpig];
    NSLog(@"%@ shoots web...", [spiderpig class]);
    [spiderpig shootWeb];
    NSLog(@"%@'s add power with responsibility...", [spiderpig class]);
    [spiderpig addPower:NSUIntegerMax withResponsibilty:NSUIntegerMax];
    NSLog(@"%@ says...", [spiderpig class]);
    [spiderpig pullTail];
    NSLog(@"\n");
    
    NSLog(@"Is Spiderpig a Spiderman? %@", [spiderpig isKindOfClass:[spiderman class]] ? @"Yes" : @"No");
    NSLog(@"Is Spiderpig a Pig? %@", [spiderpig isKindOfClass:[pig class]] ? @"Yes" : @"No");
    NSLog(@"Is Spiderman a Pig? %@", [spiderman isKindOfClass:[pig class]] ? @"Yes" : @"No");
}

@end
