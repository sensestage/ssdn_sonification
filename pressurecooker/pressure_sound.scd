//s.boot;

// Ndef( \pressure ).clear;
(
// definition of the sound:
Ndef( \pressure, {
	var rlpf, formant, decay;
	rlpf = RLPF.ar( Impulse.ar( \rate.kr( 10 ) ), \freq.kr(500), \rq.kr(0.1) );
	// decay = Decay.ar( Dust2.ar( \dens.kr( 10 ) ), \decay.kr(0.5) );
	formant = Formant.ar( \funfreq.kr( 300 ), \ffreq.kr(2000), \bwfreq.kr(800) );
	Pan2.ar( rlpf * formant * 2, \pos.kr(0) );
});

);
(
// Ndef( \pressure ).play( 1 );
Ndef( \pressure ).addSpec( \rate, [10,100,\exponential].asSpec );
Ndef( \pressure ).addSpec( \dens, [10,100,\exponential].asSpec );
Ndef( \pressure ).addSpec( \decay, [0.01,0.5,\exponential].asSpec );
Ndef( \pressure ).addSpec( \freq, [50,100,\exponential].asSpec );
Ndef( \pressure ).addSpec( \rq, [0.01,0.3,\exponential].asSpec );
Ndef( \pressure ).addSpec( \funfreq, [20,500,\exponential].asSpec );
Ndef( \pressure ).addSpec( \ffreq, [1000,3000,\exponential].asSpec );
Ndef( \pressure ).addSpec( \bwfreq, [100,200,\exponential].asSpec );
Ndef( \pressure ).addSpec( \fmfreq, [ 5, 400, \exponential ] ); // sets the range for the frequency

Ndef( \pressure ).addSpec( \pos, [ -1,1,\linear ] ); // sets the range for the frequency

Ndef( \pressure ).play; // start playback
);

(
~influx = Influx( [\p1,\p2,\p3], [\a,\b,\c,\d,\e,\f], (p1: 0, p2: 0, p3: 0 ) );
InfluxIOWGui( ~influx );
InfluxKtlGui( ~influx );

~influx.attachMapped( Ndef( \pressure ) );
);

(
~pressSpec1 = [ 0.2, 0.7 ].asSpec;
~pressSpec2 = [ 0.6, 0.9 ].asSpec;
~pressSpec3 = [ 0.2, 0.5 ].asSpec;
);


(
OSCdef( \pressure, { |msg|
	// msg.postln;
	if ( msg[1] == 1 ){
		// msg.postln;
		~influx.set( \p1, ~pressSpec1.unmap( msg[2] ) );
	};
	if ( msg[1] == 2 ){
		~influx.set( \p2, ~pressSpec2.unmap( msg[2] ) );
	};
	if ( msg[1] == 3 ){
		~influx.set( \p3, ~pressSpec3.unmap( msg[2] ) );
	};
}, "/minibee/data" );
);

// NdefMixer.new( s );