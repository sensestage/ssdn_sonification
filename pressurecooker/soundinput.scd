(
Ndef( \soundInput, {
	var input = SoundIn.ar( 0 );
	var pitch = PitchShift.ar( DelayN.ar( input, 1, 0.05 ), 0.2, LFNoise1.kr( \lffreq1.kr(100), \lfmul1.kr(0.1), 0.9 ), LFNoise1.kr( \lffreq2.kr(100), \lfmul2.kr(0.1), 1 ), LFNoise1.kr( \lffreq3.kr(100), \lfmul3.kr(0.1), 1 ) );
	FreeVerb.ar(
		(\dry.kr(0.8)*input) + (\wet.kr(0.2) * pitch ),
		\mix.kr(0.6), \room.kr(0.6), \damp.kr(0.7)
	);
} );
);

Ndef( \soundInput, { SoundIn.ar( 0 ) } );

Ndef( \soundInput ).addSpec( \dry, [0,1.0 ] );
Ndef( \soundInput ).addSpec( \wet, [0,1.0 ] );

Ndef( \soundInput ).addSpec( \lffreq1, [1, 20, \exponential ] );
Ndef( \soundInput ).addSpec( \lffreq2, [1, 20, \exponential ] );
Ndef( \soundInput ).addSpec( \lffreq3, [1, 20, \exponential ] );

Ndef( \soundInput ).addSpec( \lfmul1, [0.001,0.1, \exponential ] );
Ndef( \soundInput ).addSpec( \lfmul2, [0.001,0.1, \exponential ] );
Ndef( \soundInput ).addSpec( \lfmul3, [0.001,0.1, \exponential ] );
