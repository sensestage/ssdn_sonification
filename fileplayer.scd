// read in a soundfile:

(
Dialog.openPanel( { |file|
	if ( b.notNil ){ b.free };
	b = Buffer.read( s, file );
	Ndef( \fileplayer ).set( \bufnum, b.bufnum );
} );
);

Ndef( \fileplayer, { PlayBuf.ar( 2, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \fileplayer ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \fileplayer ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \fileplayer ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \fileplayer ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \fileplayer ).play;
Ndef( \fileplayer ).set( \amp, 10 );

Ndef( \fileplayer ).set( \trig, 1 );

(
OSCdef( \minibeeSoundTrigger, { |msg|
	if ( msg[3] > 0.5 ){ // threshold trigger
		Ndef( \fileplayer ).set( \trig, 1 );
	};
}, "/minibee/data" );
);

// stop the interaction
OSCdef( \minibeeSoundTrigger ).free;

(
OSCdef( \minibeeSoundLoop, { |msg|
	if ( msg[3] > 0.4 ){ // looping
		Ndef( \fileplayer ).set( \loop, 1 );
	}{
		Ndef( \fileplayer ).set( \loop, 0 );
	};
}, "/minibee/data" );
);

// stop the interaction
OSCdef( \minibeeSoundLoop ).free;

