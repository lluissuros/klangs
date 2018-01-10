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

	var inputSound = BrownNoise.ar(0.005) * gen * amp;
	//var inputSound = Dust.ar(10000, mul:0.005) * gen * amp;

	var z = DynKlank.ar(
        `[dynFreqs, nil, rings],
        inputSound
    );

    Out.ar(out, Pan2.ar(z*env, pan));
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

	period = args[\transition] *2 + args[\sustain] / args[\overlap];

    loop {
		period = args[\transition] *2 + args[\sustain] / args[\overlap];

//        Synth(\klankPulse, [
       Synth(\dynKlankPulse, [
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

Tdef(\player1).set(\ringLength, Pdefn(\oneIncremented).asStream / 0.5)
Tdef(\player1).set(\ringLength, 10)

Tdef(\player1).set(\topFreq, 600)
Tdef(\player1).set(\topFreq, 6000)

Tdef(\player1).stop;


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
		Tdef(\player1).set(\pulseFreq, [
			Pdefn(\oneRand),
			Pdefn(\twoRand),
			Pdefn(\twoConsecutivesRand),
			Pdefn(\oneIncremented),
			Pdefn(\twoIncrementedConsecutives)].choose.postln.asStream);

		//Tdef(\player1).set(\overlap, 20.rand.max(1).postln);
		Tdef(\player1).set(\baseFreq, Scale.major.degreeToFreq([1,3,5].choose.postln, 20.midicps, 1));

		Tdef(\player1).set(\overlap, gauss(15,5).max(5).postln);
		Tdef(\player1).set(\transition, gauss(7,2).max(2).postln);
		Tdef(\player1).set(\sustain, gauss(10,2).max(2).postln);
		Tdef(\player1).set(\ringLength, gauss(3,2).max(1).postln);
		Tdef(\player1).set(\topFreq, gauss(6000,5000).max(100).postln);
		"next in ".post;
		gauss(35,5).max(3).postln.wait;
    }
});
//Tdef(\autoPlayer1).fadeTime = 5;
Tdef(\autoPlayer1).play;
)
Tdef(\autoPlayer1).stop;