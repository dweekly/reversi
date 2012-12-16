//
//  OthelloBoardView.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class AppDelegate;

@interface OthelloBoardView : UIView
{
    CGFloat _cellSize;
}

@property (readwrite) AppDelegate *app;
@property (strong, nonatomic) UIImage *blackpiece;
@property (strong, nonatomic) UIImage *whitepiece;
@property (strong, nonatomic) UIImage *felt;

@end

