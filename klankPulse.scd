/*
Using Klang to generate rythmic pads. Generate new rythms and resonance in every iteration, each rythm is a combination of n integer mods and the Synth expects an Array.
The DynKlang version is more expensive, allows to detune the resonances.

Use the Tdef \test to understand properties better.
*/

/*
===================================
1 - DEFINITION
===================================
*/

(
SynthDef(\klankPulse,{
	|out = 0,
	freq = 65,
	topFreq = 6000.0,
	ringLength = 3,
	atk = 4,
	sus = 6,
	rel = 4,
	pulseFreq =  #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	pan = 0,
	amp = 1|

	var trigFunc = {|beats|
		beats = beats.asArray;
		beats.inject(0, {|acc, e| acc + Impulse.kr(e)});
	};

	var freqs =  ({LinRand(0, topFreq).round(freq) + freq}).dup(12);
	var rings =  {Rand(0.1, ringLength)}.dup(12);

	var trig = trigFunc.(pulseFreq);
    var env = EnvGen.kr(Env.linen(atk, sus, rel, 1, 4), doneAction:2);
	var gen = EnvGen.kr(
		Env.perc(0.001,
		0.001,
		1, -4), trig);

	var inputSound = BrownNoise.ar(0.005) * gen * amp;
	//var inputSound = Dust.ar(10000, mul:0.005) * gen * amp;

	var z = Klank.ar(
        `[freqs, nil, rings],
        inputSound
    );

    Out.ar(out, Pan2.ar(z*env, pan));
}).add;


SynthDef(\dynKlankPulse,{
	|out = 0,
	freq = 65,
	topFreq = 6000.0,
	ringLength = 3,
	atk = 4,
	sus = 6,
	rel = 4,
	pulseFreq =  #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	pan = 0,
	amp = 1|

	var trigFunc = {|beats|
		beats = beats.asArray;
		beats.inject(0, {|acc, e| acc + Impulse.kr(e)});
	};

	var freqs =  ({LinRand(0, topFreq).round(freq) + freq}).dup(12);
	var dynFreqs = freqs.collect({
		|f|
		var start = 1;
		if(0.5.coin) {start = 2} {start = 0.5};
		f * XLine.kr(start,1, atk) });

	var rings =  {Rand(0.1, ringLength)}.dup(12);

	var trig = trigFunc.(pulseFreq);
    var env = EnvGen.kr(Env.linen(atk, sus, rel, 1, 4), doneAction:2);
	var gen = EnvGen.kr(
		Env.perc(0.001,
		0.001,
		1, -4), trig);

	var pulse = BrownNoise.ar(0.005) * gen * amp;
	//var pulse = Dust.ar(10000, mul:0.005) * gen * amp;

	var z = DynKlank.ar(
        `[dynFreqs, nil, rings],
        pulse
    );

    Out.ar(out, Pan2.ar(z*env, pan));
}).add;


SynthDef.new(\iterPulse,{
	arg
	freq = 65,
	out = 0,
	amp=1,
	minffreq=80,
	maxffreq=2000,
	pan=0,
	atk = 4,
	sus = 6,
	rel = 4,
	pulseFreq =  #[7,8];

	var trigFunc = {|beats|
		beats = beats.asArray;
		beats.inject(0, {|acc, e| acc + Impulse.kr(e)});
	};
	var fatSawMaker = {|numSynths|
		var sumSynth = 0;
		numSynths.do{
			sumSynth = sumSynth +
			VarSaw.ar(
				freq * {Rand(0.99,1.02)},
				{Rand(0.0,1.0)},
				{ExpRand(0.005,0.05)});
		};
		sumSynth;
	};
	var trig = trigFunc.(pulseFreq);
    var env = EnvGen.kr(Env.linen(atk, sus, rel, 1, 4), doneAction:2);
	var gen = EnvGen.kr(
		Env.perc(0.01,
		{Rand(0.3,0.5)}, // should be a param
		1, -4), trig);

	var sound = fatSawMaker.(20) * 0.04 * env * amp * gen;

	Out.ar(0, Pan2.ar(sound, pan));
}).add;




//patterns
p = ( );
p.pulses = (1..5).addAll([7]);

Pdefn(\oneRand, Pfunc({ p.pulses.choose}));
Pdefn(\twoRand, Pfunc({ {p.pulses.choose}!2 }));
Pdefn(\twoConsecutivesRand, Pfunc({
	var num = p.pulses.choose;
	[num, num+1]}));
Pdefn(\oneIncremented, Pseq( p.pulses , inf));
Pdefn(\twoIncrementedConsecutives, Pseq(p.pulses.collect({ |e| [e, e+1] }), inf) );
)


