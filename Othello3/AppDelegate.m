//
//  AppDelegate.m
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

#ifdef FLURRY
    // Add Flurry analytics.
    [Flurry startSession:@"5XRJ5TGT3DMQTYHH5VVS"];
#endif
    
#ifdef CRASHLYTICS
    // Add Crashlytics
    [Crashlytics startWithAPIKey:@"1832bc892086bfad3ad1d6f83d5deba876746cb1"];
#endif

#ifdef TESTFLIGHT
    // Add TestFlight
#ifdef  TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    [TestFlight takeOff:@"7f8e5fb9bd5c08bfd5157d9014b2e510_MTY2ODg5MjAxMi0xMi0xNiAwMjo0ODo0MC40NzIwNDU"];
#endif
    
    // create the game object!
    _game = [[OthelloGameController alloc] init];
    
    /*
    // let's kick off some music!
    NSURL *url = [NSURL URLWithString:@"http://live.streamhosting.ch:8010/"];
	_streamer = [[AudioStreamer alloc] initWithURL:url];
    [_streamer start];
     */
    
    // load the root view controller and show it.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    // let game object know about the board view so it can refresh the board as needed.
    _game.boardView = self.viewController.othelloBoard;
    
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
