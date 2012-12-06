//
//  OthelloBoardView.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface OthelloBoardView : UIView <UIAlertViewDelegate>

@property (strong, nonatomic) UIImage *blackpiece;
@property (strong, nonatomic) UIImage *whitepiece;
@property (strong, nonatomic) UIImage *felt;

@end