(
Tdef(\testSimple, {
	var sustain = 6;
	var transition = 4;
	var overlap = 1;
	var period = transition *2 + sustain/ overlap;
    loop {
        Synth(\dynKlankPulse, [
			\atk, transition,
			\sus, sustain,
			\rel, transition,
			\pan, 1.0.rand2,
			\freq, 65,
			\topFreq, 6000,
			\ringLength, 2,
			\pulseFreq, [7,8],
			\amp, 1
        ]);
        period.wait;
    }
});
Tdef(\testSimple).play;
)



(
Tdef(\player1, {
	|args|
	var period;

	//defaults
	args.pulseFreq = Pdefn(\twoIncrementedConsecutives).asStream;
	args.baseFreq = Scale.major.degreeToFreq(1, 20.midicps, 1);
	args.sustain = 6;
	args.transition = 4;
	args.overlap = 15;
	args.topFreq = 6000;
	args.ringLength = 3;
	args.instrument = \dynKlankPulse;

	period = args[\transition] *2 + args[\sustain] / args[\overlap];

    loop {
		period = args[\transition] *2 + args[\sustain] / args[\overlap];

		Synth(args[\instrument], [
			\atk, args[\transition],
			\sus, args[\sustain],
			\rel, args[\transition],
			\pan, 1.0.rand2,
			\freq, args[\baseFreq],
			\topFreq, args[\topFreq],
			\ringLength, args[\ringLength],
			\pulseFreq, args[\pulseFreq].next,
			\amp, 0.3
        ]);
        period.wait;
    }
});
Tdef(\player1).play;
)


/*
===================================
2 - PERFORMANCE
===================================
*/

/*
todo:
 - different Task with a Routine, changing params, with fadeTime.
 -GUI
*/

//set new pulsePatterns
p.pulses = [7];
p.pulses = (1..5).addAll([7]);

Tdef(\player1).set(\pulseFreq, Pdefn(\oneRand).asStream);
Tdef(\player1).set(\pulseFreq, Pdefn(\twoRand).asStream);
Tdef(\player1).set(\pulseFreq, Pdefn(\twoConsecutivesRand).asStream);
Tdef(\player1).set(\pulseFreq, Pdefn(\oneIncremented).asStream);
Tdef(\player1).set(\pulseFreq, Pdefn(\twoIncrementedConsecutives).asStream);

Tdef(\player1).set(\baseFreq, 100)
Tdef(\player1).set(\baseFreq, Scale.minor.degreeToFreq([1,3,5].choose.postln, 20.midicps, 1));
Tdef(\player1).set(\baseFreq, 60);

Tdef(\player1).set(\overlap, 1)
Tdef(\player1).set(\overlap, 5)

Tdef(\player1).set(\transition, 0.1)
Tdef(\player1).set(\transition, 4)

Tdef(\player1).set(\sustain, 0.2)
Tdef(\player1).set(\sustain, 6)

Tdef(\player1).set(\ringLength, Pdefn(\oneIncremented).asStream / 2)
Tdef(\player1).set(\ringLength, 10)

Tdef(\player1).set(\topFreq, 600)
Tdef(\player1).set(\topFreq, 6000)

