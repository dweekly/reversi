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
 - Added TestFlight (though this does significantly slow 1st load)
 - Better refactoring without crazy timing issues.

TODOs:
 - sophisticated minmix AI with multilevel lookahead
 - welcome screen with instructions
 - support rotation
 - animations
 - GameCenter / multiplayer
