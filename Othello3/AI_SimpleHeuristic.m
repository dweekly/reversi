//
//  AI_SimpleHeuristic.m
//  isreveR
//
//  Created by David E. Weekly on 2/16/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

// Implements a 1-ply version of the negamax scout

#import "AI_SimpleHeuristic.h"
#import "AI_Minimax.h"
#import "OthelloGameController.h"

@implementation AI_SimpleHeuristic


- (id)initWithGame:(OthelloGameController *)game
{
    self = [super init];
    _game = game;
    return self;
}


- (void)computerTurn:(int *)best_i j:(int *)best_j
{
    assert(_game->gameState.currentPlayer == kOthelloBlack); // computer should always be black in current setup
    [AI_Minimax negamax:&(_game->gameState) i:best_i j:best_j ply:1 maxply:1];
}


@end
