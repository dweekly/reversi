//
//  ViewController.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OthelloBoardView.h"

@interface ViewController : UIViewController

- (IBAction)feedback:(id)sender;

@property (weak, nonatomic) IBOutlet OthelloBoardView *othelloBoard;

@end
