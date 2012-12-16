//
//  AppDelegate.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioStreamer.h"
#import "OthelloGameController.h"
#import "TestFlight.h"

#define TESTING 1

@class ViewController;
@class AudioStreamer;
@class OthelloGameController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly) AudioStreamer *streamer;
@property (readonly) OthelloGameController *game;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

@end
