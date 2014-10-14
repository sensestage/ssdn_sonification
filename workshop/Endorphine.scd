/*
Endorphine
2 shirt-like garments.

There is a soundfile that is looping at full volume.
In the first garment, when someone hugs the wearer the volume decreases to 0.
In the second garment, when someone strokes the back of the wearer for a period of time the volume decreases to 0.

*/
// start pydongui:
("cd" + "".resolveRelative ++ "; pydongui.py").runInTerminal;

// Start the synthesis server
s.boot;

// Run this code to choose your sample file
// Dialog.openPanel({|file| ~samplebuf = Buffer.read(s, file)}); // make sure the sample is stereo!

// this assumes that the sound files are in a folder "endorphine" relative to this file!
~samplebuf1 = Buffer.read( s, "".resolveRelative +/+ "endorphine/music_4.wav" );
~samplebuf2 = Buffer.read( s, "".resolveRelative +/+ "endorphine/grasgeluid.wav" );

(
// Configure the sample playback engine
Ndef( \sampler, {
	PlayBuf.ar( 2, \buf.kr(0), \rate.kr(1), \trig.tr(0), \start.kr(0), \loop.kr(0) ) * LagUD.kr(\amp.kr(0.1),2,5);
});
Ndef( \sampler ).addSpec( \amp, [0.05, 0.5, \exponential] );
Ndef( \sampler ).addSpec( \buf, [ 0, 10, \linear, 1 ] );
Ndef( \sampler ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \sampler ).set(\buf, ~samplebuf1.bufnum);
Ndef( \sampler ).set( \amp, 0.5 );
Ndef( \sampler ).set( \loop, 1 );
Ndef( \sampler ).play;
Ndef( \sampler ).set(\trig, 1);
);

(
// Configure the sample playback engine
Ndef( \grassampler, {
	PlayBuf.ar( 2, \buf.kr(0), \rate.kr(1), \trig.tr(0), \start.kr(0), \loop.kr(0) ) * LagUD.kr(\amp.kr(0.1),2,5);
});
Ndef( \grassampler ).addSpec( \amp, [0.05, 0.5, \exponential] );
Ndef( \grassampler ).addSpec( \buf, [ 0, 10, \linear, 1 ] );
Ndef( \grassampler ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \grassampler ).set(\buf, ~samplebuf2.bufnum);
Ndef( \grassampler ).set( \amp, 0.5 );
Ndef( \grassampler ).set( \loop, 1 );
Ndef( \grassampler ).play;
Ndef( \grassampler ).set(\trig, 1);
)


/// elk punt druk: geluid uit
/// wrijft : over meerdere punten druk, dan grasgeluid

Ndef( \sampler ).addSpec( \amp, [0.05, 0.5, \exponential] ); // range van de amplitude: geen druk 0.5, veel druk 0.05

(
// Interaction for hug to control volume
OSCdef(\hug, {|msg|
	var data,grasdata;
	if ( msg[1] == 1 ){ // voor minibee 1
		/// endorphine geluid
		data = msg.sum/6; // delen door 6, want 6 druk punten
		postln( "totale druk:" + data ); // data wordt lager bij meer druk
		if ( data > 0.1 ){ // grenswaarde waaronder het geluid helemaal weg gaat
			Ndef(\sampler).setUni(\amp, data); // amplitude wordt lager bij meer druk
		}{
			Ndef(\sampler).set(\amp, 0); // onder de threshold, geluid helemaal uit
		};
		// gras geluid
		grasdata = (msg < 0.4).collect{ |it| it.binaryValue }.sum; // geeft aan hoeveel van de druk punten ingedrukt
		if ( grasdata > 1 ){ // meer dan een drukpunt
			Ndef( \grassampler ).set( \loop, 1 ); // start playback
			Ndef( \grassampler ).set( \amp, 1 );  // en vol volume
		}{
			Ndef( \grassampler ).set( \loop, 0 ); // stop loop
			Ndef( \grassampler ).set( \amp, 0 );  // volume uit - hij fade out over 5 sec.
		}
	};
}, "/minibee/data");
);




/// not working yet:

// Stroking activity controls volume
// Standard dev of the past 100 datapoints (about 5 seconds).. larger stdv = lower volume

// geen aanraking -> ene geluid, ander geluid uit
// aanraking/aaien -> ander geluid, eerste geluid uit

~signalData = SignalCharacteristics.new( 100 );
~signalData.addValue( 0 );

(
OSCdef(\stroking, {|msg|
	var data = msg[2];
	if ( msg[1] == 2 ){
		~signalData.addValue( msg[2] );
		~signalData.stdDev.postln;
	};
}, "/minibee/data" );
);