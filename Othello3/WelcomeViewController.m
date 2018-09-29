//
//  WelcomeViewController.m
//  isreveR
//
//  Created by David E. Weekly on 1/6/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import "WelcomeViewController.h"
@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)newGame:(id)sender {
    // the user wants to play a new game, take them to the opponent selection screen.
    _app.opponentViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:_app.opponentViewController animated:YES completion:NULL];
}

// The user wishes to provide feedback
- (IBAction)feedback:(id)sender {
#ifdef TESTFLIGHT
    [TestFlight openFeedbackView];
#endif
}

// Show the About view.
- (IBAction)about:(id)sender {
    // Show the About view.
    _app.aboutViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:_app.aboutViewController animated:YES completion:NULL];
}

@end
