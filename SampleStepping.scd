/*
Walking through a sample bank.

Direction of walk can be changed.

Parallel sample banks can be selected.
*/

s.boot;

// For each sample bank create a new entry in b. Parallel samples should be named identically.
b = ();
~path = ( "".resolveRelative +/+ "Samples/1/*.wav" ).pathMatch.sort;
b[0] = ~path.collect{ |it| Buffer.read( s, it ) }; // bank 0
~path = ( "".resolveRelative +/+ "Samples/2/*.wav" ).pathMatch.sort;
b[1] = ~path.collect{ |it| Buffer.read( s, it ) }; // bank 1

// Create the sample playback synth
Ndef( \sampler, {
	PlayBuf.ar( 2, \buf.kr(0), \rate.kr(1), \trig.tr(0), \start.kr(0), \loop.kr(0) ) * \amp.kr(0.1);
});
Ndef(\sampler).addSpec(\amp, [0.05, 1, \linear] );
Ndef( \sampler ).addSpec( \buf, [ 0, 10, \linear, 1 ] );
Ndef( \sampler ).addSpec( \trig, [ 0, 1, \linear, 1 ] );
Ndef( \sampler ).setUni( \amp, 1.0 );
Ndef( \sampler ).set(\buf, (b[0][0]).bufnum); // initialize to sample 0 of samplebank 0
Ndef( \sampler ).play;
Ndef(\sampler).set(\trig, 1);



// Run the following code to start the interaction

~snum = 0;
~sbank = 0;       // Change this to choose a different sample bank
~last = 0;
~direction = 1;   // Change this to -1 to step backwards
OSCdef(\samplewalk, {|msg|
	var data = msg[3];
	var thresh = 0.5;
	postln(data + " " + "nextsamp: "+~snum);
	if(data >= thresh) {
		if (~last < thresh) {
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
}, "/minibee/data");


// Stop the interaction
OSCdef.freeAll;


