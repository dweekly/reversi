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
}


- (void)startComputerGameWithAI:(AIType)ai
{
    _app.game->userSide = kOthelloWhite; // let the user go first.
    [_app.game newGameVersusAI:ai];
    _app.gameBoardViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:_app.gameBoardViewController animated:YES completion:NULL];
}

- (IBAction)playEasyComputer:(id)sender {
    CLS_LOG(@"Starting EASY match");
    [self startComputerGameWithAI:kAIFirstValid];
}

- (IBAction)playMediumComputer:(id)sender {
    CLS_LOG(@"Starting MEDIUM match");
    [self startComputerGameWithAI:kAISimpleGreedy];
}

- (IBAction)playHardComputer:(id)sender {
    // TODO: check for / perform paid upgrade.
    CLS_LOG(@"Starting HARD match");
    [self startComputerGameWithAI:kAIMinimax];
}

- (IBAction)backToMenu:(id)sender {
    CLS_LOG(@"Headed back to menu");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}



////////// GAMECENTER MATCHING //////////


// UI button press: the user has indicated they'd like to play against a human
- (IBAction)playHuman:(id)sender {
    CLS_LOG(@"User requested new gamecenter match.");
    
    // we're probably GC authe'ed already because of the init in AppDelegate, but let's double-check.
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if(!localPlayer.authenticated){
        CLS_LOG(@"User wanted to play human but didn't auth. Ignoring?"); // TODO FIXME reattempt GC login?
        return;
    }

    // fire off new request for two-player match
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    [GKTurnBasedMatch findMatchForRequest:request withCompletionHandler:
        ^(GKTurnBasedMatch *match, NSError *error) {
            if(error){
                CLS_LOG(@"Issue finding new Game Center match: %@", error);
            } else {
                CLS_LOG(@"Found a Game Center match!");
                [_app.gameBoardViewController view]; // force viewDidLoad
                [_app.game loadGameFromMatch:match];
                _app.gameBoardViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:_app.gameBoardViewController animated:YES completion:nil];
            }
    }];
}


////////////////// PAYMENTS / UPGRADING CODE BELOW /////////////////////

// PURCHASE STEP #4: the payment queue is returned from Apple with completed transactions
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
                
                CLS_LOG(@"In-app purchase completed!!!");
                
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"AI Unlocked"
                                    message:@"You have unlocked the more sophisticated AI!"
                                    delegate:nil
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                [tmp show];
                
                // Actually unlock the minimax AI
                // AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
                // [app.game unlockAI:kAIMinimax];
                
                // once we've delivered/stored the purchase,
                // finalize the transaction and remove it from the queue
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateRestored: {
                // unlock is in transaction.originalTransaction.payment.productIdentifier
                assert([transaction.originalTransaction.payment.productIdentifier isEqualToString:@"com.gastonlabs.isreveR.AI_Minimax"]);
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view here?
                break;
            }
                
            case SKPaymentTransactionStateFailed: {
                if(transaction.error.code == SKErrorPaymentCancelled){
                    CLS_LOG(@"User chickened out of in-app purchase :(");
                } else {
                    CLS_LOG(@"Surprise payment error %@", transaction.error);
                    
                    UIAlertView *tmp = [[UIAlertView alloc]
                                        initWithTitle:@"Upgrade Error"
                                        message:@"There was an error with your purchase, apologies."
                                        delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"Ok", nil];
                    [tmp show];

                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view here
                break;
            }
                
            default: {
                CLS_LOG(@"Unknown transaction state: %d",transaction.transactionState);
                break;
            }
        }
    }
}


// PURCHASE STEP #2: get back list of products we can request payment for
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // ensure we got back exactly one product back.
    int count = [response.products count];
    if (count == 0) {
        CLS_LOG(@"Looks like we didn't have anything more to buy?");
        return;
    }
    assert(count == 1);
    if(count != 1){
        CLS_LOG(@"Too many eligible products??");
        return;
    }
    
    // PURCHASE STEP #3: let's request Apple perform the payment
    SKProduct *validProduct = [response.products objectAtIndex:0];
    SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
    assert([payment.productIdentifier isEqualToString:@"com.gastonlabs.isreveR.AI_Minimax"]);
    [[SKPaymentQueue defaultQueue] addPayment:payment]; // $$$!
}


// The user wants to upgrade our AI with an in-app purchase!
- (IBAction)upgrade:(id)sender
{
    // are we allowed to make a purchase?
    if ([SKPaymentQueue canMakePayments]) {
        // PURCHASE STEP #1: let's ask to make the purchase!
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.gastonlabs.isreveR.AI_Minimax"]];
        request.delegate = self;
        [request start];
    } else {
        NSLog(@"Aw, they wanted to buy but payments disabled (e.g. parental controls)");
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
