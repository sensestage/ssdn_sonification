"pydongui.py".runInTerminal;

// boot the audio engine - if it is not already running:
s.boot;

// create the GUI for sounds:
NdefMixer.new( s );


// receive the OSC data:
(
OSCdef( \minibeePost, { |msg|
	msg.postln;
}, "/minibee/data" );
);

// stop posting:
OSCdef( \minibeePost ).free;

// view and analyse the incoming data:
c = SignalCharacterics.new( 1000 );
c.makeGui;

(
OSCdef( \minibeeSignal, { |msg|
	c.addValue( msg[3] ); // first data point - our analog sensor data: range will be between 0 and 1
}, "/minibee/data" );
);

// definition of the sound:
Ndef( \sineOsc, { SinOsc.ar( \freq.kr( 200 ), 0, \amp.kr(0.1) ); } );
Ndef( \sineOsc ).addSpec( \freq, [ 400, 5000, \exponential ] ); // sets the range for the frequency
Ndef( \sineOsc ).addSpec( \amp, [ 0.05, 1, \exponential ] );    // sets the range for the amplitude
Ndef( \sineOsc ).play; // start playback

(
OSCdef( \minibeeSound, { |msg|
	Ndef( \sineOsc ).setUni( \freq, msg[3] ); // map from 0 to 1, to the range of the frequency
}, "/minibee/data" );
);


Ndef( \sineOsc ).stop;
OSCdef( \minibeeSound ).free;

Ndef( \percussiveSineOsc, { SinOsc.ar( \freq.kr( 600 ), 0, \amp.kr(0.1) ) * EnvGen.kr( Env.perc, \gate.kr(1), timeScale: \dur.kr( 0.2 ) ); } );
Ndef( \percussiveSineOsc ).addSpec( \freq, [ 400, 5000, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \dur, [ 0.05, 1, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \gate, [ 0, 1, \linear, 1 ] );

Ndef( \percussiveSineOsc ).play;
Ndef( \percussiveSineOsc ).set( \amp, 1 ); // testing
Ndef( \percussiveSineOsc ).set( \gate, 0 ); // testing
Ndef( \percussiveSineOsc ).set( \gate, 1 ); // testing

(
OSCdef( \minibeeSoundTrigger, { |msg|
	if ( msg[3] > 0.8 ){ // threshold trigger
		msg[3].postln;
		Ndef( \percussiveSineOsc ).set( \gate, 1 );
	}{
		Ndef( \percussiveSineOsc ).set( \gate, 0 );
	};
}, "/minibee/data" );
);
// stop the interaction
OSCdef( \minibeeSoundTrigger ).free;


// read in a soundfile:
b = Buffer.read( s, "/home/nescivi/git/steim/steim_vanboeijen/supercollider/samples/ritme1/HAT CLOSED SAMPLE.wav" );
Ndef( \fileplayer ).set( \bufnum, b.bufnum );

Ndef( \fileplayer, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \fileplayer ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \fileplayer ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \fileplayer ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \fileplayer ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \fileplayer ).play;
Ndef( \fileplayer ).set( \amp, 5 );

Ndef( \fileplayer ).set( \trig, 1 );

(
OSCdef( \minibeeSoundTrigger, { |msg|
	if ( msg[3] > 0.8 ){ // threshold trigger
		Ndef( \fileplayer ).set( \trig, 1 );
	};
}, "/minibee/data" );
);

// stop the interaction
OSCdef( \minibeeSoundTrigger ).free;

(
OSCdef( \minibeeSoundLoop, { |msg|
	if ( msg[3] > 0.8 ){ // looping
		Ndef( \fileplayer ).set( \loop, 1 );
	}{
		Ndef( \fileplayer ).set( \loop, 0 );
	};
}, "/minibee/data" );
);

// stop the interaction
OSCdef( \minibeeSoundLoop ).free;

// free all interaction
OSCdef.freeAll;