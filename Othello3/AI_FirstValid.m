//
//  AI_FirstValid.m
//  isreveR
//
//  Created by David E. Weekly on 12/16/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

// This AI implements the crudest possible Othello strategy:
// make the first valid move you come across.

#import "AI_FirstValid.h"

@implementation AI_FirstValid

- (id)initWithGame:(OthelloGameController *)game
{
    self = [super init];
    _game = game;
    return self;
}

- (int)computerTurn:(int *)best_i j:(int *)best_j
{
    // very silly AI that simply immediately returns once it's found a valid move.
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            int here_captured = [OthelloGameController testMove:&(_game->gameState) row:i col:j doMove:false];
            if(here_captured > 0){
                *best_i = i;
                *best_j = j;
                return here_captured;
            }
        }
    }
    
    // we should have been able to find SOME move!
    CLS_LOG(@"WTH, couldn't find a move.");
    assert(false);
}

@end
