//
//  AI_Minimax.h
//  isreveR
//
//  Created by David E. Weekly on 12/16/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OthelloGameController.h"

@interface AI_Minimax : NSObject <AIDelegate>
{
    OthelloGameController *_game;
}
@end
