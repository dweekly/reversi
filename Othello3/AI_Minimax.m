//
//  AI_Minimax.m
//  isreveR
//
//  Created by David E. Weekly on 12/16/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

// Implements an N-step lookahead that tries to maximize board control.


#import "AI_Minimax.h"

@implementation AI_Minimax

- (id)initWithGame:(OthelloGameController *)game
{
    self = [super init];
    _game = game;
    return self;
}

// A board scores highly for a given side:
//   - when I occupy many corners
//   - when I occupy sides
//   - when I have a lot of pieces on the board
//   - when I have a lot of potential moves
//   (and the converse of the above for my opponent)
- (int)evalBoard:(int[64])board forSide:(OthelloSideType)side
{
    int kCornerPieceScoreMe = 10;
    int kCornerPieceScoreOther = -10;
    int kSidePieceScoreMe = 4;
    int kSidePieceScoreOther = -4;
    int kPieceScoreMe = 1;
    int kPieceScoreOther = -1;
    int kMulForNumPlacesCanMove = 1;

    int boardScore = 0;
    int numPlacesICouldMove = 0;
    
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            OthelloSideType piece = board[i*8 + j];
            if(piece == kOthelloNone){
                // in theory we could test whether we could move here,
                // but this function's just is just to evaluate the score
                // for a given board.
            } else {
                // evaluate the value of the piece here
                if( (i==0 && (j==0 || j==7)) || (i==7 && (j==0 || j==7)) ) { // corner piece
                    boardScore += (piece == side)? kCornerPieceScoreMe : kCornerPieceScoreOther;
                } else {
                    if(i==0 || i==7 || j==0 || j==7){
                        // edge piece that is not corner piece
                        boardScore += (piece == side)? kSidePieceScoreMe : kSidePieceScoreOther;
                    } else {
                        // just a regular piece here.
                        boardScore += (piece == side)? kPieceScoreMe : kPieceScoreOther;
                    }
                }
            }
        }
    }
    
    boardScore += kMulForNumPlacesCanMove * numPlacesICouldMove;
    return boardScore;
}


// TODO: actually implement proper algorithm here. ^_^ derp derp
- (int)computerTurn:(int *)best_i j:(int *)best_j
{
    
    // first, let's capture the current game's board state, so we can return it to how we found it
    // after we're done modelling possibilities.
    OthelloSideType initBoardState[64];
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            initBoardState[i*8 + j] = _game->gameState.board[i][j];
        }
    }
    
    // for every permissible move on the board, calculate the number of pieces captured.
    // simple algorithm weights # pieces captured (TODO: extra weight for sides + corners)
    int best_captured = 0;
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            int here_captured = [_game testMove:kOthelloBlack row:i col:j doMove:false];
            if(here_captured > 0){
                if (here_captured > best_captured) {
                    best_captured = here_captured;
                    *best_i = i;
                    *best_j = j;
                }
            }
        }
    }
    
    // ensure a valid move exists (we shouldn't have been allowed to move otherwise)
    assert(best_captured);
    return best_captured;
}

@end
