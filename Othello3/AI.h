//
//  AI.h
//  isreveR
//
//  Created by David E. Weekly on 1/9/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "Othello.h"

@class OthelloGameController;

// define how we'll interact with AIs.
@protocol AIDelegate
- (id)initWithGame:(OthelloGameController *)game;
- (void)computerTurn:(int *)best_i j:(int *)best_j;
@end
