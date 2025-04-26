(
SynthDef.new(\sineTest, {
    arg freqNoise=8;
    var freq, amp, sig;
    freq = LFNoise0.kr(freqNoise).exprange(200, 1000);
    amp = LFNoise1.kr(12).exprange(0.02, 1);
    sig = SinOsc.ar(freq) * amp;
    Out.ar(0, sig);
}).add
)

x = Synth(\sineTest, [\freqNoise, 12]);
x.set(\freqNoise, 5);
x.free;


(
SynthDef.new(\pulseTest, {
    arg freqAmp=4, fundamental=40, maxPartial=4, width=0.5;
    var amp1, amp2, freq1, freq2, sig1, sig2;

    amp1 = LFPulse.kr(freqAmp, 0, 0.12) * 0.75;
    amp2 = LFPulse.kr(freqAmp, 0.5, 0.12) * 0.75;
    freq1 = LFNoise0.kr(4).exprange(fundamental, fundamental*maxPartial).round(fundamental);
    freq2 = LFNoise0.kr(4).exprange(fundamental, fundamental*maxPartial).round(fundamental);
    freq1 = freq1 * LFPulse.kr(8, add:1);
    freq2 = freq2 * LFPulse.kr(6, add:1);
    sig1 = Pulse.ar(freq1, width, amp1);
    sig2 = Pulse.ar(freq2, width, amp2);
    sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
    sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);

    Out.ar(0, sig1);
    Out.ar(1, sig2);
}).add;
)

{ LFNoise0.kr(4).exprange(40, 40*4).round(40) }.plot(1)

x = Synth(\pulseTest);
x.set(\width, 0.15);
x.set(\fundamental, 44);
x.set(\maxPartial, 10);
x.set(\freqAmp, 3);
x.free;

x = Synth(\pulseTest, [\freqAmp, 3.3, \fundamental, 48, \maxPartial, 8, \width, 0.15]);
x.free;