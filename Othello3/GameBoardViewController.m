//
//  ViewController.m
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "GameBoardViewController.h"
@implementation GameBoardViewController

// the user has resigned the match.
- (IBAction)resign:(id)sender {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.game resign];
}

@end
