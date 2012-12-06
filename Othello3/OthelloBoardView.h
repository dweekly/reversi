//
//  OthelloBoardView.h
//  Othello3
//
//  Created by David E. Weekly on 12/5/12.
//  Copyright (c) 2012 David E. Weekly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface OthelloBoardView : UIView <UIAlertViewDelegate>

@property (strong, nonatomic) UIImage *blackpiece;
@property (strong, nonatomic) UIImage *whitepiece;
@property (strong, nonatomic) UIImage *felt;
@property (strong, nonatomic) AVAudioPlayer *audioWelcomePlayer;
@property (strong, nonatomic) AVAudioPlayer *audioThppPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioWhoopPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioYayPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioBooPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioNOPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioHoldOnPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioTiePlayer;
@property (strong, nonatomic) AVAudioPlayer *audioYouLostPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioComputerLostPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioNewGamePlayer;
@end
