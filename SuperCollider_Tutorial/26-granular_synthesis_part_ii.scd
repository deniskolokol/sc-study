// Lesson:
// https://www.youtube.com/watch?v=CbIwWsGl-zc&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=28


(
s.meter;
s.plotTree;
s.scope;
)

(
x = {
    var sig = SoundIn.ar(0 ! 2);
    sig = GrainIn.ar(1, Dust.ar(20), 0.08, sig);
}.play
)
// GrainIn is a "gloryfied" Env generator - compare to this:
(
x = {
    var sig = SoundIn.ar(0 ! 2);
    sig = sig * EnvGen.ar(Env.sine(0.08), Dust.ar(20));
}.play
)

x.free


b = Buffer.alloc(s, s.sampleRate * 5, 1);
(
~micBus = Bus.audio(s, 1);
~ptrBus = Bus.audio(s, 1);
)

(
SynthDef.new(\mic, {
    arg in=0, out=0, amp=1;
    var sig;
    sig = SoundIn.ar(in) * amp;
    Out.ar(out, sig);
}).add;

// Pointer.
SynthDef.new(\ptr, {
    arg out=0, buf=0, rate=1;
    var sig = Phasor.ar(0, BufRateScale.kr(buf) * rate, 0, BufFrames.kr(buf));
    Out.ar(out, sig);
}).add;

// Reading the mic signal & the ramp signal and recording it into the buffer.
SynthDef.new(\rec, {
    arg ptrIn=0, micIn=0, buf=0;
    var ptr, sig;
    ptr = In.ar(ptrIn, 1);
    sig = In.ar(micIn, 1);
    BufWr.ar(sig, buf, ptr);
}).add;

// Granulator.
SynthDef.new(\gran, {
    arg amp=0.5, buf=0, out=0,
    atk=1, rel=1, gate=1,
    sync=1, dens=40,
    baseDur=0.05, durRand=1,
    rate=1, rateRand=1,
    pan=0, panRand=0,
    grainEnv=(-1), ptrBus=0, ptrSampleDelay=20000,
    ptrRandSamples=5000, minPtrDelay=1000;

    var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl,
    ptr, ptrRand, totalDelay, maxGrainDur;

    env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
    densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
    durCtrl = baseDur * LFNoise1.ar(100).exprange(1/durRand, durRand);
    rateCtrl = rate * LFNoise1.ar(100).exprange(1/rateRand, rateRand);
    panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

    ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples);
    totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

    ptr = In.ar(ptrBus, 1);
    ptr = ptr - totalDelay; // grain pointer value lags behind pointer to ptrSampleDelay samples
                            // adjusted to ptrRand
    ptr = ptr / BufFrames.kr(buf); // GrainBuf expects a nomalized value between 0 and 1

    maxGrainDur = (totalDelay / rateCtrl) / SampleRate.ir;
    durCtrl = min(durCtrl, maxGrainDur);

    sig = GrainBuf.ar(
        numChannels: 2,
        trigger: densCtrl,
        dur: durCtrl,
        sndbuf: buf,
        rate: rateCtrl,
        pos: ptr,
        interp: 2,
        pan: panCtrl,
        envbufnum: grainEnv
    );

    sig = sig * env * amp;
    Out.ar(out, sig);
}).add;
)

(
~micGrp = Group.new;
~ptrGrp = Group.after(~micGrp);
~recGrp = Group.after(~ptrGrp);
~granGrp = Group.after(~recGrp);
)


(
Synth(\mic, [\in, 0, \out, ~micBus], ~micGrp);
Synth(\ptr, [\buf, b, \out, ~ptrBus], ~ptrGrp);
Synth(\rec, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, b], ~recGrp);
)

s.defaultGroup.deepFree; // free the synths but leave the Groups intact

// Complex / chaotic delay line
(
b.zero;
~g = 5.collect({
    arg n;
    Synth(\gran, [
        \amp, n.linlin(0, 4, -3, -20).dbamp,
        \buf, b,
        \out, 0,
        \atk, 1,
        \rel, 1,
        \gate, 1,
        \sync, 1,
        \dens, exprand(20, 40),
        \baseDur, 0.08,
        \durRand, 1.5,
        \rate, 1,
        \rateRand, 2.midiratio, // randomize with 2 semitones up and down
        \pan, 0,
        \panRand, 0.5,
        \grainEnv, (-1),
        \ptrBus, ~ptrBus,
        \ptrSampleDelay, n.linlin(0, 4, 20000, s.sampleRate*2),
        \ptrRandSamples, 10000,
        \minPtrDelay, 1000
    ], ~granGrp)
});
)

// Freeze (to un-freeze, set 1)
~ptrGrp.set(\rate, 0);

~g.do { |n| n.set(\gate, 0)};

// Harmonizer.
(
b.zero;
~g = Synth(\gran, [
    \amp, 0.5,
    \buf, b,
    \out, 0,
    \atk, 1,
    \rel, 1,
    \gate, 1,
    \sync, 0,
    \dens, 200,
    \baseDur, 0.1,
    \durRand, 1,
    \rate, 2.midiratio,
    \rateRand, 1,
    \pan, 0,
    \panRand, 0,
    \grainEnv, -1,
    \ptrBus, ~ptrBus,
    \ptrSampleDelay, 587, // for pitch-shifting down use 1
    \ptrRandSamples, 0,
    \minPtrDelay, 0
], ~granGrp)
)

// No problem with pitch-shifting down (e.g. \rate, -3.midiratio)
// But for pitch-shifting up, we should use a specific \ptrSampleDelay:
(0.1 * 2.midiratio) - 0.1 * s.sampleRate;

~g.set(\gate, 0);

// Harmonized chord.
(
b.zero;
~g = [-5, -3, 0, 2, 4].collect({ |n|
    Synth(\gran, [
        \amp, 0.5,
        \buf, b,
        \out, 0,
        \atk, 1,
        \rel, 1,
        \gate, 1,
        \sync, 0,
        \dens, 200,
        \baseDur, 0.1,
        \durRand, 1,
        \rate, n.midiratio,
        \rateRand, 1,
        \pan, 0,
        \panRand, 0,
        \grainEnv, -1,
        \ptrBus, ~ptrBus,
        \ptrSampleDelay, ((0.1 * n.midiratio) - 0.1 * s.sampleRate).asInteger,
        \ptrRandSamples, 0,
        \minPtrDelay, 0
    ], ~granGrp)
})
)

~g.do { |n| n.set(\gate, 0)};
