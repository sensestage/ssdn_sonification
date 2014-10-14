// jonathan's computer with dmx control set up
~dmx = NetAddr.new( "192.168.2.105", 8888 );

// test messages:
~dmx.sendMsg( "/dmx", 0.4, 0.3, 0.6, 0.2, 0.9, 0.1 );
~dmx.sendMsg( "/dmx", 0.4, 0.3, 0.6, 0.2, 0.9, 0.1 );
~dmxChans = Array.fill( 6, { 1.0.rand } ); ~dmx.sendMsg( *(["/dmx"] ++ ~dmxChans).postln );

// all black
~dmxChans = Array.fill( 6, { 0 } ); ~dmx.sendMsg( *(["/dmx"] ++ ~dmxChans).postln );

// text
// muscle
// pressure
// velcro
// tentacles
// proximity
// grand finale


// worklights
~dmx.sendMsg( "/dmx", 0.1, 0, 0, 0, 0, 0.4 );

// start
~dmx.sendMsg( "/dmx", 0.2, 0, 0, 0, 0, 0 );

// muscle box
~dmx.sendMsg( "/dmx", 0, 0, 0, 0, 1, 0.2 );

// pressure
~dmx.sendMsg( "/dmx", 0, 0, 0, 0, 0, 0.6 );

// velcro chair
(
Tdef( \fadeInVelcro, {
	~dmx.sendMsg( "/dmx", 0, 0, 0.1, 0.1, 0, 0 );
	0.2.wait;
	~dmx.sendMsg( "/dmx", 0, 0, 0.2, 0.2, 0, 0 );
	0.2.wait;
	~dmx.sendMsg( "/dmx", 0, 0, 0.4, 0.4, 0, 0 );
	0.2.wait;
	~dmx.sendMsg( "/dmx", 0, 0, 0.5, 0.5, 0, 0 );
	0.2.wait;
	~dmx.sendMsg( "/dmx", 0, 0, 0.75, 0.75, 0, 0 );
	0.3.wait;
	~dmx.sendMsg( "/dmx", 0, 0, 1, 1, 0, 0 );
});
);

Tdef( \fadeInVelcro ).play;
// + feedback

~dmx.sendMsg( "/dmx", 0, 0, 1, 1, 0.4, 0 );

// tentacles
~dmx.sendMsg( "/dmx", 0, 0, 0, 0, 0, 0.6 );

// proximity chair
~dmx.sendMsg( "/dmx", 0, 1, 0, 0, 0, 0.2 );


~dmx.sendMsg( "/dmx", 0, 0, 1, 1, 1, 1 );


~dmx.sendMsg( "/dmx", 0.3, 0.2, 0.4, 0.5, 0.2, 0.4 );


// outer lights
~dmx.sendMsg( "/dmx", 0, 0, 0, 0, 0, 0.4 );

~dmx.sendMsg( "/dmx", 0, 0, 0, 0, 0, 1 );
