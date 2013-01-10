//
//  OthelloGameController.h
//  isreveR
//
//  Created by David E. Weekly on 12/15/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>

#import "OthelloBoardView.h"
#import "GameBoardViewController.h"

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
@class GameBoardViewController;


// define how we'll interact with AIs.
@protocol AIDelegate
- (id)initWithGame:(OthelloGameController *)game;
- (int)computerTurn:(int *)best_i j:(int *)best_j;
@end

typedef enum {
    kAIFirstValid = 1,
    kAISimpleGreedy = 2,
    kAIMinimax = 3
} AIType;

struct GameState {
    OthelloSideType board[8][8];
    OthelloSideType currentPlayer;
};


@interface OthelloGameController : NSObject <UIAlertViewDelegate, GKTurnBasedEventHandlerDelegate>
{
    @public struct GameState gameState; // this structure encapsulates the current state of the game.
    @public OthelloSideType userSide; // what side is the user on?
    id<AIDelegate> _ai;
}

+ (int)testMove:(struct GameState *)state row:(int)i col:(int)j doMove:(bool)doMove;
+ (AVAudioPlayer *)getPlayerForSound:(NSString *)soundFile;

- (bool)attemptPlayerMove:(int)i col:(int)j;
- (void)newGameVersusAI:(AIType)name;
- (void)resign;
- (void)loadGameFromMatch:(GKTurnBasedMatch *)match;

@property (retain) GKTurnBasedMatch *match;
@property (readwrite) GameBoardViewController *boardViewController;
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
