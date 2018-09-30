//
//  AppDelegate.m
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@import Firebase;
@import Instabug;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [FIRApp configure];
    
    // load the root view controller and show it.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController_iPhone" bundle:nil];
        self.aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iPhone" bundle:nil];
        self.opponentViewController = [[OpponentSelectViewController alloc] initWithNibName:@"OpponentSelectViewController_iPhone" bundle:nil];
        self.gameBoardViewController = [[GameBoardViewController alloc] initWithNibName:@"GameBoardViewController_iPhone" bundle:nil];
    } else {
        self.welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController_iPad" bundle:nil];
        self.aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iPad" bundle:nil];
        self.opponentViewController = [[OpponentSelectViewController alloc] initWithNibName:@"OpponentSelectViewController_iPad" bundle:nil];
        self.gameBoardViewController = [[GameBoardViewController alloc] initWithNibName:@"GameBoardViewController_iPad" bundle:nil];
    }

    self.window.rootViewController = self.welcomeViewController;
    [self.window makeKeyAndVisible];

    // we're not currently in a match, so zero that out for now.
    self->match = nil;
    
    // create the game object!
    _game = [[OthelloGameController alloc] init];
    
    // let game object know about the board view so it can refresh the board as needed.
    _game.boardViewController = self.gameBoardViewController;
    
#ifdef GAMECENTER
    // Now authenticate the local user and set up our turn-based delegate
    // (we might have been launched in order to handle a turn-based event!
    
    // TODO: this method is actually deprecated as of iOS6, but we need to do things this way for IOS5
    // unless we want to implement both methods. Poop. (iOS6 GC shows a nice login if they're not logged in)
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
        if (error) {
            // User isn't logged into GC?
            CLS_LOG(@"Error on init logging into Game Center: %@", error);
        } else {
            // Set delegate for turn based events immediately after player authentication, per Apple docs:
            // http://developer.apple.com/library/ios/#documentation/GameKit/Reference/GKTurnBasedEventHandler_Ref
            [[GKTurnBasedEventHandler sharedTurnBasedEventHandler] setDelegate:_game];
            
#define NUKE_ALL_EXISTING_MATCHES 1
            
#ifdef NUKE_ALL_EXISTING_MATCHES
            CLS_LOG(@"NUKING ALL EXISTING GAME CENTER MATCHES");
            [GKTurnBasedMatch loadMatchesWithCompletionHandler:
             ^(NSArray *nukeMatches, NSError *error){
                 if(error){
                     CLS_LOG(@"Error loading matches to nuke: %@", error);
                 } else {
                     for (GKTurnBasedMatch *nukeMatch in nukeMatches) {
                         CLS_LOG(@"Nuking match %@", nukeMatch.matchID);
                         [nukeMatch removeWithCompletionHandler:^(NSError *error){
                             if(error){
                                 CLS_LOG(@"Error nuking match %@: %@", nukeMatch, error);
                             } else {
                                 CLS_LOG(@"Nuked match %@", nukeMatch);
                             }
                         }];
                     }
                 }
             }];
#endif
        }
    }];
#endif
    
    // instatiate Instabug, but only after shake (not after screenshot)
    [Instabug startWithToken:@"738dbcc9022b5f15b297ff00dcdce2c9" invocationEvents: IBGInvocationEventShake];
    // turn off prompt after 10 seconds
    [Instabug setWelcomeMessageMode:IBGWelcomeMessageModeDisabled];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
