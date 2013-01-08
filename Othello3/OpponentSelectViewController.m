//
//  OpponentSelectViewController.m
//  isreveR
//
//  Created by David E. Weekly on 1/7/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import "OpponentSelectViewController.h"
#import "Flurry.h"

@implementation OpponentSelectViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    paymentInProgress = false;

    // TODO: visually change the appearance of self.playHardComputerButton to indicate payment will be required?
}


- (void)startComputerGameWithAI:(AIType)ai
{
    if(paymentInProgress){
        CLS_LOG(@"Ignoring game start request, there's a payment in progress...");
        // TODO: provide feedback as to why we're ignoring their game start request
        return;
    }
    _app.game->userSide = kOthelloWhite; // let the user go first.
    [_app.gameBoardViewController view]; // force view to load
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
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]){
        CLS_LOG(@"Starting HARD match");
        [self startComputerGameWithAI:kAIMinimax];
    } else {
        if(paymentInProgress){
            CLS_LOG(@"Payment is in progress, ignoring second purchase request");
        } else {
            paymentInProgress = true;
            CLS_LOG(@"User selected difficult AI but not yet purchased.");
            // TODO: auto-attempt restore if that hasn't been done yet?
            [self upgrade];
        }
    }
}

- (IBAction)backToMenu:(id)sender {
    CLS_LOG(@"Headed back to menu");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidUnload {
    [self setPlayHardComputerButton:nil];
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


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                // show wait view here
                CLS_LOG(@"PURCHASE - currently purchasing...");
                break;
            }
                
            case SKPaymentTransactionStatePurchased: {
                
                // unlock is in transaction.payment.productIdentifier
                assert([transaction.payment.productIdentifier isEqualToString:@"com.gastonlabs.isreveR.AI_Minimax"]);
                
                CLS_LOG(@"PURCHASE - complete! :D");
                
                // Save the fact that the advanced AI is now unlocked.
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"AI_Minimax"];

                // mark the transaction completed.
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                paymentInProgress = false;

                [Flurry logEvent:@"Minimax IAP Complete"];
                
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"AI Unlocked"
                                    message:@"You have unlocked the more sophisticated AI!"
                                    delegate:nil
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                [tmp show];

                [self startComputerGameWithAI:kAIMinimax];
                
                break;
            }
                
            case SKPaymentTransactionStateRestored: {
                // unlock is in transaction.originalTransaction.payment.productIdentifier
                assert([transaction.originalTransaction.payment.productIdentifier isEqualToString:@"com.gastonlabs.isreveR.AI_Minimax"]);

                [Flurry logEvent:@"Minimax IAP Restore"];

                CLS_LOG(@"PURCHASE - restored!");
                paymentInProgress = false;
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"AI_Minimax"];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self startComputerGameWithAI:kAIMinimax];

                break;
            }
                
            case SKPaymentTransactionStateFailed: {
                if(transaction.error.code == SKErrorPaymentCancelled){
                    CLS_LOG(@"User chickened out of in-app purchase :(");
                    [Flurry logEvent:@"Minimax IAP Cancel"];
                } else {
                    CLS_LOG(@"Surprise payment error %@", transaction.error);
                    [Flurry logEvent:@"Minimax IAP Error"];
                    
                    // only bother the user with an error popup if an upgrade hasn't yet gone through.
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]){
                        UIAlertView *tmp = [[UIAlertView alloc]
                                            initWithTitle:@"Upgrade Error"
                                            message:@"There was an error with your purchase, apologies."
                                            delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok", nil];
                        [tmp show];
                    }

                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                // remove wait view here?
                paymentInProgress = false;
                break;
            }
                
            default: {
                CLS_LOG(@"Unknown transaction state: %d",transaction.transactionState);
                break;
            }
        }
    }
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // ensure we got back exactly one product back.
    int count = [response.products count];
    if (count == 0) {
        CLS_LOG(@"Looks like we didn't have anything more to buy?");
        paymentInProgress = false;
        return;
    }
    assert(count == 1);
    if(count != 1){
        CLS_LOG(@"Too many eligible products??");
        paymentInProgress = false;
        return;
    }
    
    SKProduct *validProduct = [response.products objectAtIndex:0];
    SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
    assert([payment.productIdentifier isEqualToString:@"com.gastonlabs.isreveR.AI_Minimax"]);

    CLS_LOG(@"PURCHASE STEP #2 - got eligible product, attempting to add payment.");
    [[SKPaymentQueue defaultQueue] addPayment:payment]; // $$$!
}


// The user wants to upgrade our AI with an in-app purchase!
- (void)upgrade
{
    assert(![[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]);
    
    // are we allowed to make a purchase?
    if ([SKPaymentQueue canMakePayments]) {
        CLS_LOG(@"PURCHASE STEP #1 - Fetching valid product list from StoreKit.");
        [Flurry logEvent:@"Minimax IAP Begin"];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.gastonlabs.isreveR.AI_Minimax"]];
        request.delegate = self;
        [request start];
    } else {
        CLS_LOG(@"Aw, they wanted to buy but payments disabled (e.g. parental controls)");
        [Flurry logEvent:@"Minimax IAP Payments Disabled"];
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
