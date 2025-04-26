x = {SinOsc.ar([350, XLine.kr(350, 387, 3)]) * 0.125}.play
x.free

(
z = {
    arg freqNoise=8;
    var freq, amp, sig;
    freq = LFNoise0.kr(freqNoise).exprange(200, 1000);
    amp = LFNoise1.kr(12).exprange(0.02, 1);
    sig = SinOsc.ar(freq) * amp;
}.play
)

z.set(\freqNoise, 12);
z.set(\freqNoise, exprand(4, 64));
z.free;