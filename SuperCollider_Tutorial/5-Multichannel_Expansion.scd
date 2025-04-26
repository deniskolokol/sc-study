s.meter;

(
x = {
    var sig, amp;
    amp = SinOsc.kr([3, 7]).range(0, 1);
    sig = SinOsc.ar([300, 800]);
    sig = sig * amp;
}.play;
)
x.free;


// Mixing
(
x = {
    var sig, amp;
    amp = SinOsc.kr([7, 2, 1, 0.2, 6]).range(0, 1);
    sig = SinOsc.ar([300, 500, 700, 900, 1100], mul:amp);
    Mix.new(sig) * 0.25; // back to mono
}.play;
)
x.free;

// Simple duplicate
(
x = {
    var sig, amp;
    amp = SinOsc.kr([7, 2, 1, 0.2, 6]).range(0, 1);
    sig = SinOsc.ar([300, 500, 700, 900, 1100], mul:amp);
    // Mix.new(sig).dup(2) * 0.25;
    // OR
    Mix.new(sig) ! 2 * 0.25;
}.play;
)
x.free;

// Distribute the whole array of signals over stereo field
(
x = {
    var sig, amp;
    amp = SinOsc.kr([7, 2, 1, 0.2, 6]).range(0, 1);
    sig = SinOsc.ar([300, 500, 700, 900, 1100], mul:amp);
    Splay.ar(sig) * 0.5;
}.play;
)
x.free;

// With envelope
(
SynthDef.new(\multi, {
    var env, sig, amp;
    env = EnvGen.kr(
        Env.new([0, 1, 0], [10, 10], [1, -1]),
        doneAction:2
    );
    amp = SinOsc.kr({ExpRand(0.2, 12)} ! 8).range(0, 1);
    sig = SinOsc.ar({ExpRand(50, 1200)} ! 8);
    sig = sig * amp * env;
    sig = Splay.ar(sig) * 0.5;
    Out.ar(0, sig);
}).add;
)

x = Synth(\multi);
x.free;