~pressThreshold1 = 0.6;
~pressThreshold2 = 0.8;
~pressThreshold3 = 0.4;

(
~pressureActions = [
	{ |data|
		Tdef( \sendVibro1 ).set( \pval, (data * 255).round(1).asInteger);
		Tdef( \sendVibro1 ).play;
	},
	{ |data|
		Tdef( \sendVibro2 ).set( \pval, (data * 255).round(1).asInteger);
		Tdef( \sendVibro2 ).play;
	},
	{ |data|
		Tdef( \sendVibro3 ).set( \pval, (data * 255).round(1).asInteger);
		Tdef( \sendVibro3 ).play;
	},
	{ |data| ~etosc1.sound.trigger; },
	{ |data| ~etosc2.sound.trigger; },
	{ |data| ~influx.rand; "randomize influx".postln; }
];
);

(
Tdef( \sendVibro1 ).set( \pval, 0 );
Tdef( \sendVibro1, {  |ev|
	~xosc.sendMsg( "/minibee/output", 1, ev.pval.postln; );
	rrand(3.0,8.0).wait;
	~xosc.sendMsg( "/minibee/output", 1, 0 );
});

Tdef( \sendVibro2 ).set( \pval, 0 );
Tdef( \sendVibro2, {  |ev|
	~xosc.sendMsg( "/minibee/output", 2, ev.pval );
	rrand(3.0,8.0).wait;
	~xosc.sendMsg( "/minibee/output", 2, 0 );
});

Tdef( \sendVibro3 ).set( \pval, 0 );
Tdef( \sendVibro3, {  |ev|
	~xosc.sendMsg( "/minibee/output", 3, ev.pval );
	rrand(3.0,8.0).wait;
	~xosc.sendMsg( "/minibee/output", 3, 0 );
});
);

(
~pressOff1 = true;
~pressOff2 = true;
~pressOff3 = true;
);
(
OSCdef( \pressureVibro, { |msg|
	// msg.postln;
	if ( msg[1] == 1 ){
		if ( msg[2] < ~pressThreshold1 and: ~pressOff1 ){
			"trigger 1".postln;
			~pressOff1 = false;
			~pressureActions.choose.value( msg[2] );
		}{
			if ( msg[2] > (~pressThreshold1*1.05) ){
				~pressOff1 = true;
			}
		}
	};
	if ( msg[1] == 2 ){
		if ( msg[2] < ~pressThreshold2 and: ~pressOff2 ){
			"trigger 2".postln;
			~pressOff2 = false;
			~pressureActions.choose.value( msg[2] );
		}{
			if ( msg[2] > (~pressThreshold2*1.05) ){
				~pressOff2 = true;
			}
		}
	};
	if ( msg[1] == 3 ){
				if ( msg[2] < ~pressThreshold3 and: ~pressOff3 ){
			"trigger 3".postln;
			~pressOff3 = false;
			~pressureActions.choose.value( msg[2] );
		}{
			if ( msg[2] > (~pressThreshold3*1.05) ){
				~pressOff3 = true;
			}
		}
	};
}, "/minibee/data" );
);

//~pressureActions.choose.value( 0.2 );
