//
//  ViewController.m
//  Lab
//
//  Created by Sash Zats on 5/30/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "ViewController.h"
#import "Lab.h"


@interface ViewController ()

@property (nonatomic) Pig *pig;
@property (nonatomic) Spiderman spiderman;
@property (nonatomic) Spiderpig spiderpig;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
    
    
    self.pig = [Lab pig];
    [self.pig pullTail];
    NSLog(@"\n");
    
    
    
    
    
    
    
    self.spiderman = [Lab spiderman];
    [self.spiderman shootWeb];
    [self.spiderman addPower:NSUIntegerMax withResponsibilty:NSUIntegerMax];
    NSLog(@"\n");
    
    
    
    
    
    
    
    
    self.spiderpig = [Lab spiderpig];
    [self.spiderpig shootWeb];
    [self.spiderpig addPower:NSUIntegerMax withResponsibilty:NSUIntegerMax];
    [self.spiderpig pullTail];
    NSLog(@"\n");
    
    NSLog(@"Is Spiderpig a Spiderman? %@",
          [self.spiderpig isKindOfClass:[self.spiderman class]] ? @"Yes" : @"No");

    NSLog(@"Is Spiderpig a Pig? %@",
          [self.spiderpig isKindOfClass:[self.pig class]] ? @"Yes" : @"No");
    
    NSLog(@"Is Spiderman a Pig? %@",
          [self.spiderman isKindOfClass:[self.pig class]] ? @"Yes" : @"No");
}

@end
