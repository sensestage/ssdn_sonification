/*
Walking through a sample bank.

Direction of walk can be changed.

Parallel sample banks can be selected.
*/

s.boot;

// For each sample bank create a new entry in b. Parallel samples should be named identically.
b = ();
~path = ( "".resolveRelative +/+ "word1/words1_wav/*.wav" ).pathMatch.sort;
b[0] = ~path.collect{ |it| Buffer.read( s, it ) }; // bank 0
~path = ( "".resolveRelative +/+ "word2/words2_wav/*.wav" ).pathMatch.sort;
b[1] = ~path.collect{ |it| Buffer.read( s, it ) }; // bank 1
~path = ( "".resolveRelative +/+ "word3/words3_wav/*.wav" ).pathMatch.sort;
b[2] = ~path.collect{ |it| Buffer.read( s, it ) }; // bank 1

(
// Create the sample playback synth
Ndef( \sampler, {
	PlayBuf.ar( 1, \buf.kr(0), \rate.kr(1), \trig.tr(0), \start.kr(0), \loop.kr(0) ) * \amp.kr(0.1);
});
Ndef( \sampler ).addSpec( \amp, [0.05, 1, \linear] );
Ndef( \sampler ).addSpec( \buf, [ 0, 10, \linear, 1 ] );
Ndef( \sampler ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \sampler ).setUni( \amp, 1.0 );
Ndef( \sampler ).set(\buf, (b[0][0]).bufnum); // initialize to sample 0 of samplebank 0
Ndef( \sampler ).play;
Ndef( \sampler ).set(\trig, 1);
);

(
// Create the sample playback synth
Ndef( \sampler2, {
	PlayBuf.ar( 1, \buf.kr(0), \rate.kr(1), \trig.tr(0), \start.kr(0), \loop.kr(0) ) * \amp.kr(0.1);
});
Ndef( \sampler2 ).addSpec( \amp, [0.05, 1, \linear] );
Ndef( \sampler2 ).addSpec( \buf, [ 0, 10, \linear, 1 ] );
Ndef( \sampler2 ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \sampler2 ).setUni( \amp, 1.0 );
Ndef( \sampler2 ).set(\buf, (b[0][0]).bufnum); // initialize to sample 0 of samplebank 0
Ndef( \sampler2 ).play;
Ndef( \sampler2 ).set(\trig, 1);
)

// Run the following code to start the interaction

(
~snum = 0;  // sample number
~sbank = 0; // Change this to choose a different sample bank
~last = 0;  // last value
~direction = 1;   // Change this to -1 to step backwards
OSCdef(\samplewalk1, {|msg|
	var data = 1-msg[2]; // for pressure pad 1
	var thresh = 0.5; // threshold for playing the sound
	var bankthreshold1 = 0.7; // below: word 1, above word 2
	var bankthreshold2 = 0.9; // below: word 2, above word 3

	if ( msg[1] == 1 ){ // do only for the first sock
		postln(data + " " + "nextsamp: "+~snum);
		if(data >= thresh) {
			if (~last < thresh) {
				if ( data < bankthreshold1 ){
					~sbank = 0; // word 1
				}{
					if ( data > bankthreshold2 ){
						~sbank = 2;
					}{
						~sbank = 1;
					}
				};
				Ndef(\sampler).set(\buf, (b[~sbank][~snum]).bufnum);
				Ndef(\sampler).set(\trig, 1);
				~snum=~snum+~direction;
				if (~snum >= b[~sbank].size) {
					~snum = 0;
				};
				if (~snum < 0) {
					~snum = (b[~sbank].size - 1);
				};
			};
		};
		~last = data;
	}
}, "/minibee/data");
);


(
~snum2 = 0;  // sample number
~sbank2 = 0; // Change this to choose a different sample bank
~last2 = 0;  // last value
~direction2 = 1;   // Change this to -1 to step backwards
OSCdef(\samplewalk2, {|msg|
	var data = 1-msg[3]; // for pressure pad 1
	var thresh = 0.5; // threshold for playing the sound
	var bankthreshold1 = 0.7; // below: word 1, above word 2
	var bankthreshold2 = 0.9; // below: word 2, above word 3
	postln(data + " " + "nextsamp: "+~snum2);
	if(data >= thresh) {
		if (~last2 < thresh) {
			if ( data < bankthreshold1 ){
				~sbank2 = 0; // word 1
			}{
				if ( data > bankthreshold2 ){
					~sbank2 = 2;
				}{
					~sbank2 = 1;
				}
			};
			Ndef(\sampler2).set(\buf, (b[~sbank2][~snum2]).bufnum);
			Ndef(\sampler2).set(\trig, 1);
			~snum2=~snum2+~direction2;
			if (~snum2 >= b[~sbank2].size) {
				~snum2 = 0;
			};
			if (~snum2 < 0) {
				~snum2 = (b[~sbank2].size - 1);
			};
		};
	};
	~last2 = data;
}, "/minibee/data");
);

// Stop the interaction
// OSCdef.freeAll;

// pressure: vary from soft sounds to hard sounds : more pressure louder sounds
// word 1 is normal pitch
// word 2 is emotional/question/
// word 3 is shouting

// overlap words - two players
