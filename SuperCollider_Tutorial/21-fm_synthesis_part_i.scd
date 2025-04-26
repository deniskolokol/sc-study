s.scope;
FreqScope.new;

x = {SinOsc.ar(500) * 0.2 ! 2}.play;
x = {SinOsc.ar(MouseY.kr(200, 5000, 1).poll + SinOsc.ar(MouseX.kr(1, 2000, 1).poll, mul:LFNoise0.kr(8).range(20, 10000))) * 0.2 ! 2}.play;
x.free;

(
SynthDef(\fm, {
    arg out=0, pan=0, carrFreq=500, modFreq=100, modAmp=200, amp=0.2, atk=0.01, rel=1.0;
    var carr, mod, env, signal;
    mod = SinOsc.ar(modFreq, mul:modAmp);
    carr = SinOsc.ar(carrFreq + mod);
    env = Env.perc(atk, rel).kr(doneAction:Done.freeSelf);
    signal = carr * amp * env;
    Out.ar(out, Pan2.ar(signal, pan))
}).add
)

(
p = Pbind(
    \instrument, \fm,
    \dur, 1/8,
    \carrFreq, Pexprand(20, 10000),
    \modFreq, Pexprand(20, 10000),
    \modAmp, Pwhite(0, 10000),
    \amp, Pexprand(0.1, 0.5),
    \atk, Pexprand(0.001, 0.5),
    \rel, Pexprand(0.05, 1.5),
    \pan, Pwhite(-1.0, 1.0),
).play;
)

p.stop;