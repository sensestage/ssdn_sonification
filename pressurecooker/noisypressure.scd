s.waitForBoot{

	Buffer.loadDialog(s, action: {|buf|
		{

			// ~player = {|rate|Out.ar(0, PlayBuf.ar(1, ~buffer.bufnum, rate.lag(0.1), 1, 0, 1))}.play;
			~player = {|fr=4, rate=1, cp=0.5, dr=0.1, amp=0, dt=0.1, dc=1, cut=3000|
				Out.ar(0, BLowPass.ar(CombL.ar(TGrains.ar(2, Impulse.kr(fr.lag(0.1)), buf.bufnum, rate.lag(0.001), cp.lag(0.01), dr.lag(0.1), 0, amp),  0.1, dt.lag(0.1), dc), cut.lag(0.001), 0.9).tanh);
			}.play;

			s.sync;

			/*
			OSCFunc({|...args|
	//args.postln;
				~player.set(\rate, args[0][1].linlin(0, 100, 0.05, 2.4));
				~player.set(\fr, args[0][1].linlin(0, 100, 14, 200));
				~player.set(\cp, args[0][1].linlin(0, 100, 0.1, 0.3));
				~player.set(\dr, args[0][1].linlin(0, 100, 0.05, 0.9));
				~player.set(\amp, args[0][1].linlin(0, 100, 0, 3));
				~player.set(\dt, args[0][1].linlin(0, 100, 0, 0.1));
				~player.set(\dc, args[0][1].linlin(0, 100, 0.1, 13));
				~player.set(\cut, args[0][1].linlin(0, 100, 20000, 130));

			}, '\input');
			*/

			(
				OSCdef( \minibeeSound, { |msg|
					var maxval = 0.35;
					msg.postln;

					/*
					~player.set( \rate, msg[2].linlin( 0, 0.01, 0.05, 2.4 ) );
					~player.set(\fr, msg[2].linlin(0, 0.01, 14, 200));
					~player.set(\cp, msg[2].linlin(0, 0.01, 0.1, 0.3));
					~player.set(\dr, msg[2].linlin(0, 0.01, 0.05, 0.9));
					~player.set(\amp, msg[2].linlin(0, 0.01, 0, 3));
					~player.set(\dt, msg[2].linlin(0, 0.01, 0, 0.1));
					~player.set(\dc, msg[2].linlin(0, 0.01, 0.1, 13));
					~player.set(\cut, msg[2].linlin(0, 0.01, 20000, 130));
				*/
					~player.set( \rate, msg[2].linlin( 0, maxval, 0.05, 2.4 ) );
					~player.set(\fr, msg[3].linlin(0, maxval, 14, 200));
					~player.set(\cp, msg[2].linlin(0, maxval, 0.1, 0.3));
					~player.set(\dr, msg[3].linlin(0, maxval, 0.05, 0.9));
					~player.set(\amp, msg[2].linlin(0, maxval, 0, 3));
					~player.set(\dt, msg[3].linlin(0, maxval, 0, 0.1));
					~player.set(\dc, msg[2].linlin(0, maxval, 0.1, 13));
					~player.set(\cut, msg[3].linlin(0, maxval, 20000, 130));

				}, "/minibee/data" );
			)

		}.fork;
	});
}

/*
{SoundIn.ar()}.play;
Server.default.makeGui;
Server.killAll;
s.meter;

eric1606@hotmail.com
*/