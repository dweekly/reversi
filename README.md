isreveR
=======

A Reversi iOS Game.

I intially wrote this in a few hours as my first iOS application
myself iOS programming. This is probably NOT a good place for you
to teach yourself how to code for iOS because I probably did
everything wrong.

The AI is still extremely rudimentary; it simply picks a valid
move that will result in taking the most number of pieces in
the next move.

There isn't GameCenter integration, music, two player / network
mode, or anything. It's all quite basic, but it works. :)

v0.01 (Dec 5, 2012)
 - basic version working, rudimentary AI, iPhone 5 only

v0.02 (Dec 6, 2012)
 - added crude sound effects, now works on iPhone4/4S

v0.03 (Dec 15, 2012)
 - added iPad support & hi-res stones
 - added code for Shoutcast music streaming via AudioStreamer library (but is annoying, so disabled)
 - code tidying
 
v0.04 (Dec 15, 2012)
 - verified working with iPad retina, added default loading images.
 - updated felt textures
 - fixed bug which made dumb AI even dumber, whoops.
 
v0.05 (Dec 15, 2012)
 - Refactored logic from UIView object
 - Added Flurry integration

v0.06 (Dec 16, 2012)
 - Added TestFlight (though this does slow 1st load)
 - Better refactoring without crazy timing issues.
 - Added modularity to allow for different AIs
 - Smoother, subtler board lines
 
v0.07 (Dec 16, 2012)
 - Add in-app purchasing for more advanced AI

v0.08 (Dec 18, 2012)
 - Apply MP3 compression to reduce overall bundle size (23M -> 17M)
 - Target iOS 5.0 to cover a wider range of users
 - Update screenshots
 
v0.09 (Jan 8, 2013)
 - New visual flow to select an opponent/AI
 - Visual status on turn
 - Add half-functioning Game Center matching and play (disabled)

v0.10 (Jan 10, 2013)
 - Minimax (expert) AI actually implemented!

v0.11 (Jan 11, 2013)
 - Incorporated more sophisticated board evaluation function for superior expert play.

v0.12 (Feb 4, 2013)
 - Removed GameCenter play in order to prep for MVP launch
 - This version launched in the App Store!

v0.13 (Feb 16, 2013)
 - Easy and Medium modes are now substantially more challenging.
 - Recompressed board assets (PNG->JPG) to reduce app size from 12MB to 5MB
 - Removed unused AudioStreamer library
 - Fully disable GameCenter to prevent a rare crash (and we weren't really using GC anyhow)
 - Make green text much easier to read for upgrade

TODOs:
 - fix Game Center / multiplayer
 - beautiful Tamiko skins?
 - visual indicator of permissible moves
 - gameplay instructions
 - support rotation?
 - animations?
 - alter modal views to regular sliding views?
 - keep tally of wins/losses
 - add achievements
 - Allow for 3rd parties to sell AIs(!)
 - update negamax to negascout, add more plys, add move search ordering, transposition tables
 - incorporate opening move tables
 - use genetic algorithms to fine-tune evaluation function
 - incorporate edax for ULTRA difficulty level (note: GPL)
 - incorporate TD-Lambda? http://www.research.ibm.com/massive/tdl.html
