//
//  AI_Minimax.h
//  isreveR
//
//  Created by David E. Weekly on 12/16/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "AI.h"

@interface AI_Minimax : NSObject <AIDelegate>
{
    OthelloGameController *_game;
}

+ (int)negamax:(struct GameState *)initgs i:(int *)best_i j:(int *)best_j ply:(int)ply maxply:(int)maxply;

@end
