//
//  WelcomeViewController.h
//  isreveR
//
//  Created by David E. Weekly on 1/6/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

@class AppDelegate;

@interface WelcomeViewController : UIViewController

@property (readwrite) AppDelegate *app;

- (IBAction)feedback:(id)sender;
- (IBAction)about:(id)sender;
- (IBAction)newGame:(id)sender;

@end
