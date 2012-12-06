//
//  OthelloBoardView.m
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "OthelloBoardView.h"

@implementation OthelloBoardView

typedef enum {
    kOthelloNone,
    kOthelloWhite,
    kOthelloBlack
} OthelloSideType;

OthelloSideType _boardState[8][8];
OthelloSideType _currentPlayer;


// This code is run first, when the object wakes up from the XIB
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    
    // load piece images for display
    _whitepiece = [UIImage imageNamed:@"whitestone.gif"];
    _blackpiece = [UIImage imageNamed:@"blackstone.gif"];
    _felt = [UIImage imageNamed:@"felt.jpg"];
    
    // start the board empty
    [self initBoard];
    
    return self;
}


// initialize the board to a "beginning game" state
- (void)initBoard
{
    int i, j;
    for(i=0;i<8;i++){
        for(j=0;j<8;j++){
            _boardState[i][j] = kOthelloNone;
        }
    }
    _boardState[3][3] = kOthelloWhite;
    _boardState[4][4] = kOthelloWhite;
    _boardState[3][4] = kOthelloBlack;
    _boardState[4][3] = kOthelloBlack;
    
    // the user, white, goes first. (TODO: actually tell the user this.)
    _currentPlayer = kOthelloWhite;
    
}



// check to see if ANY move is permissible by a given player.
- (bool) canMove:(OthelloSideType)player
{
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if([self testMove:player row:i col:j doMove:false]) {
                return true; // yes, some move is possible.
            }
        }
    }
    return false; // no, no move is possible.
}


// after the game is acknowledged as being over, this is called and a new game is started.
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self initBoard];
}


// the game is over, as nobody can move. calculate respective scores to see who won!
- (void) gameOver
{
    int black = 0;
    int white = 0;
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if(_boardState[i][j] == kOthelloBlack){ black++; }
            if(_boardState[i][j] == kOthelloWhite){ white++; }
        }
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSString *msg;
    if(black > white){
        msg = @"The computer won!";
    }
    if(white > black){
        msg = @"You beat the computer!";
    }
    if(white == black){
        msg = @"You tied with the computer!";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


// someone just finished their move. check to see whose move is next or if the game is over.
- (void) nextTurn
{
    // refresh the display (TODO: some kind of cool animation? at least a delay?)
    [self setNeedsDisplay];

    // if the human just went...
    if(_currentPlayer == kOthelloWhite){
        // and the computer can't move...
        if(![self canMove:kOthelloBlack]){
            // AND the human can't make another move...
            if(![self canMove:kOthelloWhite]){
                // the game is over, since nobody can move.
                NSLog(@"Game over, no moves left.");
                [self gameOver];
                return;
            } else {
                // skip the computer move, let the human move again.
                NSLog(@"Computer cannot move, skipping robot move. :'(");
            }
        } else {
            // the computer CAN move. let it make a decision.
            NSLog(@"Computer's turn now.");
            _currentPlayer = kOthelloBlack;
            // in 800ms, calculate the computer's move. for now, show the user's move.
            [NSTimer scheduledTimerWithTimeInterval:.8 target:self selector:@selector(computerTurn) userInfo:nil repeats:NO];
        }
    } else { // the computer just went.
        // ...and the human can't move
        if(![self canMove:kOthelloWhite]){
            // and the computer can't make another move.
            if(![self canMove:kOthelloBlack]){
                NSLog(@"Game over, no moves left.");
                [self gameOver];
                return;
            } else {
                NSLog(@"Human can't move, skipping the mortal. :-D");
                // in 800ms, calculate the computer's move. for now, show the user's move.
                [NSTimer scheduledTimerWithTimeInterval:.8 target:self selector:@selector(computerTurn) userInfo:nil repeats:NO];
            }
        } else {
            // the human can move, let them do so.
            NSLog(@"Human's turn now.");
            _currentPlayer = kOthelloWhite;
        }
    }
    
}


// The user touched the game board to attempt a move
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	
    // first, let's check to see if it's the user's turn right now
    if(_currentPlayer != kOthelloWhite){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"It's not your turn." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
	// Retrieve the touch point
	CGPoint pt = [[touches anyObject] locationInView:self];
    
    // let's figure out what grid-spot they touched in.
    int i = (int)(pt.x / 40.0);
    int j = (int)(pt.y / 40.0);
    if([self testMove:kOthelloWhite row:i col:j doMove:true ] == 0){
        // the projected move is inadmissable / would capture no pieces.
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You can't move there." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self nextTurn];
    }
}


// the computer needs to calculate and make its move.
- (void)computerTurn
{
    // for every permissible move on the board, calculate the number of pieces captured.
    // simple algorithm weights # pieces captured (TODO: extra weight for sides + corners)
    int best_i = -1;
    int best_j = -1;
    int best_captured = 0;
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            int here_captured = [self testMove:kOthelloBlack row:i col:j doMove:false];
            // todo: descend via minmax to explore counter-moves
            if (here_captured > best_captured) {
                best_captured = here_captured;
                best_i = i;
                best_j = j;
            }
        }
    }
    
    // ensure a valid move exists (we shouldn't have been allowed to move otherwise)
    assert(best_captured);
    
    // make the move and ensure it was actually valid.
    int captured = [self testMove:kOthelloBlack row:best_i col:best_j doMove:true];
    assert(captured);
    
    // okay, we're all done with our turn now.
    [self nextTurn];
}


