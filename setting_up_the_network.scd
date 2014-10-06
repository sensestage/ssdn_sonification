"pydongui.py".runInTerminal;

n = NetAddr.new( "127.0.0.1", 57600 ); // address of pydon

n.sendMsg( "/minibee/configuration", 1, 1 ); // configuration 1 for minibee 1

// receive the OSC data:
(
OSCdef( \minibeePost, { |msg|
	msg.postln;
}, "/minibee/data" );
);

 // save the current configuration to a file
n.sendMsg( "/minihive/configuration/save", "myconfiguration.xml" );

// now stop the pydon program ([stop] button) and go to this configuration file