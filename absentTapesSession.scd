// This is a session to play klankPulse.scd
// First execute the code below with all the defs

s.record;
s.stopRecording;


//TODO: Make it dependent on Scale and ratios
1- Try to mimic what we have by using scale //done
2- abstract the scale and the baseFreq, so we have a nice versatility of baseFreq and modes. //done, with glovars
3- Diferent Tdefs with diferent cool harmonies.





//can play with these:
Scale.directory;
Scale.romanianMinor.degrees;

f[\changeScale].(Scale.major.tuning_(\just));
f[\changeScale].(Scale.partch_o1);

f[\changeScale].(Scale.kumoi); //nice, bright and tense
f[\changeScale].(Scale.zhi); //nice and bright
f[\changeScale].(Scale.romanianMinor); //darker but nice also

Tdef(\player1).set(\ringLength, 1);

Tdef(\higherNotes).play;
Tdef(\higherNotes2).stop;
Tdef(\lowerNotes).play;
Tdef(\lowerNotes_I_II_V_VI).stop;

Tdef(\player1).set(\baseFreq, 60);
~baseFreq = ~baseScale.degreeToFreq( ~baseScale.degrees.choose, ~baseFreq, [-1,-2].choose);




/*++++++++++++++++++++++++++++++++++++++++
=======    MIDIdefs    =================
++++++++++++++++++++++++++++++++++++++++*/

(
MIDIClient.init;
MIDIIn.connectAll;

MIDIdef.freeAll;

//use val.linexp(0,127,0,0.1) or linexp to map from 127 to good values!!!


//sliders
MIDIdef.cc(\slider0ToSustain, {|val, num, chan, src|
	var sustain = val.linexp(0,127,0.5,30).round(0.01);
	("sustain "+ sustain).postln;
	Tdef(\player1).set(\sustain, sustain);
}, 0, 0);

MIDIdef.cc(\slider1ToTransition, {|val, num, chan, src|
	var transition = val.linexp(0,127,1,15).round(1);
	("transition "+ transition).postln;
	Tdef(\player1).set(\transition, transition);
}, 1, 0);

MIDIdef.cc(\slider2ToOverlap, {|val, num, chan, src|
	var overlap = val.linexp(0,127,1,80).round(1);
	("overlap "+ overlap).postln;
	Tdef(\player1).set(\overlap, overlap);
}, 2, 0);

MIDIdef.cc(\slider3ToRingLength, {|val, num, chan, src|
	var ringLength = val.linexp(0,127,0.01,80).round(0.001);
	("ringLength "+ ringLength).postln;
	Tdef(\player1).set(\ringLength, ringLength);
}, 3, 0);

MIDIdef.cc(\slider4ToMaxFreq, {|val, num, chan, src|
	var maxffreq = val.linexp(0,127,80,15000).round(0.01);
	("maxffreq "+ maxffreq).postln;
	Tdef(\player1).set(\maxffreq, maxffreq);
}, 4, 0);


//buttons
//TODO> single push to change
~instruments = Pseq([\iterMouseFilterPulse, \dynKlankPulse, \klankPulse, \iterPulse], inf).asStream;
MIDIdef.cc(\buttonChangeInstrument, {|val, num, chan, src|
	var instrument = ~instruments.next;
	("instrument: "+ instrument).postln;
	Tdef(\player1).set(\instrument, instrument);
}, 32, 0);

)


//SECTIONs
(
//part1
Tdef(\player1).play;

Tdef(\player1).set(\sustain, 10);
Tdef(\player1).set(\instrument, \dynKlankPulse);
Tdef(\player1).set(\baseFreq, 60);
Tdef(\player1).set(\transition, 4);

Tdef(\player1).set(\pulseFreq, Pdefn(\twoConsecutivesRand).asStream);

Tdef(\rampUpOverlap).play;
Tdef(\longRingsToShort).play;
Tdef(\higherNotes).play;
Tdef(\lowerNotes).play;
)

Tdef(\player1).set(\pulseFreq, Pdefn(\twoRand).asStream);

(
//part 2
Tdef(\longRingsToShort).stop;
Tdef(\higherNotes).stop;
Tdef(\automateShortRings).play;
)

(
//part 3
Tdef(\overlapToHigh).play;
)

(
//part 4
Tdef(\automateInstrument).play;
Tdef(\higherNotes).play;
)


(
//before the end
Tdef(\player1).set(\sustain, 30);
)
(
//and the end
Tdef(\player1).set(\sustain, 30);
Tdef(\player1).stop;
)



/*++++++++++++++++++++++++++++++++++++++++
=======   DEFINITIONS =================
++++++++++++++++++++++++++++++++++++++++*/

