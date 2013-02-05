//
//  OthelloGameController.m
//  isreveR
//
//  Created by David E. Weekly on 12/15/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import "OthelloGameController.h"
#import "Flurry.h"

// add our AIs!
#import "AI_FirstValid.h"
#import "AI_SimpleGreedy.h"
#import "AI_Minimax.h"


@implementation OthelloGameController


// get the list of participants to go next, in a format suitable for passing to Game Center
- (NSArray *) nextParticipants
{
    assert(_match);
    NSUInteger currentIndex = [_match.participants indexOfObject:_match.currentParticipant];
    GKTurnBasedParticipant *nextParticipant = [_match.participants objectAtIndex: ((currentIndex + 1) % [_match.participants count])];
    return @[nextParticipant];
}

// return the opponent
- (GKTurnBasedParticipant *) opponentParticipant
{
    return [self nextParticipants][0];
}


// retrieve the match data in a format suitable for passing to Game Center
- (NSData *) matchData
{
    return [NSData dataWithBytes:&gameState length:sizeof(gameState)];
}


// initialize the board to a "beginning game" state
- (void)initBoard
{
    int i, j;
    for(i=0;i<8;i++){
        for(j=0;j<8;j++){
            gameState.board[i][j] = kOthelloNone;
        }
    }
    gameState.board[3][3] = kOthelloWhite;
    gameState.board[4][4] = kOthelloWhite;
    gameState.board[3][4] = kOthelloBlack;
    gameState.board[4][3] = kOthelloBlack;
    
    gameState.currentPlayer = kOthelloWhite; // white always starts the game.
    
    [self setStatus:@"Your turn!"];
    [self refreshBoard];
}


// check to see if ANY move is permissible by a given player.
- (bool) canMove
{
    for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
            if([Othello testMove:&(gameState) row:i col:j doMove:false]) {
                return true; // yes, some move is possible.
            }
        }
    }
    return false; // no, no move is possible.
}


// the computer needs to calculate and make its move.
- (void)computerTurn
{
    int best_i = -1;
    int best_j = -1;
    
    // Call out to our AI here!
    [_ai computerTurn:&best_i j:&best_j];

    // make the move and ensure it was actually valid.
    assert(best_i >= 0 && best_i < 8);
    assert(best_j >= 0 && best_j < 8);
    int captured = [Othello testMove:&(gameState) row:best_i col:best_j doMove:true];
    assert(captured);
    
    // okay, we're all done with our turn now.
    [_audioWhoopPlayer play];
    [self nextTurn];
}

// after the game is acknowledged as being over, this is called and a new game is started.
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    assert([alertView tag] == kOthelloAlertGameOver);    
    CLSLog(@"Game confirmed ended, returning to opponent selection screen.");
    [self dismissBoard];
}


// start a new game against the computer.
- (void) newGameVersusAI:(AIType)ai
{
    [_audioNewGamePlayer play];
    userSide = kOthelloWhite;
    
    switch(ai){
        case kAIFirstValid: {
            [Flurry logEvent:@"Easy AI Match"];
            _ai = [[AI_FirstValid alloc] initWithGame:self];
            [self nameSide:kOthelloBlack as:@"Easy AI"];
            break;
        }
        case kAISimpleGreedy: {
            [Flurry logEvent:@"Medium AI Match"];
            _ai = [[AI_SimpleGreedy alloc] initWithGame:self];
            [self nameSide:kOthelloBlack as:@"Medium AI"];
            break;
        }
        case kAIMinimax: {
            assert([[NSUserDefaults standardUserDefaults] boolForKey:@"AI_Minimax"]);
            [Flurry logEvent:@"Expert AI Match"];
            _ai = [[AI_Minimax alloc] initWithGame:self];
            [self nameSide:kOthelloBlack as:@"Expert AI"];
            break;
        }
        default: {
            CLS_LOG(@"Asked to switch to unknown AI %d", ai);
            assert(false);
        }
    }
    [Flurry logEvent:@"Match" timed:YES];
    
    [self setStatus:@"Your turn!"];
    [self initBoard];
}


