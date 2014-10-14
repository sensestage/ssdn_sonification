// start pydon:
"pydongui.py".runInTerminal;

// select configuration: pydonconfig.xml
// select serial port

// maybe: change port to send data to:
NetAddr.langPort; // -> outputs 57120, or 57121...

n = NetAddr.new( "127.0.0.1", 57600 ); // address of pydongui

// set up a listener for the info message from pydongui
(
OSCdef( \minibeeInfoPost, { |msg|
	msg.postln;
}, "/minibee/info" );
);

// turn on minibee

// wait for a post like : [ /minibee/info, 0013A20040BB364E, 1, 0, 0 ]

// send a message to configure your minibee
n.sendMsg( "/minibee/configuration", 1, 4 ); // 4: vibro
n.sendMsg( "/minibee/configuration", 1, 5 ); // 5: low res
n.sendMsg( "/minibee/configuration", 4, 6 ); // 6: mouth
n.sendMsg( "/minibee/configuration", 5, 7 ); // 7: audio + mic
n.sendMsg( "/minibee/configuration", 5, 8 ); // 7: audio - mic
n.sendMsg( "/minibee/configuration", 6, 9 ); // 8: stretch

n.sendMsg( "/minibee/output", 1, 1 ); // send amp on


n.sendMsg( "/minibee/custom", 1, $S.ascii, $T.ascii ); // send amp on

n.sendMsg( "/minibee/custom", 1, $S.ascii, $T.ascii ); // send amp on


n.sendMsg( "/minibee/custom", 1, $S.ascii, $T.ascii ); // send amp on

(
Tdef( \pulse, {
	loop{
		n.sendMsg( "/minibee/output", 1, 0 ); // send vibration
		3.0.rand.wait;
		n.sendMsg( "/minibee/output", 1, 255 ); // send vibration
		2.0.rand.wait;
	}
}).play;
)


a = SWPlotterMonitor.new( { [d] }, 100 );
a.start;
a.monitor.dt = 0.05;
a.stop
d

OSCdef( \minibeePost ).free

// receive the OSC data:
(
OSCdef( \minibeePost, { |msg|
	// msg.postln;
	if ( msg[1] == 12){
		msg.postln;
//		d = msg[2];
	};
	if ( msg[1] == 11){
		msg.postln;
//		d = msg[2];
	};
}, "/minibee/data" );
);

(30*130).sqrt

// view and analyse the incoming data:
c = SignalCharacteristics.new( 100 );
c.makeGui;

(
OSCdef( \minibeeSignal, { |msg|
	if ( msg[1] == 4 ){
		c.addValue( msg[2] ); // first data point - our analog sensor data: range will be between 0 and 1
	}
}, "/minibee/data" );
)


 // save the current configuration to a file
n.sendMsg( "/minihive/configuration/save", "myconfiguration.xml" );

n.sendMsg( "/minihive/configuration/save", "hairconfiguration.xml" );

n.sendMsg( "/minihive/configuration/save", "audioconfiguration.xml" );

n.sendMsg( "/minihive/configuration/save", "pressureconfiguration.xml" );

// now stop the pydon program ([stop] button) and select this configuration file
// pydongui will remember this setting for the next time you start up

(40*0.6).sqrt