// boot the audio engine:
s.boot;

/// load directory of sound files:
~soundfilePaths = ( "".resolveRelative +/+ "*.wav" ).pathMatch;

~soundBuffers = ~soundfilePaths.collect{ |it| Buffer.read( s, it ) };

Ndef( \stereofileplayer, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \stereofileplayer ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer ).addSpec( \bufnum, [ 0, 15, \linear, 1 ] ); // 16 buffers in total
Ndef( \stereofileplayer ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer ).play;

Ndef( \stereofileplayer ).set( \bufnum, ~soundBuffers[0].bufnum );

~resistanceRange = [0.05, 0.8].asSpec;
~lastTime = Main.elapsedTime;

(
OSCdef( \minibeePost, { |msg,time|
	msg.postln;
	if ( time - ~lastTime > 4 ){
		Ndef( \stereofileplayer ).setUni( ~resistanceRange.unmap( msg[3] ); );
		Ndef( \stereofileplayer ).set( \trig, 1 );
		~lastTime = Main.elapsedTime;
	};
}, "/minibee/data" );
);