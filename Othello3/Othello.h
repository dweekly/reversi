//
//  Othello.h
//  isreveR
//
//  Created by David E. Weekly on 1/9/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    kOthelloNone,
    kOthelloWhite,
    kOthelloBlack
} OthelloSideType;

typedef enum {
    kAISimpleGreedy = 1,
    kAISimpleHeuristic = 2,
    kAIMinimax = 3
} AIType;

struct GameState {
    OthelloSideType board[8][8];
    OthelloSideType currentPlayer;
};

@interface Othello : NSObject
+ (int)testMove:(struct GameState *)state row:(int)i col:(int)j doMove:(bool)doMove;
+ (AVAudioPlayer *)getPlayerForSound:(NSString *)soundFile;
@end
