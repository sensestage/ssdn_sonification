// boot the audio engine:
// s.boot;

/// load directory of sound files:
~soundfilePaths = ( "".resolveRelative +/+ "hautecouture/*.wav" ).pathMatch;
~soundBuffers = ~soundfilePaths.collect{ |it| Buffer.read( s, it ) };

(
Ndef( \stereofileplayer1, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1).lag( 0.1, 1 ); } );
Ndef( \stereofileplayer1 ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer1 ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \stereofileplayer1 ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer1 ).addSpec( \rate, [ 1, 8.0, \exponential] );
Ndef( \stereofileplayer1 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer1 ).play;

Ndef( \stereofileplayer2, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1).lag( 0.1, 1 ); } );
Ndef( \stereofileplayer2 ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer2 ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \stereofileplayer2 ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer2 ).addSpec( \rate, [ 1, 8.0, \exponential] );
Ndef( \stereofileplayer2 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer2 ).play;

Ndef( \stereofileplayer3, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1).lag( 0.1, 1 ); } );
Ndef( \stereofileplayer3 ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer3 ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \stereofileplayer3 ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer3 ).addSpec( \rate, [ 1, 8.0, \exponential] );
Ndef( \stereofileplayer3 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer3 ).play;

Ndef( \stereofileplayer4, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1).lag( 0.1, 1 ); } );
Ndef( \stereofileplayer4 ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer4 ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \stereofileplayer4 ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer4 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer4 ).addSpec( \rate, [ 1, 8.0, \exponential] );
Ndef( \stereofileplayer4 ).play;

Ndef( \stereofileplayer5, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1).lag( 0.1, 1 ); } );
Ndef( \stereofileplayer1 ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer5 ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \stereofileplayer5 ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer5 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer5 ).addSpec( \rate, [ 1, 8.0, \exponential] );
Ndef( \stereofileplayer5 ).play;

Ndef( \stereofileplayer6, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1).lag( 0.1, 1 ); } );
Ndef( \stereofileplayer6 ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer6 ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \stereofileplayer6 ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer6 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer6 ).addSpec( \rate, [ 1, 8.0, \exponential] );
Ndef( \stereofileplayer6 ).play;


Ndef( \stereofileplayer7, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1).lag( 0.1, 1 ); } );
Ndef( \stereofileplayer7 ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer7 ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \stereofileplayer7 ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer7 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer7 ).addSpec( \rate, [ 1, 8.0, \exponential] );
Ndef( \stereofileplayer7 ).play;

Ndef( \stereofileplayer8, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1).lag( 0.1, 1 ); } );
Ndef( \stereofileplayer8 ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \stereofileplayer8 ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \stereofileplayer8 ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer8 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \stereofileplayer8 ).addSpec( \rate, [ 1, 8.0, \exponential] );
Ndef( \stereofileplayer8 ).play;
);

(
Ndef( \stereofileplayer1 ).set( \bufnum, ~soundBuffers[1].bufnum );
Ndef( \stereofileplayer2 ).set( \bufnum, ~soundBuffers[0].bufnum );
Ndef( \stereofileplayer3 ).set( \bufnum, ~soundBuffers[2].bufnum );
Ndef( \stereofileplayer4 ).set( \bufnum, ~soundBuffers[3].bufnum );
Ndef( \stereofileplayer5 ).set( \bufnum, ~soundBuffers[4].bufnum );
Ndef( \stereofileplayer6 ).set( \bufnum, ~soundBuffers[5].bufnum );
Ndef( \stereofileplayer7 ).set( \bufnum, ~soundBuffers[6].bufnum );
Ndef( \stereofileplayer8 ).set( \bufnum, ~soundBuffers[7].bufnum );
);

