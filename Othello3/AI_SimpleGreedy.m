//
//  AI_SimpleGreedy.m
//  isreveR
//
//  Created by David E. Weekly on 12/16/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

// This AI implements a simple greedy algorithm which captures the maximal number
// of pieces permissible on the board.

#import "AI_SimpleGreedy.h"

@implementation AI_SimpleGreedy

- (id)initWithGame:(OthelloGameController *)game
{
    self = [super init];
    _game = game;
    return self;
}

- (int)computerTurn:(int *)best_i j:(int *)best_j
{
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