Tdef(\player1).set(\instrument, \dynKlankPulse);
Tdef(\player1).set(\instrument, \klankPulse);

TempoClock.default.tempo = 2;

Tdef(\player1).set(\amp, 0.1);


Tdef(\player1).stop;
Tdef(\player1).play;




//TODO: Map to synth params
a = Synth('help-dynKlank');
a.setn(\freqs, Array.rand(4, 500, 2000));
a.setn(\amps, Array.exprand(4, 0.01, 1));
{ Out.kr(102, MouseX.kr(1, 2) * Array.rand(4, 500, 2000)) }.play;
a.mapn(\freqs, 102, 4);





//AUTOPLAYER
(
Tdef(\autoPlayer1, {
	Tdef(\player1).play;

	loop {
		"".postln;
		"========new===========".postln;
		Tdef(\player1).set(\instrument, [\dynKlankPulse, \klankPulse].choose.postln); 2.wait;

		Tdef(\player1).set(\pulseFreq, [
			Pdefn(\oneRand),
			Pdefn(\twoRand),
			Pdefn(\twoConsecutivesRand),
			Pdefn(\oneIncremented),
			Pdefn(\twoIncrementedConsecutives)].choose.postln.asStream); 2.wait;

		//Tdef(\player1).set(\overlap, 20.rand.max(1).postln);
		Tdef(\player1).set(\baseFreq, Scale.major.degreeToFreq([1,3,5].choose.post, 20.midicps, 1)); "<-- baseFreq degree ".postln; 2.wait;
		Tdef(\player1).set(\overlap, gauss(15,5).max(5).post); "<-- overlap ".postln; 2.wait;
		Tdef(\player1).set(\transition, gauss(7,2).max(2).post); "<-- transition ".postln; 2.wait;
		Tdef(\player1).set(\sustain, gauss(10,2).max(2).post); "<-- sustain ".postln; 2.wait;
		Tdef(\player1).set(\ringLength, gauss(3,2).max(1).post); "<-- ringLength ".postln; 2.wait;
		Tdef(\player1).set(\topFreq, gauss(6000,5000).max(300).post); "<-- topFreq ".postln; 2.wait;
		"next in ".post;
		gauss(18,5).max(3).postln.wait;
    }
});
Tdef(\autoPlayer1).play;
)
Tdef(\autoPlayer1).stop;




//best plays of Autoplayer
========new===========
dynKlankPulse
Pdefn('twoIncrementedConsecutives')
5<-- baseFreq degree
23.755988297985<-- overlap
4.9093128231368<-- transition
14.159145395625<-- sustain§
5.5619126184901<-- ringLength
6546.9616776204<-- topFreq
next in 40.378011990171

========new===========
dynKlankPulse
Pdefn('twoRand')
5<-- baseFreq degree
17.821676060383<-- overlap
5.7210822393612<-- transition
10.056875105664<-- sustain
5.7376701703618<-- ringLength
14835.375343968<-- topFreq
next in 35.043354301193

========new===========
dynKlankPulse
Pdefn('twoIncrementedConsecutives')
5<-- baseFreq degree
23.439219461427<-- overlap
6.3130743249853<-- transition
11.700021727256<-- sustain
7.4419327751855<-- ringLength
5596.6905765275<-- topFreq

========new===========
klankPulse
Pdefn('oneRand')
5<-- baseFreq degree
19.596576569032<-- overlap
6.3712123812948<-- transition
9.0335344092917<-- sustain
4.4929529873241<-- ringLength
9051.0148496385<-- topFreq
next in 24.756166599567

========new===========
klankPulse
Pdefn('twoRand')
1<-- baseFreq degree
11.895928570241<-- overlap
7.6139846150542<-- transition
9.5550017511552<-- sustain
3.4495942598109<-- ringLength
8302.8671728229<-- topFreq
next in 25.826394485539
