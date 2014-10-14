// start pydon:
"pydongui.py".runInTerminal;

// select configuration: pydonconfig.xml
// select serial port

// maybe: change port to send data to:
NetAddr.langPort; // -> outputs 57120, or 57121...

n = NetAddr.new( "127.0.0.1", 57600 ); // address of pydongui

~etosc1 = ETTopeOSC.new( ~pydon, 6 );

~etosc1.sound.gui

~etosc2 = ETTopeOSC.new( ~pydon, 7 );

~etosc2.sound.gui

~etosc2.sound.trigger

Tdef( \trigSound, { loop{ ~etosc2.sound.trigger; rrand(7.0,20.0).wait; } } )
Tdef( \trigSound ).play;
Tdef( \trigSound ).stop;