- (void) loadGameFromMatch:(GKTurnBasedMatch *)match
{
    // save the match object to be able to register moves & end-of-game
    _match = match;
    
    if(match.matchData.length == 0) {
        // no existing match data, so we're first.
        userSide = kOthelloWhite; // white (us) starts the match.
        [self nameSide:kOthelloBlack as:@"Human Opponent"]; // the other side is a (yet unnamed) opponent
        [self initBoard];
        return;
    }
    
    // joining an existing match, so let's load the match state
    [match.matchData getBytes:&gameState length:sizeof(gameState)];
    
    // check to see whose turn it is
    GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if([match.currentParticipant.playerID isEqualToString:localPlayer.playerID]){
        // we're the current player.
        userSide = gameState.currentPlayer;
        [self setStatus:@"Your turn!"];
    } else {
        // we're the other player
        userSide = (gameState.currentPlayer == kOthelloBlack) ? kOthelloWhite : kOthelloBlack;
        [self setStatus:@"Waiting for opponent..."];
    }
    
    // display labels for the sides.
    OthelloSideType opponentSide = (userSide == kOthelloBlack) ? kOthelloWhite : kOthelloBlack;
    [self nameSide:userSide as:@"You!"];

    // Display opponent's name (TODO: CACHE THIS?)
    if(match.currentParticipant.playerID){
        [GKPlayer loadPlayersForIdentifiers:[self nextParticipants] withCompletionHandler:
         ^(NSArray *players, NSError *error) {
             if(error){
                 CLS_LOG(@"Game Center error fetching info about opponent: %@", error);
             } else {
                 GKPlayer *opponent = players[0]; // only one other participant
                 [self nameSide:opponentSide as:opponent.displayName];
             }
         }];
    } else {
        // we don't have a named opponent yet. TODO: when we do, fill in the label!
        [self nameSide:opponentSide as:@"Human Opponent"];
    }
    
    // we've updated the board state, so let's refresh the board view.
    [self refreshBoard];
}


// the game is over, as nobody can move. calculate respective scores to see who won!
- (void) gameOver
{
    // shake the device in glee - the game's done!
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *msg;
    GKTurnBasedMatchOutcome userOutcome = GKTurnBasedMatchOutcomeNone;
    GKTurnBasedMatchOutcome opponentOutcome;
    
    if(_match){
        GKTurnBasedParticipant *opponent = [self opponentParticipant];
        if(opponent.matchOutcome == GKTurnBasedMatchOutcomeQuit){
            CLS_LOG(@"We won the game by the other side forfeiting!");
            userOutcome = GKTurnBasedMatchOutcomeWon;
            msg = @"You win! Your opponent forfeits.";
        }
        if(opponent.matchOutcome == GKTurnBasedMatchOutcomeTimeExpired){
            CLS_LOG(@"We won the game by the other side's time expiring!");
            userOutcome = GKTurnBasedMatchOutcomeWon;
            msg = @"You win! Your opponent ran out of time.";
        }
        opponentOutcome = opponent.matchOutcome;
    }
    

    // If the user didn't automatically win, let's see who has more pieces on the board to determine a winner.
    if(userOutcome == GKTurnBasedMatchOutcomeNone){
        // count the pieces
        int userPieces = 0;
        int opponentPieces = 0;
        for(int i=0; i<8; i++){
            for(int j=0; j<8; j++){
                if(gameState.board[i][j] == userSide){
                    userPieces++;
                } else if (gameState.board[i][j] != kOthelloNone){
                    opponentPieces++;
                }
            }
        }
        
        // determine a winner
        if(opponentPieces > userPieces){
            msg = @"Your opponent won!";
            userOutcome = GKTurnBasedMatchOutcomeLost;
            opponentOutcome = GKTurnBasedMatchOutcomeWon;
            if(!_match) [_audioYouLostPlayer play];
            [Flurry logEvent:@"Game lost"];
        } else if(userPieces > opponentPieces) {
            msg = @"You win!";
            userOutcome = GKTurnBasedMatchOutcomeWon;
            opponentOutcome = GKTurnBasedMatchOutcomeLost;
            if(!_match) [_audioComputerLostPlayer play];
            [Flurry logEvent:@"Game won"];
        } else {
            msg = @"You tied.";
            userOutcome = GKTurnBasedMatchOutcomeTied;
            opponentOutcome = GKTurnBasedMatchOutcomeTied;
            if(!_match) [_audioTiePlayer play];
            [Flurry logEvent:@"Game tied"];
        }
    }
        
    // If in a Game Center match, tell Game Center who won and who lost.
    if(_match){
        CLS_LOG(@"Game is over, committing match outcome data to Game Center.");
        _match.currentParticipant.matchOutcome = userOutcome;
        GKTurnBasedParticipant *opponent = [self opponentParticipant];
        if(opponent.matchOutcome == GKTurnBasedMatchOutcomeNone) { // opponent may have e.g. quit.
            opponent.matchOutcome = opponentOutcome;
        }
        
        [_match endMatchInTurnWithMatchData:[self matchData] completionHandler:^(NSError *error) {
            if(error){
                CLS_LOG(@"Game Center error marking match completed: %@", error);
            } else {
#ifdef TESTFLIGHT
                [TestFlight passCheckpoint:@"Completed a game against a human opponent!"];
#endif
                // TODO: delete old match?
            }
        }];
        
        // TODO: prompt for rematch?
        
    } else {
        // TODO: note locally whether the user won or lost vs which A.I.
#ifdef TESTFLIGHT
        [TestFlight passCheckpoint:@"Completed a game against an AI opponent!"];
#endif
    }

    [Flurry endTimedEvent:@"Match" withParameters:nil];
    
    // Popup to display the results of the game before we transition back to opponent selection.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert setTag:kOthelloAlertGameOver];
    [alert show];
}


