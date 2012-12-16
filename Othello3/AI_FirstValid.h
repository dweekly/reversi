//
//  AI_FirstValid.h
//  isreveR
//
//  Created by David E. Weekly on 12/16/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

// This AI implements the crudest possible Othello strategy:
// make the first valid move you come across.

#import <Foundation/Foundation.h>
#import "OthelloGameController.h"

@interface AI_FirstValid : NSObject <AIDelegate>
{
    OthelloGameController *_game;
}


@end
