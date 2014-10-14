/*
// configurations:
1 : accelero
2 : pressure + vibro : 1 pressure + accelero + vibro control
3 : tentacles V1 : 4 stretch + accelero
4 : tentacles V2 : 4 stretch + accelero
5 : mouth audio : receives custom messages
6 : muscle
*/

// start pydon:
"pydongui.py".runInTerminal;

// maybe: change port to send data to:
NetAddr.langPort; // -> outputs 57120, or 57121...

~pydon = NetAddr.new( "127.0.0.1", 57600 ); // address of pydongui

(
OSCdef( \minibeeInfoPost, { |msg|
	msg.postln;
}, "/minibee/info" );
);

~pydon.sendMsg( "/minibee/configuration", 1, 2 ); // pressure+vibro
~pydon.sendMsg( "/minibee/configuration", 2, 2 ); // pressure+vibro
~pydon.sendMsg( "/minibee/configuration", 3, 2 ); // pressure+vibro

~pydon.sendMsg( "/minibee/configuration", 4, 4 ); // tentacles v2
~pydon.sendMsg( "/minibee/configuration", 5, 3 ); // tentacles v1

~pydon.sendMsg( "/minibee/configuration", 6, 5 ); // audio 1
~pydon.sendMsg( "/minibee/configuration", 7, 5 ); // audio 2

///~pydon.sendMsg( "/minibee/configuration", 8, 1 ); // acting weird

~pydon.sendMsg( "/minibee/configuration", 9, 1 ); // accelero
~pydon.sendMsg( "/minibee/configuration", 10, 1 ); // accelero

~pydon.sendMsg( "/minibee/configuration", 11, 6 ); // muscle
~pydon.sendMsg( "/minibee/configuration", 12, 6 ); // muscle


a = SWPlotterMonitor.new( { [d] }, 100 );
a.start;
a.monitor.dt = 0.05;
a.stop
d

// receive the OSC data:
(
OSCdef( \minibeePost, { |msg|
	// msg.postln;
	if ( msg[1] == 11){
		msg.postln;
		d = msg[2];
	}
}, "/minibee/data" );
);

OSCdef( \minibeePost ).free;

~pydon.sendMsg( "/minibee/output", 1, 255 )
~pydon.sendMsg( "/minibee/output", 1, 0 )

~pydon.sendMsg( "/minibee/output", 2, 255 )
~pydon.sendMsg( "/minibee/output", 2, 0 )

~pydon.sendMsg( "/minibee/output", 3, 255 )
~pydon.sendMsg( "/minibee/output", 3, 0 )



~pydon.sendMsg( "/minihive/configuration/save", "pressureconfiguration.xml" );