// user wishes to resign the current game (auto-loses)
- (void) resign
{
    [Flurry logEvent:@"Game resigned"];
    [Flurry endTimedEvent:@"Match" withParameters:nil];

    if(_match) {
        if(userSide == gameState.currentPlayer){
            [_match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:[self nextParticipants] turnTimeout:GKTurnTimeoutDefault matchData:[self matchData] completionHandler:
             ^(NSError *error) {
                 if(error){
                     CLS_LOG(@"Game Center error resigning in turn: %@", error);
                 }
             }];
        } else {
            // we quit out-of-turn.
            [_match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:
             ^(NSError *error) {
                 if(error) {
                     CLS_LOG(@"Game Center error resigning out of turn: %@", error);
                 }
            }];
        }
    } else {
        // TODO: note loss/resignation to A.I. opponent
    }
    
    // punt back to opponent selection screen
    [self dismissBoard];
}


- (void) opponentMove
{
    [self setStatus:@"Waiting for opponent..."];
    if(_match) {
        // commit current match data to Game Center and pass the turn to the human opponent
        [_match endTurnWithNextParticipants:[self nextParticipants] turnTimeout:GKTurnTimeoutDefault matchData:[self matchData] completionHandler:
            ^(NSError *error){
                if(error){
                    CLS_LOG(@"Error ending turn: %@", error);
                }
            }
         ];
    } else {
        // Delay 700ms before letting computer compute move in order to be less disorienting.
        [self setStatus:@"I'm thinking..."];
        [NSTimer scheduledTimerWithTimeInterval:.7 target:self selector:@selector(computerTurn) userInfo:nil repeats:NO];
    }
}


// Someone just finished their move. check to see whose move is next or if the game is over.
- (void) nextTurn
{
    [self refreshBoard];
    
    OthelloSideType otherSide = (userSide == kOthelloWhite)? kOthelloBlack : kOthelloWhite;
    
    // if we just went...
    if(gameState.currentPlayer == userSide){
        gameState.currentPlayer = otherSide;
        // and the other side can't move...
        if(![self canMove]){
            gameState.currentPlayer = userSide;
            // AND the human can't make another move...
            if(![self canMove]){
                // the game is over, since nobody can move.
                CLS_LOG(@"Game over, no moves left.");
                [self gameOver];
                return;
            } else {
                // skip the other side's move, let the user move again.
                CLS_LOG(@"Computer cannot move, skipping robot move. :'(");
                [self setStatus:@"Go again!"];
                [_audioBooPlayer play];
            }
        } else {
            // the other side CAN move. let it make a decision.
            gameState.currentPlayer = otherSide;
            [self opponentMove];
        }
    } else { // the other side just went.
        gameState.currentPlayer = userSide;
        // ...and the user can't move
        if(![self canMove]){
            gameState.currentPlayer = otherSide;
            // and the other side can't make another move.
            if(![self canMove]){
                CLS_LOG(@"Game over, no moves left.");
                [self gameOver];
                return;
            } else {
                CLS_LOG(@"User can't move, skipping");
                [self setStatus:@"My turn again!"];
                [_audioYayPlayer play];
                [self opponentMove];
            }
        } else {
            // the human can move, let them do so.
            [self setStatus:@"Your turn!"];
        }
    }
}


