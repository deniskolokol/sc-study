(
~wt0 = Signal.sineFill(
    1024,
    1/(1..8),
    0!8
).asWavetable;

~wt1 = Signal.sineFill(
    1024,
    [1, 0, 1/2, 1, 1/4],
    [0, 0, pi, 0, pi]
).asWavetable;
)

~wt0.plot; ~wt1.plot;

(
// VOsc requires consecutive (adjacent) wavetable buffers of the same size!
// (see VOsc help)
~wt = Array.fill(4, {
    var numSegs = rrand(4, 20);
    Env(
        [0] ++ (({rrand(0.0, 1.0)} ! (numSegs+1)) * [1, -1]).scramble ++ [0],
        {exprand(1, 20)} ! numSegs,
        {rrand(-20, 20)} ! numSegs
    ).asSignal(1024).asWavetable;
})
)

~buf = Buffer.allocConsecutive(4, s, 2048);
~buf.do { |buf, i| buf.loadCollection(~wt[i])};
~wt.do { |n, i| n.plot(~buf[i].bufnum.asString)};

(
SynthDef(\vosc, {
    arg out=0, buf=0, numBufs=2, freq=440, amp=0.2;
    var sig, bufpos, detuneSig;
    detuneSig = LFNoise1.kr(0.2 ! 8).bipolar(0.2).midiratio;
    bufpos = buf + LFNoise1.kr(0.5).range(0, numBufs-1);
    sig = VOsc.ar(bufpos, freq * detuneSig);
    sig = Splay.ar(sig);
    sig = LeakDC.ar(sig) * amp;
    Out.ar(out, sig);
}).add;
)

Synth(\vosc, [\freq, 52.midicps, \buf, ~b0.bufnum, \numBufs, 4]);


// Waveshaping

// SinOsc to more quadratic shape
(
// transfer function:
~tf = Env([-0.8, 0, 0.8], [1, 1], [8, -8]);
// with Shaper - use length as pow(2) + 1
~tf = ~tf.asSignal(length:1025);
// ... and .asWavetableNoWrap (insted of .asWavetable, as in case of Osc and VOsc)
~tf = ~tf.asWavetableNoWrap;
~tfBuf = Buffer.loadCollection(s, ~tf)
)

a = {Shaper.ar(~tfBuf, SinOsc.ar(440)) * 0.2 ! 2}.play
a.free


(
// transfer function:
~tf = Env([-1, 1], [1], [0]).asSignal(1025); // identity function
// add a function of the same size:
// - skip the first 3 partials
// - randomly peak 3 from partials 4-9
// - randomize the phases
// - scale to 1/4
~tf = ~tf + (
    Signal.sineFill(
        1025,
        (0 ! 3) ++ [0, 0, 0, 1, 1, 1].scramble,
        {rrand(0, 2pi)} ! 9
    )
);
~tf = ~tf.normalize;
~tfBuf = Buffer.loadCollection(s, ~tf.asWavetableNoWrap)
)

(
{
    var sig, input;
    input = LFSaw.ar({120 * Rand(-0.1, 0.1).midiratio} ! 8);
    input = input * LFNoise1.kr(0.5 ! 8).range(0.1, 1);
    sig = Shaper.ar(~tfBuf, input);
    sig = Splay.ar(sig) * 0.3
}.play
)


//
(
~tf = Signal.newClear(1025).waveFill({
    arg x, old, i;
    sin(x)
}, -pi/2, pi/2);
~tf = ~tf.waveFill({
    arg x, old, i;
    old * ((cos(x*0.08) / 4) + 0.3);
}, 0, 50pi).normalize;
~tf.plot;
~tfBuf.loadCollection(~tf.asWavetableNoWrap);
)

{LFTri.ar(250).lincurve(-1, 1, -1, 1, -3)}.plot(0.01);

(
{
    var sig, input;
    // input = LFSaw.ar(250); // with this - noticable aliasing (because LFSaw is jump from hi to low is abrupt)
    input = LFTri.ar(250).lincurve(-1, 1, -1, 1, -3); // no discontinuity
    sig = Shaper.ar(~tfBuf, input);
    sig = sig * 0.3 ! 2;
}.play
)

// using UGen to control the curvature, add multichannel expansion, remove LeakDC
(
{
    var sig, input, curve;
    curve = LFNoise1.kr(0.5).bipolar(4);
    input = LFTri.ar({120 * Rand(-0.1, 0.1).midiratio}!8);
    input = input.lincurve(-1, 1, -1, 1, curve:curve);
    sig = Shaper.ar(~tfBuf, input);
    sig = Splay.ar(sig) * 0.3;
    sig = LeakDC.ar(sig);
}.play
)


// as a SynthDef
(
SynthDef.new(\shaper, {
    arg buf=0, freq=250, amp=0.2, out=0,
    atk=1, sus=0, rel=5, curvemax=1;
    var sig, input, curve, env;
    env = EnvGen.kr(Env.linen(atk, sus, rel, 1, [1, 0, -1]), doneAction: 2);
    curve = LFNoise1.kr(0.5 ! 8).bipolar(curvemax);
    input = LFTri.ar({freq * Rand(-0.1, 0.1).midiratio}!8);
    input = input.lincurve(-1, 1, -1, 1, curve);
    sig = Shaper.ar(buf, input);
    sig = Splay.ar(sig) * amp * env;
    sig = LeakDC.ar(sig);
    Out.ar(out, sig);
}).add
)

(
// amplitude depends on frequency - higher pitches a little quieter
({rrand(40, 90)} ! 4).do ({
    arg n;
    Synth(\shaper, [
        \buf, ~tfBuf.bufnum,
        \freq, n.nearestInScale([0, 7, 9, 10]).postln.midicps,
        \amp, n.lincurve(40, 90, 0.3, 0.1, -2),
        \curvemax, 0
    ])
});
)





















