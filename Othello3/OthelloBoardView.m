//
//  OthelloBoardView.m
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "OthelloBoardView.h"

#import "AppDelegate.h"

@implementation OthelloBoardView


// This code is run first, when the object wakes up from the XIB
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    
    // calculate the size of each cell in our view
    //_cellSize = [self bounds].size.height / 8.0;

    // assert we're a square view.
    //assert([self bounds].size.height == [self bounds].size.width);
    
    /*
    // load piece images for display
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _felt = [UIImage imageNamed:@"felt-iPad.jpg"];
    } else {
        _whitepiece = [UIImage imageNamed:@"whitestone-40"];
        _blackpiece = [UIImage imageNamed:@"blackstone-40"];
        _felt = [UIImage imageNamed:@"felt.jpg"];
    }
    */
    
    _whitepiece = [UIImage imageNamed:@"whitestone-85"];
    _blackpiece = [UIImage imageNamed:@"blackstone-85"];
    _felt = [UIImage imageNamed:@"felt-iPad.jpg"];
    
    // fetch the app so we get get at the game object.
    _app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return self;
}


// The user touched the game board to attempt a move
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
	// Retrieve the touch point
	CGPoint pt = [[touches anyObject] locationInView:self];
    
    // let's figure out what grid-spot they touched in.
    int i = (int)(pt.x / _cellSize);
    int j = (int)(pt.y / _cellSize);
    
    [_app.game attemptPlayerMove:i col:j];
}


// render the playing board's current state
- (void)drawRect:(CGRect)rect
{
    // render the lovely felt background.
    [_felt drawAtPoint:CGPointMake(0.0, 0.0)];
    assert(rect.size.width == rect.size.height); // ensure square board!
    _cellSize = rect.size.width / 8.0;
    
    // set up graphics context for drawing gridlines
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.4].CGColor);
    CGContextSetLineWidth(context, 3);
    
    int i, j;
    for(i=0;i<8;i++){
        
        // draw vertical lines of grid
        CGContextMoveToPoint(context, _cellSize * i, 0);
        CGContextAddLineToPoint(context, _cellSize * i, _cellSize * 8.0);

        // draw horizontal lines of grid
        CGContextMoveToPoint(context, 0, _cellSize * i);
        CGContextAddLineToPoint(context, _cellSize * 8.0, _cellSize * i);

        // render piece in this square
        for(j=0;j<8;j++){
            OthelloSideType space = _app.game->gameState.board[i][j];
            CGRect pieceRect;
            pieceRect.origin.x = (_cellSize * i) + 1;
            pieceRect.origin.y = (_cellSize * j) + 1;
            pieceRect.size.width = _cellSize - 2;
            pieceRect.size.height = _cellSize - 2;
            if(space == kOthelloWhite){
                [_whitepiece drawInRect:pieceRect blendMode:kCGBlendModeNormal alpha:1.0];
            }
            if(space == kOthelloBlack){
                [_blackpiece drawInRect:pieceRect blendMode:kCGBlendModeNormal alpha:1.0];
            }
        }
    }

    // draw last part of bounding box
    CGContextMoveToPoint(context, _cellSize * 8.0, 0);
    CGContextAddLineToPoint(context, _cellSize * 8.0, _cellSize * 8.0);
    CGContextMoveToPoint(context, 0, _cellSize * 8.0);
    CGContextAddLineToPoint(context, _cellSize * 8.0, _cellSize * 8.0);
    
    // actually render gridlines
    CGContextStrokePath(context);
}

@end
