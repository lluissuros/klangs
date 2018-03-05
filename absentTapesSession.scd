// This is a session to play klankPulse.scd
// First execute the code below with all the defs

s.record;
s.stopRecording;


//TODO: Make it dependent on Scale and ratios
1- Try to mimic what we have by using scale
2- abstract the scale and the baseFreq, so we have a nice versatility of baseFreq and modes.
3- Diferent Tdefs with diferent cool harmonies.


//dirty POC

//degreeToFreq (degree, rootFreq, octave)

{Scale.minor.degreeToFreq(2, 60, 1)}.()





/*++++++++++++++++++++++++++++++++++++++++
=======   PERFORMANCE =================
++++++++++++++++++++++++++++++++++++++++*/

//can play with these:
Scale.directory;

f[\changeScale].(Scale.major.tuning_(\just));
f[\changeScale].(Scale.partch_o1);


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



//test
Scale.directory;
~baseScale =  Scale.partch_o1;
~baseScale =  Scale.major;
~baseScale.degreeToFreq( 1, ~baseFreq, 0 );

Scale.kumoi.degrees;
Scale.partch_o1.degrees;

Scale.partch_o1.degreeToRatio(2, 1) * 60



/*++++++++++++++++++++++++++++++++++++++++
=======   DEFINITIONS =================
++++++++++++++++++++++++++++++++++++++++*/

(
//GLOVARS
~baseFreq = 60;
~baseScale =  Scale.major;
~baseScale.tuning_(\just);


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





