//
//  Othello.h
//  isreveR
//
//  Created by David E. Weekly on 1/9/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define CRASHLYTICS 1
#define FLURRY 1
#define GAMECENTER
#define TESTFLIGHT 1
//#define TESTING 1
//#define FLURRY_LOC


#ifdef CRASHLYTICS
#import <Crashlytics/Crashlytics.h>
#else
#define CLS_LOG NSLog
#endif

#ifdef TESTFLIGHT
#import "TestFlight.h"
#endif

typedef enum {
    kOthelloNone,
    kOthelloWhite,
    kOthelloBlack
} OthelloSideType;

typedef enum {
    kAIFirstValid = 1,
    kAISimpleGreedy = 2,
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
