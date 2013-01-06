//
//  main.m
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"


void uncaughtExceptionHandler(NSException *exception) {
    CLS_LOG(@"Uncaught Exception!! %@", exception);
    CLS_LOG(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

int main(int argc, char *argv[])
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
