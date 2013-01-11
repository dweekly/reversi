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
- (int)evalBoard:(struct GameState *)state
{
    int kCornerPieceScoreMe = 10;
    int kCornerPieceScoreOther = -10;
    int kSidePieceScoreMe = 4;
    int kSidePieceScoreOther = -4;
    int kPieceScoreMe = 1;
    int kPieceScoreOther = -1;
    int kMulForNumPlacesCanMove = 4; // highly weight having a lot of places to move!

    int boardScore = 0;
    int numPlacesCouldMove = 0;
    int bestCapture = 0;
    
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            OthelloSideType piece = state->board[i][j];
            if(piece == kOthelloNone){
                int capture = [Othello testMove:state row:i col:j doMove:false];
                if(capture > 0) numPlacesCouldMove++;
                if(capture > bestCapture) bestCapture = capture;
                // TODO: perform lookahead to see the value of the pieces captured for better
                // heuristic weighting? effectively would buy us another ply
            } else {
                if( (i==0 && (j==0 || j==7)) || (i==7 && (j==0 || j==7)) ) { // corner piece
                    boardScore += (piece == state->currentPlayer)? kCornerPieceScoreMe : kCornerPieceScoreOther;
                } else if(i==0 || i==7 || j==0 || j==7){ // edge piece
                    boardScore += (piece == state->currentPlayer)? kSidePieceScoreMe : kSidePieceScoreOther;
                } else { // regular piece
                    boardScore += (piece == state->currentPlayer)? kPieceScoreMe : kPieceScoreOther;
                }
            }
        }
    }
    
    boardScore += kMulForNumPlacesCanMove * numPlacesCouldMove;
    boardScore += bestCapture;
    return boardScore;
}

#define NUM_PLY 3

- (int)negamax:(struct GameState *)initgs i:(int *)best_i j:(int *)best_j ply:(int)ply
{
    assert(ply >= 0);
    if(ply == 0) { // we've gone as deep as we can, so just return the score for this node.
        return [self evalBoard:initgs];
    }
    
    int alpha = INT_MIN;
    OthelloSideType otherSide = (initgs->currentPlayer == kOthelloWhite)? kOthelloBlack : kOthelloWhite;
    
    // TODO: we need to order possible moves by desirability first, or alpha-beta doesn't actually save time!
    // evaluate each possible legal move, for each side
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if(initgs->board[i][j] == kOthelloNone && [Othello testMove:initgs row:i col:j doMove:false]) {
                struct GameState gs;
                memcpy(&gs, initgs, sizeof(gs)); // copy the current game state...
                [Othello testMove:&gs row:i col:j doMove:true]; // make the move...
                gs.currentPlayer = otherSide; // ...and switch sides.
                int childWeight = -([self negamax:&gs i:best_i j:best_j ply:(ply-1)]);
                if(childWeight > alpha) {
                    alpha = childWeight;
                    if(ply == NUM_PLY) {
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
        return -([self negamax:&gs i:best_i j:best_j ply:(ply-1)]);
    }

    return alpha;
}


- (void)computerTurn:(int *)best_i j:(int *)best_j
{
    // since this is a premium algorithm, ensure that we've been IAP enabled
    assert([[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]);
    assert(_game->gameState.currentPlayer == kOthelloBlack); // computer should always be black in current setup
    [self negamax:&(_game->gameState) i:best_i j:best_j ply:NUM_PLY];
}

@end
