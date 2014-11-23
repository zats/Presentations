//
//  ViewController.m
//  Smarser
//
//  Created by Sash Zats on 11/22/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "ViewController.h"

#import "Smarser.h"
#import "Spiderman.h"
#import "Superman.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *heroesJSON = [self _loadJSON];

    NSMutableArray *heroes = [NSMutableArray arrayWithCapacity:heroesJSON.count];
    for (NSDictionary *json in heroesJSON) {        
        id instance = [Smarser objectOfKind:[Hero class] withDictionary:json];
        if (instance) {
            [heroes addObject:instance];
        }
    }
    NSLog(@"%@", heroes);
}

#pragma mark - Private

- (NSArray *)_loadJSON {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"heroes" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

@end
