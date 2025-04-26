x = { SinOsc.ar(500 + SinOsc.ar(2000, mul:200)) * 0.2 ! 2 }.play;

x = { SinOsc.ar(200 + SinOsc.ar(400, mul:200)) * 0.2 ! 2 }.play;

x.free


(
SynthDef(\fm, {
    arg out=0, pan=0, freq=500, mRatio=1, cRatio=1, modAmp=200, amp=0.2, atk=0.01, rel=3.0;
    var carr, mod, env, signal;
    mod = SinOsc.ar(freq * mRatio, mul:modAmp);
    carr = SinOsc.ar(freq * cRatio + mod);
    env = Env.perc(atk, rel).kr(doneAction:Done.freeSelf);
    signal = carr * amp * env;
    Out.ar(out, Pan2.ar(signal, pan))
}).add
)

// harmonic
Synth(\fm, [\freq, 52.midicps, \cRatio, 2]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 3]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 4]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 5]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 6]);

// INharmonic
Synth(\fm, [\freq, 52.midicps, \cRatio, 2.2]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 3.7]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 4.1]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 5.9]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 6.5]);


// Increase spacing between side-bands to get different combinations of the overtones
Synth(\fm, [\freq, 52.midicps, \cRatio, 1, \mRatio, 1]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 1, \mRatio, 2]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 1, \mRatio, 12]);
// Non-integer values produce inharmonic spectra
Synth(\fm, [\freq, 52.midicps, \cRatio, 1, \mRatio, 4.2]);
Synth(\fm, [\freq, 52.midicps, \cRatio, 1, \mRatio, 12.8]);



// Index of modulation
(
SynthDef(\fm1, {
    arg out=0, pan=0, freq=500, mRatio=1, cRatio=1, index=1, iScale=5, amp=0.2, atk=0.01, rel=3.0, cAtk=4, cRel=(-4);
    var carr, mod, env, signal, iEnv;
    iEnv = EnvGen.kr(
        Env.new(
            [index, index * iScale, index],
            [atk, rel],
            [cAtk, cRel]
        )
    );
    env = Env.perc(atk, rel, curve:[cAtk, cRel]).kr(doneAction:Done.freeSelf);
    mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * iEnv);
    carr = SinOsc.ar(freq * cRatio + mod);
    signal = carr * amp * env;
    Out.ar(out, Pan2.ar(signal, pan))
}).add
)

// pure sinewave
Synth(\fm1, [\freq, 56.midicps, \index, 0]);

// more sidebands
Synth(\fm1, [\freq, 36.midicps]);
Synth(\fm1, [\freq, 36.midicps, \index, 2]);
Synth(\fm1, [\freq, 42.midicps, \rel, 1]);
Synth(\fm1, [\freq, 36.midicps, \index, 8]);
Synth(\fm1, [\freq, 32.midicps, \rel, 5]);

// slap bass
Synth(\fm1, [\freq, 36.midicps, \rel, 1, \iScale, 10, \cRel, -16]);

// rich 90s sci-fi synth
Synth(\fm1, [\freq, 36.midicps, \rel, 4, \index, 20, \iScale, 0.2]);
Synth(\fm1, [\freq, 42.midicps, \rel, 4, \index, 20, \iScale, 0.2, \mRatio, 5]);
Synth(\fm1, [\freq, 39.midicps, \rel, 4, \index, 20, \iScale, 0.2, \mRatio, 0.5]);


// Phase modulation (almost similar)
{ SinOsc.ar(500 + SinOsc.ar(4, mul:4 * 10)) * 0.2 ! 2 }.play;
{ SinOsc.ar(500, SinOsc.ar(4, mul:10)) * 0.2 ! 2 }.play;
{ PMOsc.ar(500, 4, 10) * 0.2 ! 2 }.play // there is a UGen for that (less code)

// Warning: phase values should be within the range +-8pi (see SinOsc help)
{ PMOsc.ar(500, 4, 12pi) * 0.2 ! 2 }.play
// compare to (how it _should_ sound in trems of classical FM):
{ SinOsc.ar(500 + SinOsc.ar(4, mul:4 * 12pi)) * 0.2 ! 2 }.play;


// DIY approach - return to our own implementation, add a second modulator
(
SynthDef(\fm2, {
    arg out=0, pan=0, freq=500, mRatio=1, cRatio=1, index=1, iScale=5, amp=0.2, atk=0.01, rel=3.0, cAtk=4, cRel=(-4);
    var carr, mod, env, signal, iEnv, mod2;
    iEnv = EnvGen.kr(
        Env.new(
            [index, index * iScale, index],
            [atk, rel],
            [cAtk, cRel]
        )
    );
    env = Env.perc(atk, rel, curve:[cAtk, cRel]).kr(doneAction:Done.freeSelf);
    mod2 = SinOsc.ar(freq/10, mul:freq/10 * iEnv);
    mod = SinOsc.ar(freq * mRatio + mod2, mul:freq * mRatio * iEnv);
    carr = SinOsc.ar(freq * cRatio + mod);
    signal = carr * amp * env;
    Out.ar(out, Pan2.ar(signal, pan))
}).add
)

Synth(\fm2, [\freq, 72.midicps, \rel, 3, \iScale, 0.2, \mRatio, 0.5]);

// compare:
Synth(\fm1, [\freq, 56.midicps, \rel, 4, \index, 20, \iScale, 0.2, \mRatio, 0.5]);
Synth(\fm2, [\freq, 56.midicps, \rel, 4, \index, 20, \iScale, 0.2, \mRatio, 0.5]);

