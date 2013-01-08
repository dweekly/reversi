//
//  ViewController.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "AppDelegate.h"
#import "OthelloBoardView.h"

@class OthelloBoardView;

@interface GameBoardViewController : UIViewController
{
    GKTurnBasedMatch *_match;
}

- (IBAction)resign:(id)sender;

@property (weak, nonatomic) IBOutlet OthelloBoardView *othelloBoard;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *whiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *blackLabel;


@end
