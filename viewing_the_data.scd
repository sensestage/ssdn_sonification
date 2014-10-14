// start pydongui (if not already running):
("cd" + "".resolveRelative ++ "; pydongui.py").runInTerminal;

// view and analyse the incoming data:
c = SignalCharacteristics.new( 500 );
c.makeGui;

// make an OSC receiver to add data to the SignalCharacteristics
(
OSCdef( \minibeeSignal, { |msg|
	c.addValue( msg[3] ); // first data point - our analog sensor data: range will be between 0 and 1
}, "/minibee/data" );
);

// in the left plot you will see the signal coming in, and see how it changes over time. In the upper left part you will see the range of the data, and the mean and standard deviation.
// in the middle plot you will see how the data is distributed, and how many different values you are receiving - giving a sense of the resolution of the data.
// in the right plot you will see how the data is coming in over time, the time intervals between updates of the data.

// if you want to stop viewing the signal characteristics:
OSCdef( \minibeeSignal ).free;
