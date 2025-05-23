// Source: https://www.youtube.com/watch?v=8EK9sq_9gFI

s.boot;
s.scope;
FreqScope.new;

b = Buffer.alloc(s, 2048);

(
~amps = [1] ++ ({[0, exprand(0.05, 0.5)].choose} ! 31);
~sig = Signal.sineFill(
    1024,
    ~amps,
    0!32
);
~wt = ~sig.asWavetable;
b.loadCollection(~wt);
)

~sig.plot

(
b.sine3(
    ({exprand(0.75, 40)} ! 16).sort,
    ({exprand(0.05, 0.9)} ! 16).sort.reverse,
    {rrand(0, 2pi)} ! 16,
    asWavetable:true
);
)

{Osc.ar(b, MouseX.kr(10, 10000, 1) * [1, 2.01], mul: 0.2 ! 2)}.play


// Using Env in wavetable synthesis
(
var env, sig, wt;
env = Env(
    [0, 0.6, -0.9, 0.3, 0],
    [4, 3, 2, 1],
    {rrand(-20, 20)} ! 4
);
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
)


// radomize everything:
(
var env, sig, wt, numSegs, levels;
numSegs = rrand(4, 20);

// This is to avoid a situation when all levels are above 0, thus
// introducing a DC offset (which is not healthy for speakers!)
levels = (
    ({rrand(0.0, 1.0)} ! (numSegs+1)) * [1, -1]
).scramble;
env = Env(
    {rrand(-1.0, 1.0)} ! (numSegs+1),
    {exprand(1, 20)} ! numSegs,
    {rrand(-20, 20)} ! numSegs
);
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
sig.plot;
)


{Osc.ar(b, MouseX.kr(10, 10000, 1)*[1, 2.01], mul: 0.2 ! 2)}.play

// Use of waveFill
(
var sig, wt;
sig = Signal.newClear(1024);
sig.waveFill({
    arg x, old, i;
    var out;
    out = sin(x.pow(1.5));
    out = out * 1.5;
    out = out.fold(-1, 1);
    out = out.cubed;
}, 0, 2pi);
wt = sig.asWavetable;
b.loadCollection(wt);
// sig.plot
)

b.plot

{Osc.ar(b, MouseX.kr(10, 10000, 1)*[1, 2.01], mul: 0.2 ! 2)}.play
