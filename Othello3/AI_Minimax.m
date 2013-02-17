//
//  AI_Minimax.m
//  isreveR
//
//  Created by David E. Weekly on 12/16/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

// Implements an N-step lookahead that tries to maximize board control.


#import "AI_Minimax.h"
#import "OthelloGameController.h"

@implementation AI_Minimax

- (id)initWithGame:(OthelloGameController *)game
{
    self = [super init];
    _game = game;
    return self;
}

// An Othello board scores highly for a given side:
//   - when I occupy many corners
//   - when I occupy sides
//   - when I have a lot of pieces on the board
//   - when I have a lot of potential moves
//   - when my best capture will capture lots more pieces
//   (and the converse of the above for my opponent)
+ (int)evalBoard:(struct GameState *)state
{
    // See http://www.generation5.org/content/2002/game02.asp
    int weighting[8][8] = {
        {50, -1,5,2,2,5, -1,50},
        {-1,-10,1,1,1,1,-10,-1},
        { 5,  1,1,1,1,1,  1, 5},
        { 2,  1,1,0,0,1,  1, 2},
        { 2,  1,1,0,0,1,  1, 2},
        { 5,  1,1,1,1,1,  1, 5},
        {-1,-10,1,1,1,1,-10,-1},
        {50, -1,5,2,2,5, -1,50}
    };
    
    // pretty highly value having the ability to move!
    int mobilityValue = 10;
    
    int boardScore = 0;
    int bestCapture = 0;
    
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            OthelloSideType piece = state->board[i][j];
            if(piece == kOthelloNone){
                int capture = [Othello testMove:state row:i col:j doMove:false];
                if(capture > 0) boardScore += mobilityValue;
                if(capture > bestCapture) bestCapture = capture;
            } else {
                int mul = (piece == state->currentPlayer)? 1 : -1;
                boardScore += weighting[i][j] * mul;
            }
        }
    }
    
    boardScore += bestCapture;
    
    return boardScore;
}


+ (int)negamax:(struct GameState *)initgs i:(int *)best_i j:(int *)best_j ply:(int)ply maxply:(int)maxply
{
    assert(ply >= 0);
    if(ply == 0) { // we've gone as deep as we can, so just return the score for this node.
        return [AI_Minimax evalBoard:initgs];
    }
    
    int alpha = INT_MIN;
    OthelloSideType otherSide = (initgs->currentPlayer == kOthelloWhite)? kOthelloBlack : kOthelloWhite;
    
    // TODO: order moves by desirability first for Negascout
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if(initgs->board[i][j] == kOthelloNone && [Othello testMove:initgs row:i col:j doMove:false]) {
                struct GameState gs;
                memcpy(&gs, initgs, sizeof(gs)); // copy the current game state...
                [Othello testMove:&gs row:i col:j doMove:true]; // make the move...
                gs.currentPlayer = otherSide; // ...and switch sides.
                int childWeight = -([AI_Minimax negamax:&gs i:best_i j:best_j ply:(ply-1) maxply:maxply]);
                if(childWeight > alpha) {
                    alpha = childWeight;
                    if(ply == maxply) {
                        *best_i = i;
                        *best_j = j;
                    }
                }
            }
        }
    }
    
    // if we just couldn't move, just try other side?
    if(alpha == INT_MIN){
        struct GameState gs;
        memcpy(&gs, initgs, sizeof(gs)); // copy the current game state...
        gs.currentPlayer = otherSide; // ...and switch sides.
        return -([AI_Minimax negamax:&gs i:best_i j:best_j ply:(ply-1) maxply:maxply]);
    }

    return alpha;
}


- (void)computerTurn:(int *)best_i j:(int *)best_j
{
    // since this is a premium algorithm, ensure that we've been IAP enabled
    assert([[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]);
    assert(_game->gameState.currentPlayer == kOthelloBlack); // computer should always be black in current setup
    
    // okay let's do a 5-ply lookahead
    [AI_Minimax negamax:&(_game->gameState) i:best_i j:best_j ply:5 maxply:5];
}

@end
