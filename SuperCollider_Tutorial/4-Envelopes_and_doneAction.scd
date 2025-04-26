(
{
    var sig, env;
    env = XLine.kr(1, 0.01, 1, doneAction:2);
    sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play
)

// dB
(
{
    var sig, env;
    env = Line.kr(1, -40, 1, doneAction:2);
    sig = Pulse.ar(ExpRand(30, 500)) * env.dbamp;
}.play
)

// Line/XLine doesn't limit to amp
(
(
{
    var sig, freq, env;
    env = Line.kr(1, -40, 5, doneAction:2);
    freq = XLine.kr(880, 110, 1);
    sig = Pulse.ar(freq) * env.dbamp;
}.play
)
)

// EnvGen
// curve
(
{
    var sig, env;
    env = EnvGen.kr(
        Env.new(
            [0, 1, 0.2, 0],
            [0.5, 1, 2],
            [10, -3, 0]),
        doneAction:2
    );
    sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play
)

// EnvGen
// gate
// see Help: SynthDef / UGen Graph Functions and Special Argument Forms #trigger rate
(
x = {
    arg t_gate=1;
    var sig, env;
    env = EnvGen.kr(
        Env.new(
            [0, 1, 0.2, 0],
            [0.5, 1, 2],
            [10, -3, 0]
        ),
        t_gate, doneAction:2);
    sig = Pulse.ar(LFPulse.kr(8).range(600, 900)) * env;
}.play
)

x.set(\t_gate, 1);
x.free

// ADSR
(
x = {
    arg gate=0;
    var sig, env, freq;
    freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1); // levelScale ~ mul, levelBias ~ add
    env = EnvGen.kr(Env.adsr, gate, doneAction:2); // to remove synth after the release, use doneAction:2
    sig = VarSaw.ar(SinOsc.kr(freq).range(500, 1000)) * env;
}.play;
)

x.set(\gate, 0)
