//
//  ViewController.m
//  Xray
//
//  Created by Sash Zats on 5/30/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "ViewController.h"

#import "Vault.h"
#import "Xray.h"
#import "BadGuy.h"


@interface NSThread (Xray)
@property (nonatomic, copy, readonly) NSString *calee;
@end



@interface ViewController ()
@property (nonatomic, strong) Vault *vault;
@end


@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.vault = [Vault mainVault];
    [self.vault startVault];

    [self.vault xrayProperty:@"code" withOptions:XrayOptionSetter handler:^(id target, NSString *property, NSString *code, XrayAccessTime accessTime) {
        printf("%s: Vault.code = %s\n", [NSThread currentThread].calee.UTF8String, [code stringByReplacingOccurrencesOfString:@"." withString:@"*" options:NSRegularExpressionSearch range:NSMakeRange(0, code.length)].UTF8String);
    }];
    
    [self.vault xrayProperty:@"code" withOptions:XrayOptionGetter | XrayOptionsWillAccess | XrayOptionsDidAccess handler:^(id target, NSString *property, id object, XrayAccessTime accessTime) {
        printf("%s%s %s access the Vault.code%s\n", accessTime == XrayAccessTimeWill ? "\n" : "", [NSThread currentThread].calee.UTF8String, accessTime == XrayAccessTimeWill ? "will" : "did", accessTime == XrayAccessTimeWill ? "" : "\n");
    }];
    
    [self.vault xrayProperty:@"contents" withOptions:XrayOptionGetter handler:^(id target, NSString *property, id contents, XrayAccessTime accessTime) {
        printf("%s %s access Vault.content\n\n", [NSThread currentThread].calee.UTF8String, accessTime == XrayAccessTimeWill ? "will" : "did");
    }];
}

#pragma mark - Actions

- (IBAction)_badGuyButtonAction:(id)sender {
    [UIView animateWithDuration:0.33 animations:^{
        self.view.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [[BadGuy theBadGuy] startPickingLock];
    }];
}

@end


@implementation NSThread (Xray)

- (NSString *)calee {
    NSString *symbol = [NSThread callStackSymbols][3];
    symbol = [symbol stringByReplacingOccurrencesOfString:@"\\s+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, symbol.length)];
    NSArray *components = [symbol componentsSeparatedByString:@" "];
    BOOL isClassMethod = [[components[3] substringToIndex:1] isEqualToString:@"+"];
    NSString *className = [components[3] substringFromIndex:2];
    NSString *methodName = components[4];
    methodName = [methodName substringToIndex:methodName.length - 1];
    return [NSString stringWithFormat:@"%@[%@ %@]", isClassMethod ? @"+" : @"-", className, methodName];
}

@end
