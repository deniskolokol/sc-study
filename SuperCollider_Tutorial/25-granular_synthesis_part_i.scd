// Lesson:
// https://www.youtube.com/watch?v=WBqAM_94TW4&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=26


s.boot;

(
s.meter;
s.plotTree;
s.scope;
FreqScope.new;
)

b = Buffer.readChannel(s, PathName("~/Music/MOON2/samples/voices/Marcin_&_Agata_reading_Lem/14_marcin.wav").fullPath, channels:[0]);
b.play;

// Drone with grains
(
{
    var sig;
    sig = GrainBuf.ar(
        numChannels: 1,
        trigger: Impulse.ar({ExpRand(60, 60.5)} ! 12),
        dur: LFNoise1.kr(0.3 ! 12).exprange(0.0002, 0.1),
        sndbuf: b,
        rate: 1,
        pos: 0.12,
        interp: 2,
        pan: 0,
        envbufnum: -1,
        maxGrains: 512 // this is a fixed value, cannot be modulated at runtime!
    );
    sig = Splay.ar(sig);
}.play
)

Signal.hanningWindow(1024).plot


// Gibberish
(
{
    var sig;
    sig = GrainBuf.ar(
        numChannels: 1,
        trigger: Impulse.ar(20 ! 2),
        dur: 0.09,
        sndbuf: b,
        rate: 1,
        pos: LFNoise1.ar(10).range(0, 1),
        interp: 2,
        pan: 0,
        envbufnum: -1,
        maxGrains: 512 // this is a fixed value, cannot be modulated at runtime!
    );
    sig = Splay.ar(sig);
}.play
)


// Grain pointers "sliding" through a file
(
{
    var sig;
    sig = GrainBuf.ar(
        numChannels: 1,
        trigger: Impulse.ar(10),
        dur: 0.09,
        sndbuf: b,
        rate: 1,
        pos: LFNoise1.ar(0.1).range(0, 1),
        interp: 2,
        pan: 0,
        envbufnum: -1,
        maxGrains: 512
    );
    sig = Splay.ar(sig);
}.play
)


// if dur is twice the reciprocal of the trigger rate, the result is indistinguishable from PlayBuf
(
{
    var sig;
    sig = GrainBuf.ar(
        numChannels: 1,
        trigger: Impulse.ar(40),
        dur: 1/20,
        sndbuf: b,
        rate: 1,
        pos: Line.ar(0, 1, BufDur.ir(b), doneAction:2),
        interp: 2,
        pan: 0,
        envbufnum: -1,
        maxGrains: 512
    );
    sig = Splay.ar(sig);
}.play
)

// wiggly backwards speech
(
{
    var sig;
    sig = GrainBuf.ar(
        numChannels: 1,
        trigger: Impulse.ar(40),
        dur: 1/20,
        sndbuf: b,
        rate: 1,
        pos: (
            Line.ar(BufSamples.ir(b)-1, 0, BufDur.ir(b) * 4, doneAction:2)
            + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
        ) / BufSamples.ir(b),
        interp: 2,
        pan: 0,
        envbufnum: -1,
        maxGrains: 512
    );
    sig = Splay.ar(sig);
}.play
)


// "Funci Porcini" effect
(
{
    var sig;
    sig = GrainBuf.ar(
        numChannels: 1,
        trigger: Impulse.ar(40),
        dur: 1/20,
        sndbuf: b,
        rate: 1,
        pos: (
            Sweep.ar(Impulse.ar(1/BufDur.ir(b)), 0.2 * BufRateScale.ir(b))
            * SampleRate.ir
            + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
        ) / BufSamples.ir(b),
        interp: 2,
        pan: 0,
        envbufnum: -1,
        maxGrains: 512
    );
    sig = Splay.ar(sig);
}.play
)


// pitch shifting without changing the duration
(
{
    var sig;
    sig = GrainBuf.ar(
        numChannels: 1,
        trigger: Dust.ar(100),
        dur: 1/20,
        sndbuf: b,
        rate: MouseX.kr(0.5, 2, 1),
        pos: (
            Phasor.ar(0, MouseY.kr(0.1, 2, 1) * BufRateScale.ir(b), 0, BufFrames.kr(b))
            + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
        ) / BufSamples.ir(b),
        interp: 2,
        pan: 0,
        envbufnum: -1,
        maxGrains: 512
    );
    sig = Splay.ar(sig);
}.play
)

b.free;