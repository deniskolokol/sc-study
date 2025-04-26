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
}).add;

SynthDef(\bpfbuf, {
    arg atk=0, sus=0, rel=3, c1=1, c2=(-1), buf=0, rate=1, spos=0, freq=440,
    rq=1, bpmix=0, pan=0, amp=1, out=0;
    var sig, env;
    env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction:2);
    sig = PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf), startPos:spos);
    sig = XFade2.ar( // smoothly balance between the unfiltered and the band-passed signal
        sig,
        BPF.ar(
            sig,
            freq,
            rq,
            mul:1/rq.sqrt // inverse relationship between `reciprocal quality` (Q) and amplitude -
                          // this provides a boost in amp to compensate the loss in amp that results
                          // in narrow filter band.
        ),
        bpmix*2-1 // in the param we use the range (0..1), this need to convert in the expected range (-1..1)
    );
    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
    arg in, out=0, predelay=0.1, revtime=1.8, lpf=4500, amp=1, mix=0.15;
    var dry, wet, temp, sig;
    dry = In.ar(in, 2);
    temp = In.ar(in, 2);
    wet = 0; // or `DC.ar(0)!2` or `Silent.ar(2)`
    temp = DelayN.ar(temp, 0, 2, predelay);
    16.do {
        temp = AllpassN(temp, 0.05, {Rand(0.001, 0.05)}!2, revtime);
        temp = LPF(temp, lpf);
        wet = wet + temp
    };
    sig = XFade2.ar(dry, wet, mix*2-1, amp);
    Out.ar(out, sig);
}).add;
)

~reverbBus = Bus.audio(s, 2);
~reverbSynth = Synth(\reverb, [\in, ~reverbBus]);


(
b = Dictionary.new;
PathName("~/Music/material/Drum samples/513TubeDrumHits_Wav_SP/Samples").entries.do {
    arg subfolder;
    b.add(
        subfolder.folderName.asSymbol -> Array.fill(
            subfolder.entries.size,
            { |i| Buffer.read(s, subfolder.entries[i].fullPath) };
        )
    )
}
)


(
rrand(4, 10).do {
    Synth(
        \bpfbuf, [
            \buf, b['Hats & Shakers'].choose,
            \atk, exprand(2, 3),
            \sus, 1,
            \rel, 2,
            \bpfmix, 1,
            \freq, (Scale.lydian.degrees + 69).choose.midicps * [1, 2].choose,
            \rq, exprand(0.001, 0.008),
            \rate, exprand(0.6, 1.2),
            \pan, rrand(-0.5, 0.5)
        ]
    )
}
)

(
Synth(
    \bpfbuf, [
        \buf, b['Hats & Shakers'].choose,
        \rel, rrand(0.15, 0.25),
        \rate, rrand(-2.0, 2.0).midiratio,
        \out, ~reverbBus
    ]
)
)