(
//GLOVARS
~baseFreq = 60;
~baseScale =  Scale.major.tuning_(\just);


//FUNCTIONS
f = f ? ();

f[\createHarmonicDefs] = {
	"updating harmonies".postln;

	Tdef(\lowerNotes, {
		var freqs = Pseq([
			~baseScale.degreeToFreq( 0, ~baseFreq, 0 ),
			~baseScale.degreeToFreq( 0, ~baseFreq, 1 ),
			~baseScale.degreeToFreq( 2, ~baseFreq, 1 ),
			~baseScale.degreeToFreq( 0, ~baseFreq, 0 ),
			~baseScale.degreeToFreq( 5, ~baseFreq, -1 ),
			~baseScale.degreeToFreq( 0, ~baseFreq, 0 ),
		], inf).asStream;

		loop {
			Tdef(\player1).set(\baseFreq, freqs.next.postln);
			6.wait;
		}
	});


	Tdef(\lowerNotes_I_II_V_VI, {
		var freqs = Pseq([
			~baseScale.degreeToFreq( 0, ~baseFreq, 0 ),
			~baseScale.degreeToFreq( 2, ~baseFreq, 0 ),
			~baseScale.degreeToFreq( 6, ~baseFreq, 0 ),
			~baseScale.degreeToFreq( 5, ~baseFreq, 0 ),
		], inf).asStream;

		loop {
			Tdef(\player1).set(\baseFreq, freqs.next.postln);
			5.wait;
		}
	});

	Tdef(\higherNotes, {
		var freqs = Pseq([
			~baseScale.degreeToFreq( 0, ~baseFreq, -1 ),
			~baseScale.degreeToFreq( 2, ~baseFreq, 2 ),
			~baseScale.degreeToFreq( 4, ~baseFreq, 3 ),
			~baseScale.degreeToFreq( 2, ~baseFreq, 3 ),
			~baseScale.degreeToFreq( 6, ~baseFreq, 3 ),
			~baseScale.degreeToFreq( 2, ~baseFreq, 6 ),
		], inf).asStream;

		loop {
			Tdef(\player1).set(\baseFreq, freqs.next.postln);
			10.wait;
		}
	});

	Tdef(\higherNotes2, {
		var freqs = Pseq([
			~baseScale.degreeToFreq( 3, ~baseFreq, 4 ),
			~baseScale.degreeToFreq( 6, ~baseFreq, 4 ),
			~baseScale.degreeToFreq( 7, ~baseFreq, 4 ),
			~baseScale.degreeToFreq( 2, ~baseFreq, 6 ),
			~baseScale.degreeToFreq( 5, ~baseFreq, 5 ),
		], inf).asStream;

		loop {
			Tdef(\player1).set(\baseFreq, freqs.next.postln);
			9.wait;
		}
	});

	Tdef(\higherNotes2, {
		var freqs = Prand([
			~baseScale.degreeToFreq( 6, ~baseFreq, 5 ),
			~baseScale.degreeToFreq( 3, ~baseFreq, 4 ),
			~baseScale.degreeToFreq( 7, ~baseFreq, 5),
			~baseScale.degreeToFreq( 2, ~baseFreq, 4 ),
			~baseScale.degreeToFreq( 5, ~baseFreq, 4 ),
		], inf).asStream;

		loop {
			Tdef(\player1).set(\baseFreq, freqs.next.postln);
			9.wait;
		}
	});
};

f[\changeScale]= { |scale|
	~baseScale =  scale;
	f[\createHarmonicDefs].();
};



// TDEFS
f[\createHarmonicDefs].();

Tdef(\longRingsToShort, {
	var rings = (200..1) / 20;
	rings.do { |ring|
		Tdef(\player1).set(\ringLength, ring.postln);
		0.5.wait;
	}
});

Tdef(\automateShortRings, {
	var rings = Pseq((40..1).mirror / 100, inf).asStream;
	loop {
		Tdef(\player1).set(\ringLength, rings.next.postln);
		2.wait;
	}
});

Tdef(\automateInstrument, {
	var instruments = Pwrand(
		[\iterMouseFilterPulse, \dynKlankPulse, \klankPulse, \iterPulse],
		[6, 3, 2, 1].normalizeSum,
		inf)
	.asStream;

	loop {
		Tdef(\player1).set(\instrument, instruments.next.postln);
		0.2.wait;
	}
});


Tdef(\overlapToHigh, {
	(25..80).do { |overlap|
		Tdef(\player1).set(\overlap, overlap.next.postln);
		1.wait;
	}
});

Tdef(\rampUpOverlap, {
	var values = (5..25);
	values.do { |val|
		Tdef(\player1).set(\overlap, val.postln);
		5.wait;
	}
});
)