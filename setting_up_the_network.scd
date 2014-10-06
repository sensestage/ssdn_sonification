// start pydon:
"pydongui.py".runInTerminal;

// select configuration: pydonconfig.xml
// select serial port

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
n.sendMsg( "/minibee/configuration", 1, 2 ); // configuration 2 for minibee 1

// receive the OSC data:
(
OSCdef( \minibeePost, { |msg|
	msg.postln;
}, "/minibee/data" );
);

 // save the current configuration to a file
n.sendMsg( "/minihive/configuration/save", "myconfiguration.xml" );

// now stop the pydon program ([stop] button) and select this configuration file
// pydongui will remember this setting for the next time you start up