// The user has attempted a move, it may or may not be legal or their turn.
- (bool) attemptPlayerMove:(int)i col:(int)j
{
    // first, let's check to see if it's the user's turn right now
    if(gameState.currentPlayer != userSide){
        CLS_LOG(@"Player attempted to move at %d, %d but wasn't player's turn.", i, j);
        [self setStatus:@"Not your turn yet!"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_audioHoldOnPlayer play];
        return false;
    }
    
    // attempt to actually make the move.
    int captured = [Othello testMove:&(gameState) row:i col:j doMove:true];
    if(captured == 0){
        // the projected move is inadmissable / would capture no pieces.
        CLS_LOG(@"Player attempted to move at %d, %d but move was not permitted.", i, j);
        [self setStatus:@"You can't move there."];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_audioNOPlayer play];
        return false;
    }
    
    // the move is admissable and was made, make the next turn happen
    CLS_LOG(@"Player moved successfully at %d, %d capturing %d pieces.", i, j, captured);
    [_audioThppPlayer play];
    [self nextTurn];
    return true;
}


// label a given side with a string
- (void) nameSide:(OthelloSideType)side as:(NSString *)label
{
    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(side == kOthelloWhite){
        [app.gameBoardViewController.whiteLabel setText:label];
    } else {
        [app.gameBoardViewController.blackLabel setText:label];
    }
}


// update the status on the board
- (void) setStatus:(NSString *)status
{
    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.gameBoardViewController.statusLabel setText:status];
}


// refresh the board view
- (void) refreshBoard
{
    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.gameBoardViewController.othelloBoard setNeedsDisplay];
}


// dismiss the game board to return to opponent selection
- (void) dismissBoard
{
    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.gameBoardViewController dismissViewControllerAnimated:YES completion:NULL];
}



/////////// GKTurnBasedEventHandlerDelegate Section ///////////

// We are inviting someone else to a match (only from the gamecenter matching view, which we've torn out, so probably not relevant.
- (void) handleInviteFromGameCenter:(NSArray *)playersToInvite
{
    // XXX FIXME TODO: Ask the user if they want to forfeit their current (e.g. vs AI) match
    // to accept the invite??
    
    // For now, decline all invites.
    CLS_LOG(@"User invited someone to a new match from Game Center, auto-declining because this can't happen???");
    [_match declineInviteWithCompletionHandler:^(NSError *error) {
        if(error){
            CLS_LOG(@"Error declining invite: %@", error);
        }
    }];
}


// Game Center thinks the match has ended.
- (void) handleMatchEnded:(GKTurnBasedMatch *)match
{
    assert(match.status == GKTurnBasedMatchStatusEnded);
    
    // load the game state from match data & refresh the board
    _match = match;
    [match.matchData getBytes:&gameState length:sizeof(gameState)];
    [self refreshBoard];
    
    // ...and calculate who won/lost
    [self gameOver];
}


// Game Center thinks it's time for us to make a move.
- (void) handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive
{
    assert(match.status == GKTurnBasedMatchStatusOpen);
    [self loadGameFromMatch:match];
}




///////////////////////////////////////////////////////////////////

- (id)init
{
    self = [super init];
    
    _audioWelcomePlayer = [Othello getPlayerForSound:@"welcome"];
    _audioThppPlayer = [Othello getPlayerForSound:@"thpp"];
    _audioWhoopPlayer = [Othello getPlayerForSound:@"whoop"];
    _audioYayPlayer = [Othello getPlayerForSound:@"yay"];
    _audioBooPlayer = [Othello getPlayerForSound:@"boo"];
    _audioNOPlayer = [Othello getPlayerForSound:@"no"];
    _audioHoldOnPlayer = [Othello getPlayerForSound:@"holdon"];
    _audioTiePlayer = [Othello getPlayerForSound:@"tie"];
    _audioYouLostPlayer = [Othello getPlayerForSound:@"youlost"];
    _audioComputerLostPlayer = [Othello getPlayerForSound:@"computerlost"];
    _audioNewGamePlayer = [Othello getPlayerForSound:@"newgame"];
    
    [_audioWelcomePlayer play];

    return self;
};

@end
