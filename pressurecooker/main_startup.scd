// start pydon:
"pydongui.py".runInTerminal;

~xosc = NetAddr.new( "192.168.2.103", 57000 );
~xosc.sendMsg( "/XOSC/subscribe/tag", "/minibee/data" );

// connect pydon to /minibee/output
~xosc.sendMsg( "/XOSC/connect/tag", "127.0.0.1", 57600, "/minibee/output" );
~xosc.sendMsg( "/XOSC/connect/tag", "127.0.0.1", 57600, "/minibee/custom" );

// ~xosc.sendMsg( "/minibee/output", 1, 0 );

// s.quit;

// Ndef.all.do{ |it| it.clear };

s.boot;

// load:
( "".resolveRelative +/+ "multisoundfileplayer.scd").load; // tentacles
( "".resolveRelative +/+ "press_vibro_speaker.scd").load; // pressure sound interaction
( "".resolveRelative +/+ "pressure_sound.scd").load; // pressure sound interaction
NdefMixer.new(s);

// audio nodes:
~pydon = NetAddr.new( "127.0.0.1", 57600 ); // address of pydongui
~etosc1 = ETTopeOSC.new( ~pydon, 6 );
~etosc2 = ETTopeOSC.new( ~pydon, 7 );

~etosc1.sound.gui;
~etosc2.sound.gui;