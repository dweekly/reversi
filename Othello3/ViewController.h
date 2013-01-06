//
//  ViewController.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "OthelloBoardView.h"

@class OthelloBoardView;

@interface ViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver, GKTurnBasedMatchmakerViewControllerDelegate>
{
    GKTurnBasedMatch *_match;
}

- (IBAction)feedback:(id)sender;
- (IBAction)upgrade:(id)sender;
- (IBAction)infoClick:(id)sender;
- (IBAction)playHuman:(id)sender;

@property (weak, nonatomic) IBOutlet OthelloBoardView *othelloBoard;
@property (weak, nonatomic) IBOutlet UILabel *opponentLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
