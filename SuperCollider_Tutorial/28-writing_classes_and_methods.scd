// https://www.youtube.com/watch?v=9gs0WPnxyak&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=29

// adding methods to classes

144.tempodur; // ERROR! no such method (this is what we want to implement)
18.5.tempodur;

3.24.durtempo;

(18/60).reciprocal * 8

TempoClock(144/60).beatDur

(
~tempodur = {
    arg bpm;
    60/bpm;
}
)

~tempodur.(36)

Platform.userExtensionDir;
Platform.systemExtensionDir;

// Class and Instance methods
a = Array.series(8, 1, 3);
a.series(8, 1, 3); // ERROR! Not a class method
a = a.reverse;
Array.reverse;  // ERROR! Not a instance method

Integer.browse;

// Env with rand segments
(
var env, numSegs=16;
env = Env.new(
    {rrand(-1.0, 1.0)} ! (numSegs+1),
    {exprand(1, 10)} ! numSegs,
    {rrand(-4.0, 4.0)} ! numSegs
);
env.plot
)

Env.browse

Env.rand(16).plot;
Env.rand(12, 3).plot;
Env.rand(5, 3, false).plot;


// Example with sound
{SinOsc.ar(60.midicps) * EnvGen.ar(Env.perc(0.001, 0.2), doneAction:2) * 0.5 ! 2}.play

60.play
67.play
72.play

b = 42.play
b

// Pseudo-UGens

// simplify this - create a Pseudo-UGen:
(
SynthDef(\reverb, {
    arg in=0, dec=3.5, mix=0.08, lpf1=2000, lpf2=6000, predelay=0.25, out=0;
    var dry, wet, sig;
    dry = In.ar(in, 2);
    wet = In.ar(in, 2);
    wet = 16.collect {
        var temp = CombL.ar(
            wet,
            0.1,
            LFNoise1.kr({ExpRand(0.02, 0.04)} ! 2).exprange(0.02, 0.099),
            dec
        );
        temp = LPF.ar(temp, lpf1);
    }.sum * 0.25;
    8.do {
        wet = AllpassL.ar(
            wet,
            0.1,
            LFNoise1.kr({ExpRand(0.02, 0.04)} ! 2).exprange(0.02, 0.099),
            dec
        );
    };
    wet = LeakDC.ar(wet);
    wet = LPF.ar(wet, lpf2, 0.5);
    sig = dry.blend(wet, mix);
    Out.ar(out, sig);
}).add
)

// and change to the following:
(
SynthDef(\reverb, {
    arg in=0, dec=3.5, mix=0.08, lpf1=2000, lpf2=6000, predelay=0.25, out=0;
    var dry, wet, sig;
    sig = In.ar(in, 2);
    sig = VerbEF.ar(sig, dec, mix, lpf1, lpf2, predelay);
    Out.ar(out, sig);
}).add
)

b = Bus.audio(s, 2);
r = Synth.new(\reverb, [\in, b]);

r.set(\lpf2, 400);
67.play(b)


(
var win;
win = Window.new("", Window.screenBounds, false, false);
win.view.background_(Color.black);
win.view.keyDownAction_({
    arg view, char, mod, unicode;
    if (unicode == 27) {win.close};
});
win.front;
)


Window.blackout




