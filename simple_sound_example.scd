// start pydongui (if not already running):
("cd" + "".resolveRelative ++ "; pydongui.py").runInTerminal;

// boot the audio engine - if it is not already running:
s.boot;

// create the GUI for sounds:
NdefMixer.new( s );


// definition of the sound:
Ndef( \sineOsc, { SinOsc.ar( \freq.kr( 200 ), 0, \amp.kr(0.1) ); } );
Ndef( \sineOsc ).addSpec( \freq, [ 400, 1000, \exponential ] ); // sets the range for the frequency
Ndef( \sineOsc ).addSpec( \amp, [ 0.05, 1, \exponential ] );    // sets the range for the amplitude
Ndef( \sineOsc ).play; // start playback

// create an OSC receiver to map the incoming data to the sound parameters:
(
OSCdef( \minibeeSound, { |msg|
	Ndef( \sineOsc ).setUni( \freq, 1-msg[2] ); // map from 0 to 1, to the range of the frequency
}, "/minibee/data" );
);

// stop the sound playback:
Ndef( \sineOsc ).stop;
// remove the osc receiver:
OSCdef( \minibeeSound ).free;


// create a percussive sound that can be triggered by the data:

Ndef( \percussiveSineOsc, { SinOsc.ar( \freq.kr( 600 ), 0, \amp.kr(0.1) ) * EnvGen.kr( Env.perc, \gate.kr(0) + \trig.tr(1), timeScale: \dur.kr( 0.2 ) ); } );
Ndef( \percussiveSineOsc ).addSpec( \freq, [ 400, 5000, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \dur, [ 0.05, 1, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \gate, [ 0, 1, \linear, 1 ] );
Ndef( \percussiveSineOsc ).addSpec( \trig, [ 0, 1, \linear, 1 ] );

Ndef( \percussiveSineOsc ).play;
Ndef( \percussiveSineOsc ).set( \amp, 1 ); // change the volume

// trig just needs a positive value once, and will reset itself to zero, so it can be retriggered
Ndef( \percussiveSineOsc ).set( \trig, 1 ); // testing

// trigger again:
Ndef( \percussiveSineOsc ).set( \trig, 1 ); // testing

// gate needs to be manually reset, after it is set to 1
Ndef( \percussiveSineOsc ).set( \gate, 1 );

// reset gate to 0:
Ndef( \percussiveSineOsc ).set( \gate, 0 ); // testing

// trigger again by setting gate to 1:
Ndef( \percussiveSineOsc ).set( \gate, 1 );

// reset gate to 0:
Ndef( \percussiveSineOsc ).set( \gate, 0 ); // testing


// open the gate when value is above a certain threshold, and use the value as the frequency for the note:
(
OSCdef( \minibeeSoundTrigger, { |msg|
	Ndef( \percussiveSineOsc ).setUni( \freq, msg[3] );
	if ( msg[3] > 0.5 ){ // threshold trigger
		msg[3].postln;
		Ndef( \percussiveSineOsc ).set( \gate, 1 );
	}{
		Ndef( \percussiveSineOsc ).set( \gate, 0 );
	};
}, "/minibee/data" );
);

// stop the interaction
OSCdef( \minibeeSoundTrigger ).free;
