//
//  AppDelegate.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#define CRASHLYTICS 1
#define FLURRY 1
#define TESTFLIGHT 1
// #define TESTING 1

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#ifdef CRASHLYTICS
#import <Crashlytics/Crashlytics.h>
#else
#define CLS_LOG NSLog
#endif

#import "AudioStreamer.h"
#import "TestFlight.h"

#import "OthelloGameController.h"
#import "WelcomeViewController.h"
#import "AboutViewController.h"
#import "OpponentSelectViewController.h"
#import "GameBoardViewController.h"

@class OthelloGameController;
@class WelcomeViewController;
@class AboutViewController;
@class OpponentSelectViewController;
@class GameBoardViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly) AudioStreamer *streamer;
@property (readonly) OthelloGameController *game;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) WelcomeViewController *welcomeViewController;
@property (strong, nonatomic) AboutViewController *aboutViewController;
@property (strong, nonatomic) OpponentSelectViewController *opponentViewController;
@property (strong, nonatomic) GameBoardViewController *gameBoardViewController;

@end