// compute whether a given move is valid, and, possibly, do it.
- (bool)testMove:(OthelloSideType)whoseMove row:(int)i col:(int)j doMove:(bool)doMove
{
    assert(i >= 0);
    assert(i < 8);
    assert(j >= 0);
    assert(j < 8);
    assert(whoseMove == kOthelloWhite || whoseMove == kOthelloBlack);
    
    // if the proposed space is already occupied, bail.
    if(_boardState[i][j] != kOthelloNone){
        return false;
    }

    // explore whether any of the eight 'rays' extending from the current piece
    // have a line of at least one opponent piece terminating in one of our own pieces.
    int dx, dy;
    int totalCaptured = 0;
    for(dx = -1; dx <= 1; dx++){
        for(dy = -1; dy <= 1; dy++){
            // (skip the null movement case)
            if(dx == 0 && dy == 0){ continue; }
            
            // explore the ray for potential captures.
            for(int steps = 1; steps < 8; steps++){
                int ray_i = i + (dx*steps);
                int ray_j = j + (dy*steps);
                
                // if the ray has gone out of bounds, give up
                if(ray_i < 0 || ray_i >= 8 || ray_j < 0 || ray_j >= 8){ break; }
                
                OthelloSideType ray_cell = _boardState[ray_i][ray_j];
                
                // if we hit a blank cell before terminating a sequence, give up
                if(ray_cell == kOthelloNone){ break; }
                
                // if we hit a piece that's our own, let's capture the sequence
                if(ray_cell == whoseMove){
                    if(steps > 1){
                        // we've gone at least one step, capture the ray.
                        totalCaptured += steps-1;
                        NSLog(@"Found a valid ray capture from %d, %d on ray %d, %d (steps %d)", i, j, dx, dy, steps);
                        if(doMove) { // okay, let's actually execute on this
                            while(steps--){
                                _boardState[i + (dx*steps)][j + (dy*steps)] = whoseMove;
                            };
                        }
                    }
                    break;
                }
            }
        }
    }
    return totalCaptured;
}


// render the playing board's current state
- (void)drawRect:(CGRect)rect
{
    // render the lovely felt background.
    [_felt drawAtPoint:CGPointMake(0.0, 0.0)];
    
    // set up graphics context for drawing gridlines
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0 green:0.3 blue:0.0 alpha:0.8].CGColor);
    CGContextSetLineWidth(context, 1.5);
    
    int i, j;
    for(i=0;i<8;i++){
        
        // draw vertical lines of grid
        CGContextMoveToPoint(context, (40.0 * i), 0);
        CGContextAddLineToPoint(context, (40.0 * i), 320.0);

        // draw horizontal lines of grid
        CGContextMoveToPoint(context, 0, (40.0 * i));
        CGContextAddLineToPoint(context, 320.0, (40.0 * i));

        // render piece in this square
        for(j=0;j<8;j++){
            OthelloSideType space = _boardState[i][j];
            if(space == kOthelloWhite){
                [_whitepiece drawAtPoint:CGPointMake((40.0 * i) + 5.0, (40.0 * j) + 5.0) blendMode:kCGBlendModeNormal alpha:1.0];
            }
            if(space == kOthelloBlack){
                [_blackpiece drawAtPoint:CGPointMake((40.0 * i) + 5.0, (40.0 * j) + 5.0) blendMode:kCGBlendModeNormal alpha:1.0];
            }
        }
    }

    // draw vertical lines of grid
    CGContextMoveToPoint(context, (40.0 * 8), 0);
    CGContextAddLineToPoint(context, (40.0 * 8), 320.0);
    
    // draw horizontal lines of grid
    CGContextMoveToPoint(context, 0, (40.0 * 8));
    CGContextAddLineToPoint(context, 320.0, (40.0 * 8));

    
    // actually render gridlines
    CGContextStrokePath(context);
}

@end
