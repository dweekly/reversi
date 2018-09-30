//
//  Othello.m
//  isreveR
//
//  Created by David E. Weekly on 1/9/13.
//  Copyright (c) 2013 David E. Weekly. All rights reserved.
//

#import "Othello.h"

@implementation Othello

// compute whether a given move is valid, and, possibly, do it.
+ (int)testMove:(struct GameState *)state row:(int)i col:(int)j doMove:(bool)doMove
{
    assert(i >= 0);
    assert(i < 8);
    assert(j >= 0);
    assert(j < 8);
    
    // if the proposed space is already occupied, bail.
    if(state->board[i][j] != kOthelloNone){
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
                
                OthelloSideType ray_cell = state->board[ray_i][ray_j];
                
                // if we hit a blank cell before terminating a sequence, give up
                if(ray_cell == kOthelloNone){ break; }
                
                // if we hit a piece that's our own, let's capture the sequence
                if(ray_cell == state->currentPlayer){
                    if(steps > 1){
                        // we've gone at least one step, capture the ray.
                        totalCaptured += steps - 1;
                        if(doMove) { // okay, let's actually execute on this
                            while(steps--){
                                state->board[i + (dx*steps)][j + (dy*steps)] = state->currentPlayer;
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


// fetch a playable object for a sound file
+ (AVAudioPlayer *)getPlayerForSound:(NSString *)soundFile
{
    AVAudioPlayer *p;
    NSString *path = [[NSBundle mainBundle] pathForResource:soundFile ofType:@"mp3"];
    if(!path){
        path = [[NSBundle mainBundle] pathForResource:soundFile ofType:@"wav"];
    }
    if(!path){
        assert(false);
        return nil;
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error;
    p = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    assert(p);
    return p;
}


@end
