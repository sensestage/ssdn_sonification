a = Bus.control(s,1);

Ndef( \stddev, { SendReply.kr( Impulse.kr(20), '/stddev', StdDevUGen.kr( In.kr( \bus.kr(a.index), 1 ), 300 ), 1 ) } );

OSCdef( \stddev, { |msg| msg.postln; }, "/stddev" );

Ndef( \mean, { SendReply.kr( Impulse.kr(20), '/mean', RunningSum.kr( In.kr( \bus.kr(a.index), 1 ), 300 ) / 300, 1 ) } );

OSCdef( \mean, { |msg| msg.postln; }, "/mean" );


a.set( 0.4);

// language side:

c = SignalCharacteristics.new( 200 );

c.addValue( 0.3 );
c.stdDev;

c.addValue( 0.1 );
c.stdDev;
