//
//  GameViewController.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "OthelloBoardView.h"

@class OthelloBoardView;

@interface GameViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (IBAction)feedback:(id)sender;
- (IBAction)upgrade:(id)sender;
- (IBAction)infoClick:(id)sender;

@property (weak, nonatomic) IBOutlet OthelloBoardView *othelloBoard;
@property (strong, nonatomic) IBOutlet UIPickerView *aiPicker;
@property (weak, nonatomic) IBOutlet UILabel *aiLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameStatus;

@end
