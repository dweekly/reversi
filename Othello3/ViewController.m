//
//  ViewController.m
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // ensure we observe any activity on the payment queue (for IAPs)
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    // check IAP, if already made, remove upgrade button
    // If IAP not present, check for restore purchase?
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)feedback:(id)sender {
    [TestFlight openFeedbackView];
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
                
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"AI Unlocked"
                                    message:@"You have unlocked the more sophisticated AI!"
                                    delegate:nil
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                [tmp show];

                // Actually unlock the minimax AI
                AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app.game unlockAI:kAIMinimax];
                 
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
                    NSLog(@"User chickened out of in-app purchase :(");
                } else {
                    NSLog(@"Surprise payment error %@", transaction.error);
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view here
                break;
            }
                
            default: {
                NSLog(@"Unknown transaction state: %d",transaction.transactionState);
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
        NSLog(@"Looks like we didn't have anything more to buy?");
        return;
    }
    assert(count == 1);
    if(count != 1){
        NSLog(@"Too many eligible products??");
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
