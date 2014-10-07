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

// change the frequency range:
Ndef( \sineOsc ).addSpec( \freq, [ 600, 9000, \exponential ] ); // sets the range for the frequency

Ndef( \sineOsc ).addSpec( \freq, [ 200, 2000, \exponential ] ); // sets the range for the frequency

Ndef( \sineOsc ).addSpec( \freq, [ 400, 5000, \exponential ] ); // sets the range for the frequency


// make the transitions more smooth with .lag
Ndef( \sineOsc, { SinOsc.ar( \freq.kr( 200 ).lag(0.5), 0, \amp.kr(0.1) ); } );

// make the lag controllable:
Ndef( \sineOsc, { SinOsc.ar( \freq.kr( 200 ).lag( \lag.kr(0.5) ), 0, \amp.kr(0.1) ); } );
Ndef( \sineOsc ).addSpec( \lag, [ 0.05, 1, \exponential ] );    // sets the range for the lag

// change the lag with the pressure
(
OSCdef( \minibeeSound, { |msg|
	Ndef( \sineOsc ).setUni( \freq, msg[3] ); // map from 0 to 1, to the range of the frequency
	Ndef( \sineOsc ).setUni( \lag, msg[3] ); // map from 0 to 1, to the range of the lag
}, "/minibee/data" );
);


(
OSCdef( \minibeeSound, { |msg|
	Ndef( \sineOsc ).setUni( \freq, msg[3] ); // map from 0 to 1, to the range of the frequency
	Ndef( \sineOsc ).setUni( \lag, msg[3] ); // map from 0 to 1, to the range of the lag
	Ndef( \sineOsc ).setUni( \amp, 1-msg[3] ); // map from 0 to 1, to the range of the amp
}, "/minibee/data" );
);

// also lag the amplitude
Ndef( \sineOsc, { SinOsc.ar( \freq.kr( 200 ).lag( \lag.kr(0.5) ), 0, \amp.kr(0.1).lag( \lag.kr(0.5) ) ); } );

(
// threshold the amplitude
OSCdef( \minibeeSound, { |msg|
	Ndef( \sineOsc ).setUni( \freq, msg[3] ); // map from 0 to 1, to the range of the frequency
	Ndef( \sineOsc ).setUni( \lag, msg[3] ); // map from 0 to 1, to the range of the lag
	if ( msg[3] < 0.3 ){
		Ndef( \sineOsc ).setUni( \amp, 1-msg[3] ); // map from 0 to 1, to the range of the amp
	}{
		Ndef( \sineOsc ).set( \amp, 0 ); // map from 0 to 1, to the range of the amp
	}
}, "/minibee/data" );
);

// also lag the amplitude, but with a different fadeout
Ndef( \sineOsc, { SinOsc.ar( \freq.kr( 200 ).lag( \lag.kr(0.5) ), 0, \amp.kr(0.1).lag( \lag.kr(0.5), \decay.kr(2) ) ); } );
Ndef( \sineOsc ).addSpec( \decay, [ 0.05, 4, \exponential ] );    // sets the range for the decay


(
// threshold the amplitude
OSCdef( \minibeeSound, { |msg|
	Ndef( \sineOsc ).setUni( \freq, msg[3] ); // map from 0 to 1, to the range of the frequency
	Ndef( \sineOsc ).setUni( \lag, msg[3] ); // map from 0 to 1, to the range of the lag
	if ( msg[3] < 0.3 ){
		Ndef( \sineOsc ).setUni( \amp, 1-msg[3] ); // map from 0 to 1, to the range of the amp
		Ndef( \sineOsc ).setUni( \decay, 1-msg[3] ); // map from 0 to 1, to the range of the decay
	}{
		Ndef( \sineOsc ).set( \amp, 0 ); // map from 0 to 1, to the range of the amp
	}
}, "/minibee/data" );
);
