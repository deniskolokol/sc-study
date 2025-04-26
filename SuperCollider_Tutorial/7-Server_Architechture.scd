s.boot;
s.plotTree;
s.meter;

s.options.numAudioBusChannels;
s.options.numInputBusChannels;
s.options.numOutputBusChannels;

(
SynthDef(\blip, {
    arg out;
    var freq, trig, sig;
    freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
    sig = SinOsc.ar(freq, mul:0.25);
    trig = Dust.kr(2);
    sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
    Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
    arg in, out=0;
    var sig;
    sig = In.ar(in, 1);
    sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2) ! 2;
    Out.ar(out, sig);
}).add
)

x = Synth(\reverb, [\in, 6]);
y = Synth(\blip, [\out, 6]);
y.set(\out, 8);
x.set(\out, 0, \in, 8);
y.free

~reverbBus = Bus.audio(s, 1);
~reverbBus.index;

y = Synth(\reverb, [\in, ~reverbBus]);
x = Synth(\blip, [\out, ~reverbBus]);
x.free;


// Multichannel example
(
SynthDef(\blip, {
    arg out=0;
    var freq, trig, sig;
    freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
    sig = SinOsc.ar(freq, mul:0.25);
    trig = Dust.kr(2);
    sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
    sig = Pan2.ar(sig, LFNoise1.kr(10));
    Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
    arg in, out=0;
    var sig;
    sig = In.ar(in, 2);
    sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
    Out.ar(out, sig);
}).add
)

~reverbBus2 = Bus.audio(s, 2);
~reverbBus2.index;

y = Synth(\reverb, [\in, ~reverbBus2]);
x = Synth(\blip, [\out, ~reverbBus2]);
s.freeAll;

//Groups and Nodes.

// correct order in specified Group
g = Group.new;
y = Synth(\blip, [\out, ~reverbBus2], g, \addToHead);
x = Synth(\reverb, [\in, ~reverbBus2], g, \addToTail);
g.free;

// correct order in the default Group
y = Synth(\blip, [\out, ~reverbBus2]);
x = Synth(\reverb, [\in, ~reverbBus2], y, \addAfter);

y.free;
// since the reverb is still on the server, it's enough to
// re-instantiate sound source placing it before the reverb
x = Synth.before(x, \blip, [\out, ~reverbBus2]);


// separate groups for sources and effects (should be in the correct
// order, which makes synth order irrelevant as long as each of them
// is in a correct group)
~groupSource = Group.new;
~groupFX = Group.after(~groupSource);
y = Synth(\reverb, [\in, ~reverbBus2], ~groupFX);
x = Synth(\blip, [\out, ~reverbBus2], ~groupSource);


// Multiple synthns control within a Group
(
SynthDef(\blip, {
    arg out=0, fund=300, dens=2, decay=0.2;
    var freq, trig, sig;
    freq = LFNoise0.kr(3).exprange(fund, fund*4).round(fund);
    sig = SinOsc.ar(freq, mul:0.25);
    trig = Dust.kr(dens);
    sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
    sig = Pan2.ar(sig, LFNoise1.kr(10));
    Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
    arg in, out=0;
    var sig;
    sig = In.ar(in, 2);
    sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
    Out.ar(out, sig);
}).add
)

~groupSource = Group.new;
~groupFX = Group.after(~groupSource);
y = Synth(\reverb, [\in, ~reverbBus2], ~groupFX);
(
8.do {
    Synth(\blip,
        [\out, ~reverbBus2, \fund, exprand(60, 300).round(30)],
        ~groupSource
    )
};
)

~groupSource.set(\decay, 0.005, \dens, 15);
~groupSource.freeAll;