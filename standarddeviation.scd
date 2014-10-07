a = Bus.control(s,1);

Ndef( \stddev, { SendReply.kr( Impulse.kr(20), '/stddev', StdDevUGen.kr( In.kr( \bus.kr(a.index), 1 ), 300 ), 1 ) } );

OSCdef( \stddev, { |msg| msg.postln; }, "/stddev" );

Ndef( \mean, { SendReply.kr( Impulse.kr(20), '/mean', RunningSum.kr( In.kr( \bus.kr(a.index), 1 ), 300 ) / 300, 1 ) } );

OSCdef( \mean, { |msg| msg.postln; }, "/mean" );


a.set( 0.4);