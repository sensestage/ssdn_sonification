// SuperCollider introduction

// two parts: programming language + audio engine

// in the editor you execute code by pressing [shift] + [enter] on the line you want to execute:
"this line of code is executed now".postln;

// with [ctr]/[cmd] + [enter] you execute a block of code:
(
"this block of code is now executed".postln;
"multiple lines".postln;
"the output of the last one is printed".postln;
);

// you can start the audio engine with:
s.boot;

// you can create a sound like this:
Ndef( \sineOsc, { SinOsc.ar( \freq.kr( 500 ), 0, \amp.kr(0.1) ); } );
// and play it:
Ndef( \sineOsc ).play;

// and change the frequency:
Ndef( \sineOsc ).set( \freq, 600 );

// and change the amplitude:
Ndef( \sineOsc ).set( \amp, 0.05 );

// and stop the sound:
Ndef( \sineOsc ).stop;

// and create a GUI for the sounds that play:
NdefMixer.new( s );