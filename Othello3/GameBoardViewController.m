//
//  ViewController.m
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "GameBoardViewController.h"

@interface GameBoardViewController ()

@end

@implementation GameBoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.statusLabel setText:@"Your turn!"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// the user has resigned the match.
- (IBAction)resign:(id)sender {
    // TODO: send "mark game as lost" to gamecenter or to AI game score / count as applicable
    // TODO: clear board / state
    CLS_LOG(@"User resigned match");
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)viewDidUnload {
    [self setOpponentLabel:nil];
    [self setStatusLabel:nil];
    [super viewDidUnload];
}
@end
