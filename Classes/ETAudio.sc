ETAudio{

	var <lastPreset;

	var <tope;

	var <amplitudes, <repeats, <offsets, <waves;
	var <frequencies, <envelopes, <durations;
	var <randomFreqs, <randomDurs, <randomModes;
	var <filter;
	var <>filterMax = 255;

	*new{ |tp|
		^super.new.init(tp);
	}

	init{ |tp|
		tope = tp;
		// TODO: set defaults for sound
		frequencies = [50,20,2560];
		randomFreqs = Array.fill(3,0);
		randomModes = Array.fill(3,0);
		repeats = Array.fill(3,0);
		amplitudes = Array.fill(3,0);
		offsets = Array.fill(3,0);
		durations = Array.fill( 3, 512 );
		randomDurs = Array.fill(3,0);
		envelopes = Array.fill( 3, { [0,10,5,20] }).flatten;
		waves = [ 5, 5, 5 ]; // all sines
		filter = [1.0, 0,0, 0,0];
	}

	// settings for the sound
	//--- sound
	// trig:      2 ('S','T')
	trigger{
		tope.sendControl( 1, [ $S.ascii, $T.ascii ], \soundtrigger );
	}
	// amplitude: 5 ('S','A',a1,a2,a3) - node 2
	amplitude_{ |amps, send=true, sendChanged=true|
		amplitudes = amps;
		if ( send ){
			tope.sendControl( 2, [ $S.ascii, $A.ascii ] ++ amps, \soundamps );
		};
		if ( sendChanged ){
			this.changed;
		}
	}

	// repeat :   5 ('S','H',h1,h2,h3)
	repeat_{ |reps, send = true, sendChanged=true|
		repeats = reps;
		if ( send ){
			tope.sendControl( 2, [ $S.ascii, $H.ascii ] ++ reps, \soundrepeats );
		};
		if ( sendChanged ){
			this.changed;
		}
	}

	// offset :   5 ('S','O',o1,o2,o3)
	offset_{ |offs, send=true, sendChanged=true|
		offsets = offs;
		if ( send ){
			tope.sendControl( 2, [ $S.ascii, $O.ascii ] ++ offs, \soundoffsets );
		};
		if ( sendChanged ){
			this.changed;
		}
	}

	// wave :     5 ('S','W',w1,w2,w3)
	wave_{ |reps, send=true, sendChanged=true|
		waves = reps;
		if ( send ){
			tope.sendControl( 2, [ $S.ascii, $W.ascii ] ++ reps, \soundwaves );
		};
		if ( sendChanged ){
			this.changed;
		}

	}

	// frequency: 8 ('S','F', freq1*2, freq2*2, freq3*2)
	frequency_{ |freqs,send=true,sendChanged=true|
		frequencies = freqs;
		if ( send ){
			tope.sendControl( 9, [ $S.ascii, $F.ascii ] ++ freqs.collect{ |i| [ (i/256).floor, i%256 ] }.flatten, \soundfreqs );
		};
		if ( sendChanged ){
			this.changed;
		}
	}

	// duration:  8 ('S','L', dur1*2, dur2*2, dur3*2)
	duration_{ |durs,send=true,sendChanged=true|
		durations = durs;
		if ( send ){
			tope.sendControl( 3, [ $S.ascii, $L.ascii ] ++ durs.collect{ |i| [ (i/256).floor, i%256 ] }.flatten, \sounddurs );
		};
		if ( sendChanged ){
			this.changed;
		}
	}

	// filter :   8 ('S','P', A0, A1, A2, B0, B1, signs)
	filter_{ |cfs,send=true,sendChanged=true|
		var abs = cfs.abs.normalizeSum;
		var coefs = ( abs.collect{ |it| ( it * filterMax ).floor } ) ++
		(cfs.collect{ |it| if( it.sign>0){1}{0} } * [1,2,4,8,16] ).sum;
		filter = cfs;
		if ( send ){
			tope.sendControl( 3, [$S.ascii, $P.ascii ] ++ coefs, \soundfilter );
		};
		if ( sendChanged ){
			this.changed;
		}
	}

	// random :   15 ('S','R', modes, r1*2, r2*2, r3*2, rd1*2, rd2*2, rd3*2)
	random_{ |mods,randfreqs,randdurs,send=true,sendChanged=true|
		randomModes = mods;
		randomFreqs = randfreqs;
		randomDurs = randdurs;
		if ( send ){
			tope.sendControl( 4,
				[ $S.ascii, $R.ascii ]
				++ ( mods * [1,4,16] ).sum
				++ ( [randfreqs,randdurs].flop.flatten.collect{ |i| [ (i/256).round(1), i%256 ] }.flatten ), \soundrandom );
		};
		if ( sendChanged ){
			this.changed;
		}
	}

	// envelope: 14 ('S','E', 3*(phase, attack, decay, steps) )
	envelope_{ |envs,send=true,sendChanged=true|
		envelopes = envs;
		if ( send ){
			tope.sendControl( 10, [ $S.ascii, $E.ascii ] ++ envs, \soundenv );
		};
		if ( sendChanged ){ this.changed };
	}

	// all settings: 50 (2+(3*14)) ('S','S', 3*(modes, amp, dur*2,attack,decay,freq*2,offset,rand*2,rand*2,steps) + coefs filter (6)) )
	sendAll{
		var int2byte = { |int| [ (int/256).floor, int%256 ] };
		var msg,abs,coefs;
		//TODO: gather settings from all, and send it out
		msg = 3.collect{ |i|
			[ repeats[i].leftShift(7) + randomModes[i].leftShift(5) + envelopes[i*4].leftShift(3) + waves[i] ] ++
			amplitudes[i] ++ offsets[i] ++
			int2byte.value( durations[i] ) ++
			envelopes.at( [1,2,3] + (i*4) ) ++
			int2byte.value( frequencies[i]) ++
			int2byte.value( randomFreqs[i]) ++
			int2byte.value( randomDurs[i])
		}.flatten;
		//msg = msg ++
		abs = filter.abs.normalizeSum;
		coefs = ( abs.collect{ |it| ( it * filterMax ).floor } ) ++ (filter.collect{ |it| if( it.sign>0){1}{0} } * [1,2,4,8,16] ).sum;
		msg = msg ++ coefs;
		tope.sendControl( 6, [ $S.ascii, $S.ascii ] ++ msg, \soundsetAll );
	}

	sendOneByOne{
		this.sendOne( 0 );
		this.sendOne( 1 );
		this.sendOne( 2 );
	}

	sendOne{ |i|
		var msg;
		var int2byte = { |int| [ (int/256).floor, int%256 ] };
		msg = ([ repeats[i].leftShift(7) + randomModes[i].leftShift(5) + envelopes[i*4].leftShift(3) + waves[i] ] ++
			amplitudes[i] ++ offsets[i] ++
			int2byte.value( durations[i] ) ++
			envelopes.at( [1,2,3] + (i*4) ) ++
			int2byte.value( frequencies[i]) ++
			int2byte.value( randomFreqs[i]) ++
			int2byte.value( randomDurs[i])
		).flatten;
		tope.sendControl( 4, [ $S.ascii, $s.ascii, i ] ++ msg, (\soundset ++ i ).asSymbol );
	}

	asPreset{
		^NPPreset[
			\amplitudes -> amplitudes.copy,
			\repeats -> repeats.copy,
			\offsets -> offsets.copy,
			\waves -> waves.copy,
			\frequencies -> frequencies.copy,
			\envelopes -> envelopes.copy,
			\durations -> durations.copy,
			\randomFreqs -> randomFreqs.copy,
			\randomDurs -> randomDurs.copy,
			\randomModes -> randomModes.copy,
			\filter -> filter.copy,
			\filterMax -> filterMax.copy
		];
	}

	storePreset{ |name,lib|
		var preset = this.asPreset;
		lastPreset = name.asSymbol;
		if ( lib.isNil ){
			if ( tope.poly.notNil ){
				lib = tope.poly.soundPresets;
			};
		};
		preset.lib = lib;
		preset.store( name );
		//		lib.store( name, this.asPreset );
	}

	fromPreset{ |preset, send=true|
		if ( preset.isKindOf( NPPreset ) ){
			this.prFromPreset( preset, send );
		}{
			if ( tope.poly.notNil and: preset.isKindOf( Symbol ) ){
				this.fromPreset( tope.poly.soundPresets[ preset ] );
			}
		}
	}

	prFromPreset{ |preset, send=true|
		this.amplitude_( [0,0,0], true, false );
		lastPreset = preset[ \name ];
		this.amplitude_( preset[\amplitudes].copy, false, false );
		this.repeat_( preset[\repeats].copy, false, false );
		this.offset_( preset[\offsets].copy, false, false );
		this.wave_( preset[\waves].copy, false, false );
		this.frequency_( preset[\frequencies].copy, false, false );
		this.duration_( preset[\durations].copy, false, false );
		this.random_( preset[\randomModes].copy, preset[\randomFreqs].copy, preset[\randomDurs ].copy, false, false );
		this.envelope_( preset[\envelopes].copy, false, false );
		this.filterMax_( preset[\filterMax].copy );
		this.filter_( preset[\filter].copy, true, false );
		if ( send ){
			this.sendOne( 0 );
			this.sendOne( 1 );
			this.sendOne( 2 );
			// this.sendAll;
		};
		this.changed;
	}

	guiClass{
		^ETAudioGui;
	}
}


