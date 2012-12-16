//
//  OthelloGameController.h
//  isreveR
//
//  Created by David E. Weekly on 12/15/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "OthelloBoardView.h"

typedef enum {
    kOthelloNone,
    kOthelloWhite,
    kOthelloBlack
} OthelloSideType;

typedef enum {
    kOthelloAlertGameOver = 1
} OthelloAlerts;

@class OthelloGameController;
@class OthelloBoardView;


// define how we'll interact with AIs.
@protocol AIDelegate
- (id)initWithGame:(OthelloGameController *)game;
- (int)computerTurn:(int *)best_i j:(int *)best_j;
@end


@interface OthelloGameController : NSObject <UIAlertViewDelegate>
{
    @public OthelloSideType _boardState[8][8];
    @public OthelloSideType _currentPlayer;
    id <AIDelegate> _ai;
}

- (bool)attemptPlayerMove:(int)i col:(int)j;
- (int)testMove:(OthelloSideType)whoseMove row:(int)i col:(int)j doMove:(bool)doMove;

@property (readwrite) OthelloBoardView *boardView;
@property (strong, nonatomic) AVAudioPlayer *audioWelcomePlayer;
@property (strong, nonatomic) AVAudioPlayer *audioThppPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioWhoopPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioYayPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioBooPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioNOPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioHoldOnPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioTiePlayer;
@property (strong, nonatomic) AVAudioPlayer *audioYouLostPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioComputerLostPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioNewGamePlayer;

@end