(
~fileOffs = [ true, true, true, true,  true, true, true, true ];
~fileThreshsholds = [0.99, 0.99, 0.99, 0.99,  0.99, 0.99, 0.99, 0.99];

~fileThreshsholds = Array.fill( 8, 0.8 )

// Ndef( \stereofileplayer1 ).set( \loop, 0 );

~checkTrigger.value( 0.9, 6.rand );
~checkTrigger.value( 1, 6.rand );

~checkTrigger = { |data, id|
	if ( data < ~fileThreshsholds[id] and: ~fileOffs[id] ){
		~fileOffs[id] = false;
		switch( id,
			0, {
				Ndef( \stereofileplayer1 ).set( \trig, 1 );
				Ndef( \stereofileplayer1 ).set( \amp, 1 );
			},
			1, {
				Ndef( \stereofileplayer2 ).set( \trig, 1 );
				Ndef( \stereofileplayer2 ).set( \amp, 1 );
			},
			2, {
				Ndef( \stereofileplayer3 ).set( \trig, 1 );
				Ndef( \stereofileplayer3 ).set( \amp, 1 );
			},
			3, {
				Ndef( \stereofileplayer4 ).set( \trig, 1 );
				Ndef( \stereofileplayer4 ).set( \amp, 1 );
			},
			4, {
				Ndef( \stereofileplayer5 ).set( \trig, 1 );
				Ndef( \stereofileplayer5 ).set( \amp, 1 );
			},
			5, {
				Ndef( \stereofileplayer6 ).set( \trig, 1 );
				Ndef( \stereofileplayer6 ).set( \amp, 1 );
			},
			6, {
				Ndef( \stereofileplayer7 ).set( \trig, 1 );
				Ndef( \stereofileplayer7).set( \amp, 1 );
			},
			7, {
				Ndef( \stereofileplayer8 ).set( \trig, 1 );
				Ndef( \stereofileplayer8 ).set( \amp, 1 );
			}
		);
	}{
		if ( data > (~fileThreshsholds[id]*1.05) ){
			~fileOffs[id] = true;
			switch( id,
				0, {
					Ndef( \stereofileplayer1 ).set( \trig, 1 );
					Ndef( \stereofileplayer1 ).set( \amp, 0 );
				},
				1, {
					Ndef( \stereofileplayer2 ).set( \trig, 1 );
					Ndef( \stereofileplayer2 ).set( \amp, 0 );
				},
				2, {
					Ndef( \stereofileplayer3 ).set( \trig, 1 );
					Ndef( \stereofileplayer3 ).set( \amp, 0 );
				},
				3, {
					Ndef( \stereofileplayer4 ).set( \trig, 1 );
					Ndef( \stereofileplayer4 ).set( \amp, 0 );
				},
				4, {
					Ndef( \stereofileplayer5 ).set( \trig, 1 );
					Ndef( \stereofileplayer5 ).set( \amp, 0 );
				},
				5, {
					Ndef( \stereofileplayer6 ).set( \trig, 1 );
					Ndef( \stereofileplayer6 ).set( \amp, 0 );
				},
				6, {
					Ndef( \stereofileplayer7 ).set( \trig, 1 );
					Ndef( \stereofileplayer7).set( \amp, 0 );
				},
				7, {
					Ndef( \stereofileplayer8 ).set( \trig, 1 );
					Ndef( \stereofileplayer8 ).set( \amp, 0 );
				}
			)
		};
	};
};
);

(
OSCdef( \tentacles, { |msg|
	if ( msg[1] == 4){
		msg.postln;
		[0,1,2,3].do{ |it|
			~checkTrigger.value( msg[ it+2 ], it );
		};
		Ndef( \stereofileplayer1 ).setUni( \rate, msg[2] );
		Ndef( \stereofileplayer2 ).setUni( \rate, msg[3] );
		Ndef( \stereofileplayer3 ).setUni( \rate, msg[4] );
		Ndef( \stereofileplayer4 ).setUni( \rate, msg[5] );
	};
	if ( msg[1] == 5){
		msg.postln;
		[0,1,2,3].do{ |it|
			~checkTrigger.value( msg[ it+2 ], it+4 );
		};
		Ndef( \stereofileplayer5 ).setUni( \rate, msg[2] );
		Ndef( \stereofileplayer6 ).setUni( \rate, msg[3] );
		Ndef( \stereofileplayer7 ).setUni( \rate, msg[4] );
		Ndef( \stereofileplayer8 ).setUni( \rate, msg[5] );
	};
}, "/minibee/data" );
);