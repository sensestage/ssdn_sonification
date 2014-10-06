// boot the audio engine - if it is not already running:
s.boot;

// create the GUI for sounds:
NdefMixer.new( s );

// view and analyse the incoming data:
c = SignalCharacterics.new( 1000 );
c.makeGui;

// receive the OSC data:
(
OSCdef( \minibeePost, { |msg|
	msg.postln;
}, "/minbee/data" );
);
(
OSCdef( \minibeeSignal, { |msg|
	c.addValue( msg[2] ); // first data point - our analog sensor data: range will be between 0 and 1
}, "/minbee/data" );
);



Ndef( \sineOsc, { SinOsc.ar( \freq.kr( 200 ), 0, \amp.kr(0.1) ); } );
Ndef( \sineOsc ).addSpec( \freq, [ 400, 5000, \exponential ] );
Ndef( \sineOsc ).addSpec( \amp, [ 0.05, 1, \exponential ] );

(
OSCdef( \minibeeSound, { |msg|
	Ndef( \sineOsc ).setUni( \freq, msg[2] ); // map from 0 to 1, to the range of the frequency
}, "/minbee/data" );
);


Ndef( \percussiveSineOsc, { SinOsc.ar( \freq.kr( 600 ), 0, \amp.kr(0.1) ) * EnvGen.kr( Env.perc, \trig.tr(1), timeScale: \dur.kr( 0.2 ) ); } );
Ndef( \percussiveSineOsc ).addSpec( \freq, [ 400, 5000, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \dur, [ 0.05, 1, \exponential ] );
Ndef( \percussiveSineOsc ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \percussiveSineOsc ).play;
Ndef( \percussiveSineOsc ).set( \trig, 1 );

// read in a soundfile:
b = Buffer.read( s, "/home/nescivi/git/steim/steim_vanboeijen/supercollider/samples/ritme1/HAT CLOSED SAMPLE.wav" );
Ndef( \fileplayer ).set( \bufnum, b.bufnum );

Ndef( \fileplayer, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \fileplayer ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \fileplayer ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \fileplayer ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \fileplayer ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \fileplayer ).play;
Ndef( \fileplayer ).set( \trig, 1 );
