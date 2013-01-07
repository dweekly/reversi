//
//  WelcomeViewController.m
//  isreveR
//
//  Created by David E. Weekly on 1/6/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newGame:(id)sender {
    // the user wants to play a new game, take them to the opponent selection screen.
    _app.opponentViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:_app.opponentViewController animated:YES completion:NULL];
}

// The user wishes to provide feedback
- (IBAction)feedback:(id)sender {
    [TestFlight openFeedbackView];
}

// Show the About view.
- (IBAction)about:(id)sender {
    // Show the About view.
    _app.aboutViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:_app.aboutViewController animated:YES completion:NULL];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}


@end
