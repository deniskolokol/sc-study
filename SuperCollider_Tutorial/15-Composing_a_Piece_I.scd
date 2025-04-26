(
SynthDef(\bpsaw, {
    arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
    cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
    out=0, freq=440, detune=0.2, pan=0, amp=1;
    var sig, env;
    env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction:Done.freeSelf);
    sig = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio} ! 2);
    sig = BPF.ar(sig,
        {LFNoise1.kr(0.2).exprange(cfmin, cfmax)} ! 2,
        {LFNoise1.kr(0.1).exprange(rqmin, rqmax)} ! 2
    );
    sig = Balance2.ar(sig[0], sig[1], pan);
    sig = sig * env * amp;
    Out.ar(out, sig)
}).add
)


(
10.do {
    Synth(\bpsaw, [
        \freq, 50,
        \amp, 0.4,
        \cfmin, 50*2,
        \cfmax, 50*50,
        \rqmin, 0.005,
        \rqmax, 0.03,
        \pan, 0
    ])
}
)


//beyond stereo

s.options.numOutputBusChannels_(8);
s.reboot;
s.meter;

(
SynthDef(\bpsaw, {
    arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
    cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
    out=0, freq=440, detune=0.2, pan=0, amp=1;
    var sig, env;
    env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction:Done.freeSelf);
    sig = Saw.ar(freq * LFNoise1.kr(0.5, detune).midiratio);
    sig = BPF.ar(sig,
        LFNoise1.kr(0.2).exprange(cfmin, cfmax),
        LFNoise1.kr(0.1).exprange(rqmin, rqmax)
    );
    sig = PanAz.ar(8, sig, LFNoise1.kr(0.5));
    sig = sig * env * amp;
    Out.ar(out, sig)
}).add
)


(
10.do {
    Synth(\bpsaw, [
        \freq, 20,
        \amp, 0.5,
        \detune, 1,
        \cfmin, 20*40,
        \cfmax, 20*50,
        \rqmin, 0.005,
        \rqmax, 0.03,
        \pan, -0.75
    ])
}
)


// Nested randomness

(
SynthDef(\bpsaw, {
    arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
    cfmin=500, cfmax=2000, cfhzmin=0.1, cfhzmax=0.3,
    lsf=200, ldb=0,
    rqmin=0.1, rqmax=0.2,
    out=0, freq=440, detune=0.2, pan=0, amp=1;
    var sig, env;
    env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction:Done.freeSelf);
    sig = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio} ! 2);
    sig = BPF.ar(sig,
        {
            LFNoise1.kr(
                LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
            ).exprange(cfmin, cfmax)
        } ! 2,
        {LFNoise1.kr(0.1).exprange(rqmin, rqmax)} ! 2
    );
    sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
    sig = Balance2.ar(sig[0], sig[1], pan);
    sig = sig * env * amp;
    Out.ar(out, sig)
}).add
)


(
10.do {
    Synth(\bpsaw, [
        \freq, 50,
        \amp, 0.4,
        \cfmin, 50*2,
        \cfmax, 50*50,
        \rqmin, 0.005,
        \rqmax, 0.03,

        \cfhzmin, 1, // sweeping effect pronounced
        \cfhzmax, 6 // up to 30-40 - partials disappear in a bubbling effect
    ])
}
)


// Chord progression
(
// pads
~chords = Pbind(
    \instrument, \bpsaw,
    \dur, 5,
    \midinote, Pxrand([
        [23, 35, 54, 63, 64],
        [45, 52, 54, 59, 61, 64],
        [28, 40, 47, 56, 59, 63],
        [42, 52, 57, 61, 63]
    ], inf),
    \detune, Pexprand(0.05, 0.2, inf),
    \cfmin, 100,
    \cfmax, 1500,
    \rqmin, Pexprand(0.01, 0.15, inf),
    \atk, Pwhite(2.0, 2.5, inf),
    \rel, Pwhite(6.5, 10, inf),
    \ldb, 6,
    \amp, 0.2,
    \out, 0
).play;

~marimba = Pbind(
    \instrument, \bpsaw,
    \dur, Prand([1, 0.5], inf),
    \freq, Prand([1/2, 2/3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf),
    \detune, 0, // in this case changing it will not detune the "maribmba" freq, but slow down or speed up the rhythm (use \cfmax instead)
    \rqmin, 0.005,
    \rqmax, 0.008,
    \cfmin, Prand((Scale.major.degrees + 64).midicps, inf) * Prand([0.5, 1, 2, 4], inf),
    \cfmax, Pkey(\cfmin) * Pwhite(1.008, 1.025, inf), // "detune" the synth
    \atk, 3,
    \sus, 1,
    \rel, 5,
    \amp, 1,
    \out, 0
).play;
)

~marimba.stop
~chords.stop