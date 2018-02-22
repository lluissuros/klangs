// This is a session to play klankPulse.scd
// First execute the code below with all the defs

s.record;
s.stopRecording;


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






//DEFINITIONS
(
Tdef(\lowerNotes, {
	var freqs = Pseq([
		60,
		120,
		120 * 5/4,
		60,
		60 * 4/5,
		60], inf).asStream;

    loop {
		Tdef(\player1).set(\baseFreq, freqs.next.postln);
		6.wait;
		// 1.wait;
    }
});


Tdef(\higherNotes, {
	var freqs = Pseq([
		30,
		240 * 5/4,
		480 * 3/2,
		600,
		1200 * 3/4,
		4800
	], inf).asStream;

    loop {
		Tdef(\player1).set(\baseFreq, freqs.next.postln);
		// 2.wait;
        10.wait;
    }
});


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
	var values = (2..25);
    values.do { |val|
		Tdef(\player1).set(\overlap, val.postln);
		5.wait;
    }
});
)
