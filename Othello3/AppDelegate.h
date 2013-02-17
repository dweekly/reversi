//
//  AppDelegate.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "Othello.h"

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
{
    @public GKTurnBasedMatch *match;
}

@property (readonly) OthelloGameController *game;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) WelcomeViewController *welcomeViewController;
@property (strong, nonatomic) AboutViewController *aboutViewController;
@property (strong, nonatomic) OpponentSelectViewController *opponentViewController;
@property (strong, nonatomic) GameBoardViewController *gameBoardViewController;

@end
