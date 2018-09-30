//
//  OthelloGameController.m
//  isreveR
//
//  Created by David E. Weekly on 12/15/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "Othello.h"
#import "OthelloGameController.h"

// add our AIs!
#import "AI_SimpleGreedy.h"
#import "AI_SimpleHeuristic.h"
#import "AI_Minimax.h"

@implementation OthelloGameController

// retrieve the match data in a format suitable for passing to Game Center
- (NSData *) matchData
{
    return [NSData dataWithBytes:&gameState length:sizeof(gameState)];
}


// initialize the board to a "beginning game" state
- (void)initBoard
{
    int i, j;
    for(i=0;i<8;i++){
        for(j=0;j<8;j++){
            gameState.board[i][j] = kOthelloNone;
        }
    }
    gameState.board[3][3] = kOthelloWhite;
    gameState.board[4][4] = kOthelloWhite;
    gameState.board[3][4] = kOthelloBlack;
    gameState.board[4][3] = kOthelloBlack;
    
    gameState.currentPlayer = kOthelloWhite; // white always starts the game.
    
    [self setStatus:@"Your turn!"];
    [self refreshBoard];
}


// check to see if ANY move is permissible by a given player.
- (bool) canMove
{
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if([Othello testMove:&(gameState) row:i col:j doMove:false]) {
                return true; // yes, some move is possible.
            }
        }
    }
    return false; // no, no move is possible.
}


// the computer needs to calculate and make its move.
- (void)computerTurn
{
    int best_i = -1;
    int best_j = -1;
    
    // Call out to our AI here!
    [_ai computerTurn:&best_i j:&best_j];

    // make the move and ensure it was actually valid.
    assert(best_i >= 0 && best_i < 8);
    assert(best_j >= 0 && best_j < 8);
    int captured = [Othello testMove:&(gameState) row:best_i col:best_j doMove:true];
    assert(captured);
    
    // okay, we're all done with our turn now.
    [_audioWhoopPlayer play];
    [self nextTurn];
}

// start a new game against the computer.
- (void) newGameVersusAI:(AIType)ai
{
    [_audioNewGamePlayer play];
    userSide = kOthelloWhite;
    
    switch(ai){
        case kAISimpleGreedy: {
            //[Flurry logEvent:@"Easy AI Match"];
            _ai = [[AI_SimpleGreedy alloc] initWithGame:self];
            [self nameSide:kOthelloBlack as:@"Easy AI"];
            break;
        }
        case kAISimpleHeuristic: {
            //[Flurry logEvent:@"Medium AI Match"];
            _ai = [[AI_SimpleHeuristic alloc] initWithGame:self];
            [self nameSide:kOthelloBlack as:@"Medium AI"];
            break;
        }
        case kAIMinimax: {
            assert([[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]);
            //[Flurry logEvent:@"Expert AI Match"];
            _ai = [[AI_Minimax alloc] initWithGame:self];
            [self nameSide:kOthelloBlack as:@"Expert AI"];
            break;
        }
        default: {
            // Crashlytics log this?
            assert(false);
        }
    }
    
    [self setStatus:@"Your turn!"];
    [self initBoard];
}


// the game is over, as nobody can move. calculate respective scores to see who won!
- (void) gameOver
{
    // shake the device in glee - the game's done!
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *msg;

    // count the pieces
    int userPieces = 0;
    int opponentPieces = 0;
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if(gameState.board[i][j] == userSide){
                userPieces++;
            } else if (gameState.board[i][j] != kOthelloNone){
                opponentPieces++;
            }
        }
    }
    
    // determine a winner
    if(opponentPieces > userPieces){
        msg = @"Your opponent won!";
        [_audioYouLostPlayer play];
        //[Flurry logEvent:@"Game lost"];
    } else if(userPieces > opponentPieces) {
        msg = @"You win!";
        [_audioComputerLostPlayer play];
        //[Flurry logEvent:@"Game won"];
    } else {
        msg = @"You tied.";
        [_audioTiePlayer play];
        //[Flurry logEvent:@"Game tied"];
    }
    
#ifdef TESTFLIGHT
    [TestFlight passCheckpoint:@"Completed a game against an AI opponent!"];
#endif

    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Over" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                         {
                             NSLog(@"Game confirmed ended, returning to opponent selection screen.");
                             [self dismissBoard];
                         }];
    [alert addAction:ok];
    [app.gameBoardViewController presentViewController:alert animated:YES completion:nil];
}


