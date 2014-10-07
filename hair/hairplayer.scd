"pydongui.py".runInTerminal;

// boot the audio engine:
s.boot;

/// load directory of sound files:
~soundfilePaths = ( "".resolveRelative +/+ "*.wav" ).pathMatch.sort;

// load the file paths into buffers on the server
~soundBuffers = ~soundfilePaths.collect{ |it| Buffer.read( s, it ) };

( // create the file player:
Ndef( \stereofileplayer, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \stereofileplayer ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer ).addSpec( \bufnum, [ 0, 15, \linear, 1 ] ); // 16 buffers in total
Ndef( \stereofileplayer ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer ).addSpec( \rate, [ 1, 2, \linear ] );
Ndef( \stereofileplayer ).play;

Ndef( \stereofileplayer ).set( \bufnum, ~soundBuffers[0].bufnum );
Ndef( \stereofileplayer ).set( \amp, 1 );
);

// just test if it plays
Ndef( \stereofileplayer ).set( \trig, 1 );


~resistanceRange = [0.5, 1].asSpec; // the range which selects which file is played, i.e. where in the poem we are
~lastTime = Main.elapsedTime; // this tracks the last time we change the file position.

(
OSCdef( \minibeeSound, { |msg,time|
	if ( msg[3] < 1 ){
		if ( time - ~lastTime > 3 ){
			"play and change soundfile".postln;
			Ndef( \stereofileplayer ).setUni( \bufnum, (1-~resistanceRange.unmap( msg[3] )).postln; );
			Ndef( \stereofileplayer ).set( \trig, 1 );
			~lastTime = Main.elapsedTime;
		};
		if ( msg[3] < 0.4 ){
			Ndef( \stereofileplayer ).setUni( \rate, msg[3]*2 );
		}{
			Ndef( \stereofileplayer ).set( \rate, 1 );
		}
	}
}, "/minibee/data" );
);
