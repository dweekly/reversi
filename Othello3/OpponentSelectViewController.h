//
//  OpponentSelectViewController.h
//  isreveR
//
//  Created by David E. Weekly on 1/7/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <StoreKit/StoreKit.h>

#import "AppDelegate.h"
#import "OthelloGameController.h"

@class AppDelegate;

@interface OpponentSelectViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    bool paymentInProgress;
}

@property (readwrite) AppDelegate *app;
@property (weak, nonatomic) IBOutlet UIButton *playHardComputerButton;

- (IBAction)playEasyComputer:(id)sender;
- (IBAction)playMediumComputer:(id)sender;
- (IBAction)playHardComputer:(id)sender;

- (IBAction)backToMenu:(id)sender;

@end