ETAudioGui : ObjectGui {

	classvar <>oscWidth = 250;

	var <ampOffsets;
	var <freqRands;
	var <durRands;
	var <repeats, <waves, <randomModes, <filter, <filterMax;
	var <envAttacks, <envDecays, <envPhases, <envSteps;

	var <preset;

	guiBody { arg layout;
		var trig;
		var modes;

		Spec.add( \integer8, [0,256-1,\linear,1].asSpec );
		Spec.add( \integer16, [0,256*256-1,\linear,1].asSpec );
		Spec.add( \integer16exp, [0,256*256-1,10,1].asSpec );
		// the object you are making a gui for is referred to as the model

		layout.startRow;
		// header
		StaticText(layout,Rect(0,0,oscWidth,20) ).string_( "osc 1" ).align_( \center );
		StaticText(layout,Rect(0,0,oscWidth,20) ).string_( "osc 2" ).align_( \center );
		StaticText(layout,Rect(0,0,oscWidth,20) ).string_( "osc 3" ).align_( \center );

		layout.startRow;
		ampOffsets = model.amplitudes.collect{ |it,i|
			EZRanger.new( layout, Rect(0,0,oscWidth,20), "amp", \integer8.asSpec, { |sl|
				//"range slider values: ".post;
				//sl.value.postln;
				model.offset_( model.offsets.put( i, sl.value[0].asInteger ), sendChanged: false );
				model.amplitude_( model.amplitudes.put( i, sl.value[1].asInteger - sl.value[0].asInteger ) );
			}, [ model.offsets[i], model.offsets[i] + it], labelWidth: 30, numberWidth: 40 );
		};

		/*
		layout.startRow;
		offsets = model.offsets.collect{ |it,i|
			EZSlider.new( layout, Rect(0,0,oscWidth,20), "off", \integer8.asSpec, { |sl| model.offset_( model.offsets.put( i, sl.value ) ) }, it, labelWidth: 30, numberWidth: 35 );
		};
		*/

		layout.startRow;
		freqRands = model.frequencies.collect{ |it,i|
			EZRanger.new( layout, Rect(0,0,oscWidth,20), "freq", \integer16exp.asSpec, { |sl|
				model.frequency_( model.frequencies.put( i, sl.value[0].asInteger ), sendChanged: false );
				model.random_( model.randomModes, model.randomFreqs.put( i, sl.value[1].asInteger - sl.value[0].asInteger ), model.randomDurs )
			}, [it, it+model.randomFreqs[i] ], labelWidth: 30, numberWidth: 40 );
		};

		/*
		layout.startRow;
		randomFreqs = model.randomFreqs.collect{ |it,i|
			EZSlider.new( layout, Rect(0,0,oscWidth,20), "~freq~", \integer16exp.asSpec, { |sl| model.random_( model.randomModes, model.randomFreqs.put( i, sl.value.asInteger ), model.randomDurs ) }, it, labelWidth: 30, numberWidth: 35 );
		};
		*/

		layout.startRow;
		durRands = model.durations.collect{ |it,i|
			EZRanger.new( layout, Rect(0,0,oscWidth,20), "dur", \integer16exp.asSpec, { |sl|
				model.duration_( model.durations.put( i, sl.value[0].asInteger ), sendChanged: false );
				model.random_( model.randomModes, model.randomFreqs, model.randomDurs.put( i, sl.value[1].asInteger - sl.value[0].asInteger ) )
			}, [it, model.randomDurs[i] + it ], labelWidth: 30, numberWidth: 40 );
		};

		/*
		layout.startRow;
		randomDurs = model.randomDurs.collect{ |it,i|
			EZSlider.new( layout, Rect(0,0,oscWidth,20), "~dur~", \integer16exp.asSpec, { |sl| model.random_( model.randomModes, model.randomFreqs, model.randomDurs.put( i, sl.value.asInteger ) ) }, it, labelWidth: 30, numberWidth: 35 );
		};
		*/

		layout.startRow;

		modes = 3.collect{ |j|
			[
				Button.new( layout, Rect(0,0,oscWidth/3-2,20) ).states_( [ ["no random"], ["once random"], ["repeat random"] ] ).action_( { |but| model.random_( model.randomModes.put( j, but.value ), model.randomFreqs, model.randomDurs ) } ).value_( model.randomModes[j] ),
				Button.new( layout, Rect(0,0,oscWidth/3-2,20) ).states_(
					[ ["triangle"], ["saw"], ["sawinv"],
						["pulse"], ["dc"], ["sine"], ["noise"] ].copyFromStart( if ( j == 2 ){ 6 }{ 5 } )
				).action_( { |but| model.wave_( model.waves.put( j, but.value ) ) } ).value_( model.waves[j] ),
			Button.new( layout, Rect(0,0,oscWidth/3-2,20) ).states_( [[ "once" ], ["repeat"] ] ).action_( { |but| model.repeat_( model.repeats.put( j, but.value ) ) } ).value_( model.repeats[j] );
			];
		}.flop;
		randomModes = modes[0];
		waves = modes[1];
		repeats = modes[2];

		/*
		randomModes = model.randomModes.collect{ |it,i|
			Button.new( layout, Rect(0,0,oscWidth,20) ).states_( [ ["no random"], ["once random"], ["repeat random"] ] ).action_( { |but| model.random_( model.randomModes.put( i, but.value ), model.randomFreqs, model.randomDurs ) } );
		};

		layout.startRow;
		waves = model.waves.collect{ |it,i|
			Button.new( layout, Rect(0,0,oscWidth,20) ).states_( [ ["triangle"], ["saw"], ["sawinv"], ["pulse"], ["dc"], ["noise"], ["sine"] ] ).action_( { |but| model.wave_( model.waves.put( i, but.value ) ) } );
		};

		layout.startRow;
		repeats = model.repeats.collect{ |it,i|
			Button.new( layout, Rect(0,0,oscWidth,20) ).states_( [[ "once" ], ["repeat"] ] ).action_( { |but| model.repeat_( model.repeats.put( i, but.value ) ) } );
		};
		*/
		//		layout.startRow;
		//		StaticText(layout,Rect(0,0,80,20) ).string_( "envelope" );
		//		envelopes = model.envelopes.gui(layout);
		layout.startRow;
		envPhases = model.envelopes.clump(4).collect{ |it,i|
			Button.new( layout, Rect(0,0,oscWidth,20) ).states_( [[ "attack" ], ["decay"], ["rest"], ["dc"] ] ).action_( { |but| model.envelope_( model.envelopes.put( i*4, but.value.asInteger ) ) } );
		};

		layout.startRow;
		envAttacks = model.envelopes.clump(4).collect{ |it,i|
			EZSlider.new( layout, Rect(0,0,oscWidth,20), "attack", [0,255,3,1].asSpec, { |sl|
				model.envelope_( model.envelopes.put( i*4 + 1, sl.value.asInteger ) )
			}, it[1], labelWidth: 30, numberWidth: 40 );
		};
		layout.startRow;
		envDecays = model.envelopes.clump(4).collect{ |it,i|
			EZSlider.new( layout, Rect(0,0,oscWidth,20), "decay", [0,255,3,1].asSpec, { |sl|
				model.envelope_( model.envelopes.put( i*4 + 2, sl.value.asInteger ) )
			}, it[2], labelWidth: 30, numberWidth: 40 );
		};
		layout.startRow;
		envSteps = model.envelopes.clump(4).collect{ |it,i|
			EZSlider.new( layout, Rect(0,0,oscWidth,20), "steps", \integer8.asSpec, { |sl|
				model.envelope_( model.envelopes.put( i*4 + 3, sl.value.asInteger ) )
			}, it[3], labelWidth: 30, numberWidth: 40 );
		};

		layout.startRow;
 		3.do{ |i|
			Button(layout,Rect(0,0,oscWidth,30) ).states_([["sendOne",Color.black, Color.yellow ] ]).action_({ arg butt;
			model.sendOne(i);
			});
		};

		layout.startRow;
		filter = model.filter.collect{ |it,i|
			if ( i == 3 ){ layout.startRow };
			EZSlider.new( layout, Rect(0,0,oscWidth,20), ["a0","a1","a2","b0","b1"].at(i), [-1,1,\linear,0.001].asSpec, { |sl|
				model.filter_( model.filter.put( i, sl.value ) )
			}, it, labelWidth: 20, numberWidth: 40 );
		};
		//	layout.startRow;
		filterMax = EZSlider.new( layout, Rect(0,0,oscWidth,20), "filterMax", \integer8.asSpec, { |sl|
			model.filterMax_( sl.value.asInteger )
		}, model.filterMax, labelWidth: 20, numberWidth: 40 );

		// using non 'gui' objects
		//trig = layout.layRight(30,30); // allocate yourself some space
		layout.startRow;

		if ( model.tope.poly.notNil ){
			preset = model.tope.poly.soundPresets.gui( layout );
			preset.currentTarget = model;
		};

		Button(layout,Rect(0,0,oscWidth*3 - 310,40) ).states_([["trigger",Color.black, Color.green ] ]).action_({ arg butt;
			model.trigger;
		});
		Button(layout,Rect(0,0,60,40) ).states_([["sendAll",Color.black, Color.yellow ] ]).action_({ arg butt;
			model.sendAll;
		});
	}

	// your gui object will have update called any time the .changed message
	// is sent to your model
	update { arg changed,changer;
		if(changer !== this,{
			defer{
				[ \repeats,  \waves, \randomModes, \filter
					//	\envelopes, \filter, \filterMax
				].do{ |obj|
					this.perform( obj ).do{ |it,i|
						it.value_( model.perform( obj ).at( i ) );
					};
				};
				ampOffsets.do{ |it,i|
					it.lo_( model.offsets[i] );
					it.hi_( model.offsets[i] + model.amplitudes[i] );
				};
				freqRands.do{ |it,i|
					it.lo_( model.frequencies[i] );
					it.hi_( model.frequencies[i] + model.randomFreqs[i] );
				};
				durRands.do{ |it,i|
					it.lo_( model.durations[i] );
					it.hi_( model.durations[i] + model.randomDurs[i] );
				};
				model.envelopes.clump(4).do{ |it,i|
					envPhases[i].value_( it[0] );
					envAttacks[i].value_( it[1] );
					envDecays[i].value_( it[2] );
					envSteps[i].value_( it[3] );
				};
				filterMax.value_( model.filterMax );
			};
		});
	}
}
