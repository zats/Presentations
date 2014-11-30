//
//  ViewController.m
//  Smarser
//
//  Created by Sash Zats on 11/22/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

#import "SmarserViewController.h"

#import "Smarser.h"
#import "Spiderman.h"
#import "Superman.h"

@interface SmarserViewController ()

@end

@implementation SmarserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *heroes = [NSMutableArray array];
    for (NSDictionary *json in [self _JSON]) {
        id instance = [Smarser objectOfKind:[Hero class] withDictionary:json];
        if (instance) {
            [heroes addObject:instance];
        }
    }

    [heroes removeAllObjects];
    
    for (NSDictionary *json in [self _corruptedJSON]) {
        id instance = [Smarser objectOfKind:[Hero class] withDictionary:json];
        if (instance) {
            [heroes addObject:instance];
        }
    }
}

#pragma mark - Private

- (NSArray *)_JSON {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"heroes" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (NSArray *)_corruptedJSON {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"heroes-corrupted" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

@end
