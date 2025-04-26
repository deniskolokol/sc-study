(
x = Array.newClear(5);
[4, 7, 1.2, 19, 9]. do { |i, c|
    x[c] = i.squared;
    postf("%: % ^ 2 = %\n", c, i, x[c])
};

x
)

z = (1..10).collect(_.squared);


x = {VarSaw.ar(40!2, 0, 0.05)}.play;
x.free;


// Iteration in SynthDef - example 1
(
SynthDef.new(\iter, { |freq|
    var temp, sum, env;
    sum = 0;
    env = EnvGen.kr(
        Env.perc(0.01, 5, 1, -2),
        doneAction:2
    );
    10.do {
        temp = VarSaw.ar(
            freq * {Rand(0.99, 1.02)}!2,
            Rand(0.0, 1.0)!2, // randomize phase a bit to smooth out the innitial pop
            Rand(0.005, 0.05)!2 // randomize duty cycle
        );
        sum = sum + temp;
    };
    sum = sum * 0.05 * env;
    Out.ar(0, sum);
}).add;
)

Synth(\iter, [\freq, 40]);
Synth(\iter, [\freq, 400]);
Synth(\iter, [\freq, 300]);
Synth(\iter, [\freq, 250]);
Synth(\iter, [\freq, 224]);

Synth(\iter, [\freq, 66.midicps]);
Synth(\iter, [\freq, 73.midicps]);
Synth(\iter, [\freq, 80.midicps]);
Synth(\iter, [\freq, 75.midicps]);


// Generally it is not recommended to use language side constructions like
// .do() to create multiple sinths, as there is a risk to loose sample
// accuracy if using a lot of heavy-duty, complicated synths.
[53, 59, 63, 68].do { |midinote| Synth(\iter, [\freq, midinote.midicps])}


// Iteration in SynthDef - example 2
(
SynthDef.new(\iter2, {
    arg freq=200, dev=1.02;
    var temp, sum;
    sum = 0;
    10.do { |count|
        temp = SinOsc.ar(
            freq *
            (count + 1) *
            LFNoise1.kr({Rand(0.05, 0.2)} ! 2).range(dev.reciprocal, dev)
        );
        temp = temp * LFNoise1.kr({Rand(0.5, 8)} ! 2).exprange(0.01, 1);
        sum = sum + temp;
    };
    sum = sum * 0.05;
    Out.ar(0, sum);
}).add
)

x = Synth(\iter2, [\freq, 125])
x.set(\freq, 100);
x.set(\dev, 2.5);
x.free;