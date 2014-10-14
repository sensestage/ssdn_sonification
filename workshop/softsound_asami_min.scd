// boot the audio engine:
s.boot;

NdefMixer.new(s);

(
/// load directory of sound files:
~yesAsamiPaths = ( "".resolveRelative +/+ "asami/yes*.wav" ).pathMatch;
~yesAsamiBuffers = ~yesAsamiPaths.collect{ |it| Buffer.read( s, it ) };
Ndef( \yesAsami, { PlayBuf.ar( 1, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \yesAsami ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \yesAsami ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \yesAsami ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \yesAsami ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \yesAsami ).set( \bufnum, ~yesAsamiBuffers[0].bufnum );
Ndef( \yesAsami ).set( \amp, 1 );
Ndef( \yesAsami ).play;
);

(
/// load directory of sound files:
~noAsamiPaths = ( "".resolveRelative +/+ "asami/no*.wav" ).pathMatch;
~noAsamiBuffers = ~noAsamiPaths.collect{ |it| Buffer.read( s, it ) };
Ndef( \noAsami, { PlayBuf.ar( 1, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \noAsami ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \noAsami ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \noAsami ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \noAsami ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \noAsami ).set( \bufnum, ~noAsamiBuffers[0].bufnum );
Ndef( \noAsami ).set( \amp, 1 );
Ndef( \noAsami ).play;
);


(
/// load directory of sound files:
~yesMinPaths = ( "".resolveRelative +/+ "min/yes*.wav" ).pathMatch;
~yesMinBuffers = ~yesMinPaths.collect{ |it| Buffer.read( s, it ) };
Ndef( \yesMin, { PlayBuf.ar( 1, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \yesMin ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \yesMin ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \yesMin ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \yesMin ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \yesMin ).set( \bufnum, ~yesMinBuffers[0].bufnum );
Ndef( \yesMin ).set( \amp, 1 );
Ndef( \yesMin ).play;
);

(
/// load directory of sound files:
~noMinPaths = ( "".resolveRelative +/+ "min/no*.wav" ).pathMatch;
~noMinBuffers = ~noMinPaths.collect{ |it| Buffer.read( s, it ) };
Ndef( \noMin, { PlayBuf.ar( 1, \bufnum.kr(0), \rate.kr(1), \trig.tr(1), 0, \loop.kr(0) ) * \amp.kr(0.1); } );
Ndef( \noMin ).addSpec( \amp, [ 0.05, 1, \exponential ] );
Ndef( \noMin ).addSpec( \bufnum, [ 0, 10, \linear, 1 ] );
Ndef( \noMin ).addSpec( \loop, [ 0, 1, \linear, 1 ] );
Ndef( \noMin ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \noMin ).set( \bufnum, ~noMinBuffers[0].bufnum );
Ndef( \noMin ).set( \amp, 1 );
Ndef( \noMin ).play;
);


// create streams of the different sound files - this picks one at random, but never the same twice in a row
~yesAsamiSequence = Pxrand( ~yesAsamiBuffers, inf ).asStream;
~noAsamiSequence = Pxrand( ~noAsamiBuffers, inf ).asStream;
~yesMinSequence = Pxrand( ~yesMinBuffers, inf ).asStream;
~noMinSequence = Pxrand( ~noMinBuffers, inf ).asStream;




//Ndef( \vocal, { RLPF.ar( LFPulse.ar( \lfrq.kr(20) * LFNoise2.kr(200,0.05,1), 0, \width.kr(0.2) ), \freq.kr(2000)*[1,5/4,3/2] * LFNoise2.kr(200, 0.05, 1 ), \rq.kr(0.1) ).sum * \amp.kr(0.1) * 0.2 / 3 } );

(
Ndef( \vocal1, {
	RLPF.ar(
		Formant.ar( \fundfreq.kr(440), \formfreq.kr( 1760 ), \bwfreq.kr(880), \amp.kr(0.1) );
		, \freq.kr(1000), \rq.kr(0.1)
	) * EnvGen.kr( Env.sine( \dur.kr(5 ) ), \gate.kr(1) );
})
);

(
Ndef( \vocal2, {
	RLPF.ar(
		Formant.ar( \fundfreq.kr(440), \formfreq.kr( 1760 ), \bwfreq.kr(880), \amp.kr(0.1) );
		, \freq.kr(1000), \rq.kr(0.1)
	) * EnvGen.kr( Env.sine( \dur.kr(5 ) ), \gate.kr(1) );
})
);


Ndef( \vocal1 ).play;
Ndef( \vocal2 ).play;



Ndef( \vocal ).set( \bwfreq, 1800, \freq, 2000  );
Ndef( \vocal ).set( \bwfreq, 600, \freq, 800  );

Ndef( \vocal ).set( \gate, 1 );
Ndef( \vocal ).set( \gate, 0 );



Ndef( \yesAsami ).set( \trig, 1, \bufnum, ~yesAsamiSequence.next.postln.bufnum );
Ndef( \noAsami ).set( \trig, 1, \bufnum, ~noAsamiSequence.next.postln.bufnum );
Ndef( \yesMin ).set( \trig, 1, \bufnum, ~yesMinSequence.next.postln.bufnum );
Ndef( \noMin ).set( \trig, 1, \bufnum, ~noMinSequence.next.postln.bufnum );


(
~count1 = 0;
~wasOn = false;
OSCdef( \minibee1, { |msg|
	if ( msg[1] == 1 ){
		if ( msg[3] > 0.3 ){ // touch threshold on: start counting
			~count1 = ~count1 + 1;
			~wasOn = true;
			if ( ~count1 > 50 ){ // long touch, play vocal sound
				Ndef( \vocal1 ).set( \fundfreq, rrand( 300, 500 ) );
				Ndef( \vocal1 ).set( \bwfreq, 1800, \freq, 2000  );
				Ndef( \vocal1 ).set( \gate, 1 );
				~count1 = 0;
			}{ // can retrigger
				Ndef( \vocal1 ).set( \gate, 0 );
			}
		}{ // under the touch threshold/no contact
			if ( ~wasOn and: ( ~count1 < 20 ) ){ // short touch - play sound, yes or no
				if ( 0.5.coin ){
					Ndef( \yesAsami ).set( \trig, 1, \bufnum, ~yesAsamiSequence.next.postln.bufnum );
				}{
					Ndef( \noAsami ).set( \trig, 1, \bufnum, ~noAsamiSequence.next.postln.bufnum );
				};
			};
			~wasOn = false;
			~count1 = 0;
		};
	};
}, "/minibee/data" );
);



(
~count2 = 0;
~wasOn2 = false;
OSCdef( \minibee2, { |msg|
	if ( msg[1] == 2 ){
		if ( msg[3] > 0.3 ){ // touch threshold on: start counting
			~count2 = ~count2 + 1;
			~wasOn = true;
			if ( ~count2 > 50 ){ // long touch, play vocal sound
				Ndef( \vocal2 ).set( \fundfreq, rrand( 300, 500 ) );
				Ndef( \vocal2 ).set( \bwfreq, 1800, \freq, 2000  );
				Ndef( \vocal2 ).set( \gate, 1 );
				~count2 = 0;
			}{ // can retrigger
				Ndef( \vocal2 ).set( \gate, 0 );
			}
		}{ // under the touch threshold/no contact
			if ( ~wasOn2 and: ( ~count2 < 20 ) ){ // short touch - play sound, yes or no
				if ( 0.5.coin ){
					Ndef( \yesMin ).set( \trig, 1, \bufnum, ~yesMinSequence.next.postln.bufnum );
				}{
					Ndef( \noMin ).set( \trig, 1, \bufnum, ~noMinSequence.next.postln.bufnum );
				};
			};
			~wasOn2 = false;
			~count2 = 0;
		};
	};
}, "/minibee/data" );
);