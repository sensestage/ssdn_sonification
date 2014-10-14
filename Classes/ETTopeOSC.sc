ETTopeOSC{

	var <>poly;
	//	classvar <>offset  = 10000;
	//	classvar <>offset2 = 11000;
	//	var <nodeid, <nodeid2,
	var <beeid;
    var <>network;
    var <>oscTarget;
	var <>redundancy = 2;

	var <broadcast;

    // var <nodes, <sizes;

	var <sound;
	var <queue;
	//var <queuePlayer;

	var <ampup,<ampdown;

	*new{ |oscTarget,bee,broadcast = false|
		^super.new.oscTarget_( oscTarget ).init( bee, broadcast );
	}

	setupQueue{
		if ( queue.player.isNil ){
			queue.player = TaskProxy.new;
		};
		queue.player.source = { |ev|
			var curmsg,curname;
			loop{
				curname = queue.firstName;
				curmsg = queue.takeFirst;
				if ( curmsg.notNil ){
					if ( broadcast ){
						poly.queue.addFirstWithRedundancy( curname, curmsg, this.redundancy );
						// TODO: clear things from queue with same type of message as this that are going to the nodes...
					}{
						poly.queue.addLastWithRedundancy( curname, curmsg, this.redundancy );
						//	poly.queue.addLast( curname, curmsg );
					};
					ev.lastName = curname;
					ev.lastMsg = curmsg;
					//ev.lastMsg.postln;
				};
				ev.waitTime.wait;
			}
		};
		queue.player.set( \waitTime, 0.25 );
	}

	init{ |bee,bc|
		sound = ETAudio.new( this );

		broadcast = bc;

		beeid = bee;
		if ( broadcast ){ beeid = 0xFFFF; };
        // nodes = 10.collect{ |it| beeid*10 + it + 1000 };
        // sizes = [ 2, 5, 9, 16, 37, 50, 3, 4, 8, 14  ];

		//	this.remapBee;

        /*
		if(broadcast){
			nodes.do{ |it| network.addExpected( it ) };
			this.setMappingHooks;
		};

		network.addHook( beeid, {
			nodes.do{ |it,i|
				network.addExpected( it );
			};
			//			nodes.do{ |it,i| 	network.addExpected( it, "beeC" ++ beeid ++ "_" ++ i, sizes[i] );};
			this.setMappingHooks;
			//	this.remapBee;
		}, permanent: true );

		network.addHook( nodes[3], {
			this.sound.sendOne( 0 );
			this.sound.sendOne( 1 );
			this.sound.sendOne( 2 );
			this.trilight.sendAll;
		}, \mappedCustom, true );


		if ( network.isKindOf( SWDataNetworkClient ) ){
			network.subscribeNode( beeid );
		};
        */
		queue = NPQueue.new;
		this.setupQueue;

	}

    updateSoundLight{
        this.sound.sendOne( 0 );
        this.sound.sendOne( 1 );
        this.sound.sendOne( 2 );
		// this.trilight.sendAll;
    }

	// 2 (3),
	// 4 (3), 5 (10), 6(1),
	// 8(6), 9(2),
	// 14(2),
	// 35(1), 38(1)

	sendControl{ |which,data,name|
		var msg,msgdata;
		//data.postln;
        msgdata = data.floor.clip(0,255).round(1).asInteger;
		switch( which,
			1, { msgdata = msgdata.keep(2) },
			2, { msgdata = (msgdata++[$N.ascii]).clipExtend(5) },
			3, { msgdata = (msgdata++[$N.ascii]).clipExtend(9) },
			4, { msgdata = (msgdata++[$N.ascii]).clipExtend(16) },
			5, { msgdata = (msgdata++[$N.ascii]).clipExtend(37) },
			6, { msgdata = (msgdata++[$N.ascii]).clipExtend(50) },
			7, { msgdata = (msgdata++[$N.ascii]).clipExtend(3) },
			8, { msgdata = (msgdata++[$N.ascii]).clipExtend(4) },
			9, { msgdata = (msgdata++[$N.ascii]).clipExtend(8) },
			10, { msgdata = (msgdata++[$N.ascii]).clipExtend(14) }
		);
        // [ data, msg ].postln;
        msg = [ "/minibee/custom", beeid ] ++ msgdata;
        //[ data, msgdata, msg ].postln;
        // msg.postln;
        //"solotope %\n".postf( msg );
		this.addToQueue( msg, name );
	}

	addToQueue{ |msg,name|
		if ( poly.notNil ){
			//			queue.addLastWithRedundancy( ("X" ++ beeid ++ "_" ++ name).asSymbol, msg, this.redundancy );
			queue.addLast( ("X" ++ beeid ++ "_" ++ name).asSymbol, msg );
		}{
            oscTarget.sendMsg( *msg );
            // network.setData( *msg );
		};
	}

	// input: envelope: 4 ('I','a',up,down) - node 2
	ampTrack_{ |aup, ad|
		ampup = aup;
		ampdown = ad;
		this.sendControl( 2, [ $I.ascii, $a.ascii, ampup, ampdown ], \input );
	}

    /*
	setMappingHooks{
		nodes.do{ |it,i|
			network.addHook( it, {
				network.add( "beeC" ++ beeid ++ "_" ++ i, it );
				//	network.addExpected( it, "beeC" ++ beeid ++ "_" ++ i, sizes[i] );
				this.remapNodeToBee( it );
			});
		};
	}

	remapNodeToBee{ |node|
		if ( broadcast ){
			network.mapHive( node, \custom );
		}{
			network.mapBee( node, beeid, \custom );
		};
	}
    */

	remapBee{ // dummy method
        /*
		if ( broadcast ){
			nodes.do{ |it| network.mapHive( it, \custom ) };
		}{
			nodes.do{ |it| network.mapBee( it, beeid, \custom ); };
		};
        */
	}

	ampTrackValue{
        if ( network.notNil ){
            ^network.nodes[ beeid ].slots[0].value;
        };
        ^0
	}

}
