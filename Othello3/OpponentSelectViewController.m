//
//  OpponentSelectViewController.m
//  isreveR
//
//  Created by David E. Weekly on 1/7/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import "OpponentSelectViewController.h"

@implementation OpponentSelectViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    paymentInProgress = false;
    
    // The user hasn't paid to unlock Hard level yet, show text in green
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]){
        [self.playHardComputerButton setTitleColor:[UIColor colorWithRed:0.1 green:0.6 blue:0.1 alpha:1.0] forState:UIControlStateNormal];
    }
}


- (void)startComputerGameWithAI:(AIType)ai
{
    if(paymentInProgress){
         // TODO: provide feedback as to why we're ignoring their game start request (show spinner?)
        return;
    }
    _app.game->userSide = kOthelloWhite; // let the user go first.
    [_app.gameBoardViewController view]; // force view to load
    [_app.game newGameVersusAI:ai];
    _app.gameBoardViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:_app.gameBoardViewController animated:YES completion:NULL];
}

- (IBAction)playEasyComputer:(id)sender {
    [self startComputerGameWithAI:kAISimpleGreedy];
}

- (IBAction)playMediumComputer:(id)sender {
    [self startComputerGameWithAI:kAISimpleHeuristic];
}

- (IBAction)playHardComputer:(id)sender {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]){
        [self startComputerGameWithAI:kAIMinimax];
    } else {
        if(paymentInProgress){
            // show spinner?
        } else {
            paymentInProgress = true;
            // TODO: auto-attempt restore if that hasn't been done yet?
            [self upgrade];
        }
    }
}

- (IBAction)backToMenu:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}



////////////////// PAYMENTS / UPGRADING CODE BELOW /////////////////////


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                // show wait view here
                break;
            }
                
            case SKPaymentTransactionStatePurchased: {
                
                // unlock is in transaction.payment.productIdentifier
                assert([transaction.payment.productIdentifier isEqualToString:@"com.gastonlabs.isreveR.AI_Minimax"]);
                                
                // Save the fact that the advanced AI is now unlocked.
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"AI_Minimax"];

                // mark the transaction completed.
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                paymentInProgress = false;

                //[Flurry logEvent:@"Minimax IAP Complete"];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AI Unlocked" message:@"You have unlocked the more sophisticated AI!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                     {
                                         NSLog(@"AI Upgraded.");
                                         [self startComputerGameWithAI:kAIMinimax];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                
                break;
            }
                
            case SKPaymentTransactionStateRestored: {
                // unlock is in transaction.originalTransaction.payment.productIdentifier
                assert([transaction.originalTransaction.payment.productIdentifier isEqualToString:@"com.gastonlabs.isreveR.AI_Minimax"]);

                //[Flurry logEvent:@"Minimax IAP Restore"];

                paymentInProgress = false;
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"AI_Minimax"];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self startComputerGameWithAI:kAIMinimax];

                break;
            }
                
            case SKPaymentTransactionStateFailed: {
                if(transaction.error.code == SKErrorPaymentCancelled){
                    //[Flurry logEvent:@"Minimax IAP Cancel"];
                } else {
                    //[Flurry logEvent:@"Minimax IAP Error"];
                    
                    // only bother the user with an error popup if an upgrade hasn't yet gone through.
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]){
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Purchase Error" message:@"Thre was an error with your purchase, apologies." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                             {
                                             }];
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                    }

                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                // remove wait view here?
                paymentInProgress = false;
                break;
            }
                
            default: {
                break;
            }
        }
    }
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // ensure we got back exactly one product back.
    NSUInteger count = [response.products count];
    if (count == 0) {
        paymentInProgress = false;
        return;
    }
    assert(count == 1);
    if(count != 1){
        paymentInProgress = false;
        return;
    }
    
    SKProduct *validProduct = [response.products objectAtIndex:0];
    SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
    assert([payment.productIdentifier isEqualToString:@"com.gastonlabs.isreveR.AI_Minimax"]);

    [[SKPaymentQueue defaultQueue] addPayment:payment]; // $$$!
}


// The user wants to upgrade our AI with an in-app purchase!
- (void)upgrade
{
    assert(![[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]);
    
    // are we allowed to make a purchase?
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.gastonlabs.isreveR.AI_Minimax"]];
        request.delegate = self;
        [request start];
    } else {
        paymentInProgress = false;
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Prohibited"
                            message:@"Parental Control is enabled, cannot make a purchase!"
                            delegate:nil
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
        [tmp show];
    }
}


@end
