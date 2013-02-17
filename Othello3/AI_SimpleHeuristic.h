//
//  AI_SimpleHeuristic.h
//  isreveR
//
//  Created by David E. Weekly on 2/16/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

// This is a simplified 2-ply version of the Negamax scout.

#import "AI.h"

@interface AI_SimpleHeuristic : NSObject <AIDelegate>
{
    OthelloGameController *_game;
}
@end
