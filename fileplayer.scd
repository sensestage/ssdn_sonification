// start pydongui (if not already running):
("cd" + "".resolveRelative ++ "; pydongui.py").runInTerminal;

// boot the audio engine - if it is not already running:
s.boot;

// create the GUI for sounds:
NdefMixer.new( s );


// define the fileplayer:
(
Ndef( \fileplayer, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(1).lag(0.1,1); } );
Ndef( \fileplayer ).addSpec( \amp, [ 0.05, 2, \exponential ] );
Ndef( \fileplayer ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \fileplayer ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \fileplayer ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
);

// read in a stereo soundfile by selecting it with a dialog:
(
Dialog.openPanel( { |file|
	if ( b.notNil ){ b.free };
	b = Buffer.read( s, file );
	Ndef( \fileplayer ).set( \bufnum, b.bufnum );
} );
);

// start playback of the sound:
Ndef( \fileplayer ).play;


// trigger the sound once:
Ndef( \fileplayer ).set( \trig, 1 );

// trigger playback of the soundfile is the value is larger than a particular threshold:
(
OSCdef( \minibeeSoundTrigger, { |msg|
	if ( msg[3] > 0.5 ){ // threshold trigger
		Ndef( \fileplayer ).set( \trig, 1 );
	};
}, "/minibee/data" );
);

// stop the interaction
OSCdef( \minibeeSoundTrigger ).free;

// using the looping function, the file playback can be looped:
Ndef( \fileplayer ).set( \loop, 1 );

// with trigger it is started, and will keep looping:
Ndef( \fileplayer ).set( \trig, 1 );

// setting loop to 0 again, will stop the looping, the sound will keep playing until the soundfile has ended:
Ndef( \fileplayer ).set( \loop, 0 );

// let the soundfile loop while the incoming data is above the threshold:
(
OSCdef( \minibeeSoundLoop, { |msg|
	if ( msg[3] > 0.4 ){ // looping
		Ndef( \fileplayer ).set( \loop, 1 );
	}{
		Ndef( \fileplayer ).set( \loop, 0 );
	};
}, "/minibee/data" );
);


// let the soundfile loop while the incoming data is above the threshold, fade the sound playback out when the value is under the threshold
(
OSCdef( \minibeeSoundLoop, { |msg|
	if ( msg[3] > 0.4 ){ // looping
		Ndef( \fileplayer ).set( \loop, 1 );
		Ndef( \fileplayer ).set( \amp, 1 );
	}{
		Ndef( \fileplayer ).set( \loop, 0 );
		Ndef( \fileplayer ).set( \amp, 0 );
	};
}, "/minibee/data" );
);

// stop the interaction
OSCdef( \minibeeSoundLoop ).free;