// user wishes to resign the current game (auto-loses)
- (void) resign
{
    // TODO: note loss/resignation to A.I. opponent
    
    // punt back to opponent selection screen
    [self dismissBoard];
}


- (void) opponentMove
{
    [self setStatus:@"Waiting for opponent..."];
    // Delay 700ms before letting computer compute move in order to be less disorienting.
    [self setStatus:@"I'm thinking..."];
    [NSTimer scheduledTimerWithTimeInterval:.7 target:self selector:@selector(computerTurn) userInfo:nil repeats:NO];
}


// Someone just finished their move. check to see whose move is next or if the game is over.
- (void) nextTurn
{
    [self refreshBoard];
    
    OthelloSideType otherSide = (userSide == kOthelloWhite)? kOthelloBlack : kOthelloWhite;
    
    // if we just went...
    if(gameState.currentPlayer == userSide){
        gameState.currentPlayer = otherSide;
        // and the other side can't move...
        if(![self canMove]){
            gameState.currentPlayer = userSide;
            // AND the human can't make another move...
            if(![self canMove]){
                // the game is over, since nobody can move.
                [self gameOver];
                return;
            } else {
                // skip the other side's move, let the user move again.
                [self setStatus:@"Go again!"];
                [_audioBooPlayer play];
            }
        } else {
            // the other side CAN move. let it make a decision.
            gameState.currentPlayer = otherSide;
            [self opponentMove];
        }
    } else { // the other side just went.
        gameState.currentPlayer = userSide;
        // ...and the user can't move
        if(![self canMove]){
            gameState.currentPlayer = otherSide;
            // and the other side can't make another move.
            if(![self canMove]){
                [self gameOver];
                return;
            } else {
                [self setStatus:@"My turn again!"];
                [_audioYayPlayer play];
                [self opponentMove];
            }
        } else {
            // the human can move, let them do so.
            [self setStatus:@"Your turn!"];
        }
    }
}


// The user has attempted a move, it may or may not be legal or their turn.
- (bool) attemptPlayerMove:(int)i col:(int)j
{
    // first, let's check to see if it's the user's turn right now
    if(gameState.currentPlayer != userSide){
        [self setStatus:@"Not your turn yet!"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_audioHoldOnPlayer play];
        return false;
    }
    
    // attempt to actually make the move.
    int captured = [Othello testMove:&(gameState) row:i col:j doMove:true];
    if(captured == 0){
        // the projected move is inadmissable / would capture no pieces.
        [self setStatus:@"You can't move there."];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_audioNOPlayer play];
        return false;
    }
    
    // the move is admissable and was made, make the next turn happen
    [_audioThppPlayer play];
    [self nextTurn];
    return true;
}


// label a given side with a string
- (void) nameSide:(OthelloSideType)side as:(NSString *)label
{
    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(side == kOthelloWhite){
        [app.gameBoardViewController.whiteLabel setText:label];
    } else {
        [app.gameBoardViewController.blackLabel setText:label];
    }
}


// update the status on the board
- (void) setStatus:(NSString *)status
{
    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.gameBoardViewController.statusLabel setText:status];
}


// refresh the board view
- (void) refreshBoard
{
    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.gameBoardViewController.othelloBoard setNeedsDisplay];
}


// dismiss the game board to return to opponent selection
- (void) dismissBoard
{
    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.gameBoardViewController dismissViewControllerAnimated:YES completion:NULL];
}


///////////////////////////////////////////////////////////////////

- (id)init
{
    self = [super init];
    
    _audioWelcomePlayer = [Othello getPlayerForSound:@"welcome"];
    _audioThppPlayer = [Othello getPlayerForSound:@"thpp"];
    _audioWhoopPlayer = [Othello getPlayerForSound:@"whoop"];
    _audioYayPlayer = [Othello getPlayerForSound:@"yay"];
    _audioBooPlayer = [Othello getPlayerForSound:@"boo"];
    _audioNOPlayer = [Othello getPlayerForSound:@"no"];
    _audioHoldOnPlayer = [Othello getPlayerForSound:@"holdon"];
    _audioTiePlayer = [Othello getPlayerForSound:@"tie"];
    _audioYouLostPlayer = [Othello getPlayerForSound:@"youlost"];
    _audioComputerLostPlayer = [Othello getPlayerForSound:@"computerlost"];
    _audioNewGamePlayer = [Othello getPlayerForSound:@"newgame"];
    
    [_audioWelcomePlayer play];

    return self;
};

@end
