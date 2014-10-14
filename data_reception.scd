// start pydongui:
("cd" + "".resolveRelative ++ "; pydongui.py").runInTerminal;


// receive the OSC data:
(
OSCdef( \minibeePost, { |msg|
	msg.postln;
}, "/minibee/data" );
);

// look at the data that is posted, it will have a format like:
[ "/minibee/data", 1, 0.677, 0.53, 0.45, 0.23, ... ];
// check which one is the value changing as you manipulate your sensor.
// for example, while pressing your pressure sensor, the 3rd element in this array changes.
[ "/minibee/data", 1, 0.677, 0.53, 0.45, 0.23, ... ];
[ "/minibee/data", 1, 0.6, 0.53, 0.45, 0.23, ... ];
[ "/minibee/data", 1, 0.3, 0.53, 0.45, 0.23, ... ];
// then we can access it with msg[2], the third element of the array (we start counting at 0).
// msg[0] = "/minibee/data"
// msg[1] = 1 : this is the index of the minibee
// msg[2] : this is the first sensor data stream
// msg[3] : this is the second sensor data stream

(
OSCdef( \minibeePost, { |msg|
	("full messages" + msg).postln;
	("my data" + msg[2]).postln;
}, "/minibee/data" );
);

// if we have more than one minibee connected, the second element in the array will change:
[ "/minibee/data", 1, 0.677, 0.53, 0.45, 0.23, ... ];
[ "/minibee/data", 2, 0.6, 0.53, 0.45, 0.23, ... ];
[ "/minibee/data", 1, 0.3, 0.53, 0.45, 0.23, ... ];
[ "/minibee/data", 2, 0.6, 0.53, 0.45, 0.23, ... ];

// we can listen for a particular one, if we filter for it, for example:
(
OSCdef( \minibeePost, { |msg|
	("full messages" + msg).postln;
	if ( msg[1] == 1 ){
		("data for minibee 1" + msg.copyToEnd( 2 ) ).postln;
	};
	if ( msg[1] == 2 ){
		("data for minibee 2" + msg.copyToEnd( 2 ) ).postln;
	};
}, "/minibee/data" );
);


// stop posting:
OSCdef( \minibeePost ).free;


// free all interaction
OSCdef.freeAll;
