//
//  OthelloGameController.m
//  isreveR
//
//  Created by David E. Weekly on 12/15/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "OthelloGameController.h"

// add our AIs!
#import "AI_FirstValid.h"
#import "AI_SimpleGreedy.h"

@implementation OthelloGameController


// fetch a playable object for a sound file
- (AVAudioPlayer *)getPlayerForSound:(NSString *)soundFile
{
    AVAudioPlayer *p;
    NSString *path = [[NSBundle mainBundle] pathForResource:soundFile ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error;
    p = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(!p){
        NSLog(@"Error in getPlayerForSound: %@ %@", error, [error userInfo]);
    }
    return p;
}


// initialize the board to a "beginning game" state
- (void)initBoard
{
    int i, j;
    for(i=0;i<8;i++){
        for(j=0;j<8;j++){
            _boardState[i][j] = kOthelloNone;
        }
    }
    _boardState[3][3] = kOthelloWhite;
    _boardState[4][4] = kOthelloWhite;
    _boardState[3][4] = kOthelloBlack;
    _boardState[4][3] = kOthelloBlack;
    
    // the user, white, goes first. (TODO: actually tell the user this.)
    _currentPlayer = kOthelloWhite;
    
    [_boardView setNeedsDisplay];
}


// check to see if ANY move is permissible by a given player.
- (bool) canMove:(OthelloSideType)player
{
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if([self testMove:player row:i col:j doMove:false]) {
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
    int captured = [self testMove:kOthelloBlack row:best_i col:best_j doMove:true];
    assert(captured);
    
    // okay, we're all done with our turn now.
    [_audioWhoopPlayer play];
    [self nextTurn];
}


// compute whether a given move is valid, and, possibly, do it.
- (int)testMove:(OthelloSideType)whoseMove row:(int)i col:(int)j doMove:(bool)doMove
{
    assert(i >= 0);
    assert(i < 8);
    assert(j >= 0);
    assert(j < 8);
    assert(whoseMove == kOthelloWhite || whoseMove == kOthelloBlack);
    
    // if the proposed space is already occupied, bail.
    if(_boardState[i][j] != kOthelloNone){
        return false;
    }
    
    // explore whether any of the eight 'rays' extending from the current piece
    // have a line of at least one opponent piece terminating in one of our own pieces.
    int dx, dy;
    int totalCaptured = 0;
    for(dx = -1; dx <= 1; dx++){
        for(dy = -1; dy <= 1; dy++){
            // (skip the null movement case)
            if(dx == 0 && dy == 0){ continue; }
            
            // explore the ray for potential captures.
            for(int steps = 1; steps < 8; steps++){
                int ray_i = i + (dx*steps);
                int ray_j = j + (dy*steps);
                
                // if the ray has gone out of bounds, give up
                if(ray_i < 0 || ray_i >= 8 || ray_j < 0 || ray_j >= 8){ break; }
                
                OthelloSideType ray_cell = _boardState[ray_i][ray_j];
                
                // if we hit a blank cell before terminating a sequence, give up
                if(ray_cell == kOthelloNone){ break; }
                
                // if we hit a piece that's our own, let's capture the sequence
                if(ray_cell == whoseMove){
                    if(steps > 1){
                        // we've gone at least one step, capture the ray.
                        totalCaptured += steps-1;
                        // NSLog(@"Found a valid ray capture from %d, %d on ray %d, %d (steps %d)", i, j, dx, dy, steps);
                        if(doMove) { // okay, let's actually execute on this
                            while(steps--){
                                _boardState[i + (dx*steps)][j + (dy*steps)] = whoseMove;
                            };
                        }
                    }
                    break;
                }
            }
        }
    }
    return totalCaptured;
}


// after the game is acknowledged as being over, this is called and a new game is started.
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    assert([alertView tag] == kOthelloAlertGameOver);
    [_audioNewGamePlayer play];
    [self initBoard];
}


// the game is over, as nobody can move. calculate respective scores to see who won!
- (void) gameOver
{
    int black = 0;
    int white = 0;
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if(_boardState[i][j] == kOthelloBlack){ black++; }
            if(_boardState[i][j] == kOthelloWhite){ white++; }
        }
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSString *msg;
    if(black > white){
        msg = @"The computer won!";
        [_audioYouLostPlayer play];
    }
    if(white > black){
        msg = @"You beat the computer!";
        [_audioComputerLostPlayer play];
    }
    if(white == black){
        msg = @"You tied with the computer!";
        [_audioTiePlayer play];
    }
    [TestFlight passCheckpoint:@"Completed a game!"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:msg delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
    [alert setTag:kOthelloAlertGameOver];
    [alert show];
}


// someone just finished their move. check to see whose move is next or if the game is over.
- (void)nextTurn
{
    [_boardView setNeedsDisplay];
    
    // if the human just went...
    if(_currentPlayer == kOthelloWhite){
        // and the computer can't move...
        if(![self canMove:kOthelloBlack]){
            // AND the human can't make another move...
            if(![self canMove:kOthelloWhite]){
                // the game is over, since nobody can move.
                NSLog(@"Game over, no moves left.");
                [self gameOver];
                return;
            } else {
                // skip the computer move, let the human move again.
                NSLog(@"Computer cannot move, skipping robot move. :'(");
                [_audioBooPlayer play];
            }
        } else {
            // the computer CAN move. let it make a decision.
            _currentPlayer = kOthelloBlack;
            // in 800ms, calculate the computer's move. for now, show the user's move.
            [NSTimer scheduledTimerWithTimeInterval:.8 target:self selector:@selector(computerTurn) userInfo:nil repeats:NO];
        }
    } else { // the computer just went.
        // ...and the human can't move
        if(![self canMove:kOthelloWhite]){
            // and the computer can't make another move.
            if(![self canMove:kOthelloBlack]){
                NSLog(@"Game over, no moves left.");
                [self gameOver];
                return;
            } else {
                NSLog(@"Human can't move, skipping the mortal. :-D");
                [_audioYayPlayer play];
                // in 800ms, calculate the computer's move. for now, show the user's move.
                [NSTimer scheduledTimerWithTimeInterval:.8 target:self selector:@selector(computerTurn) userInfo:nil repeats:NO];
            }
        } else {
            // the human can move, let them do so.
            _currentPlayer = kOthelloWhite;
        }
    }
}


// The user has attempted a move, it may or may not be legal or their turn.
- (bool)attemptPlayerMove:(int)i col:(int)j
{
    // first, let's check to see if it's the user's turn right now
    if(_currentPlayer != kOthelloWhite){
        NSLog(@"Player attempted to move at %d, %d but wasn't player's turn.", i, j);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_audioHoldOnPlayer play];
        return false;
    }
    
    // attempt to actually make the move.
    int captured = [self testMove:kOthelloWhite row:i col:j doMove:true];
    if(captured == 0){
        // the projected move is inadmissable / would capture no pieces.
        NSLog(@"Player attempted to move at %d, %d but move was not permitted.", i, j);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_audioNOPlayer play];
        return false;
    }
    
    // the move is admissable and was made, make the next turn happen
    NSLog(@"Player moved successfully at %d, %d capturing %d pieces.", i, j, captured);
    [_audioThppPlayer play];
    [self nextTurn];
    return true;
}


- (id)init
{
    self = [super init];
    
    // pick which A.I. we're going to use
    _ai = [[AI_SimpleGreedy alloc] initWithGame:self];
    
    _audioWelcomePlayer = [self getPlayerForSound:@"welcome"];
    _audioThppPlayer = [self getPlayerForSound:@"thpp"];
    _audioWhoopPlayer = [self getPlayerForSound:@"whoop"];
    _audioYayPlayer = [self getPlayerForSound:@"yay"];
    _audioBooPlayer = [self getPlayerForSound:@"boo"];
    _audioNOPlayer = [self getPlayerForSound:@"no"];
    _audioHoldOnPlayer = [self getPlayerForSound:@"holdon2"];
    _audioTiePlayer = [self getPlayerForSound:@"tie"];
    _audioYouLostPlayer = [self getPlayerForSound:@"youlost"];
    _audioComputerLostPlayer = [self getPlayerForSound:@"computerlost"];
    _audioNewGamePlayer = [self getPlayerForSound:@"newgame"];

    // welcome the player
    [_audioWelcomePlayer play];
    
    // start the board empty
    [self initBoard];
    
    return self;
};

@end
