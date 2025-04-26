(
SynthDef("bass", {
    arg out=0, rate=1, amp=1.0, pan=0, freq=432,
	gate=1, atk=0.01, decay=0.1, sustain=1, rel=0.5, ca=3, cr= -3,
	momentum=0.3, trigID=80;

	var env = EnvGen.kr(Env.new([0, sustain, 0], [atk, rel], [ca, cr]), doneAction: 2);
	var signal = Pulse.ar(
		freq,
		width: PinkNoise.kr((ExpRand(0.009, momentum*0.9)*amp).min(0.45), 0.45),
		mul: FSinOsc.ar(LinRand(9, 99*freq).round(9), 0, LinRand(0.09, 0.999-momentum), amp)
	);
	signal = RLPF.ar(signal,
		freq: (freq*9*momentum).max(freq*4.5),
		rq: LinRand(0.09, 4.5)
	).softclip;
	signal = Pan2.ar(signal * env, pan);

    Out.ar(out, signal)
}).add;
)

(
Pdef(
	\basspat,
	Pbind(
		\instrument, \bass,
		\dur, Pseq([1/16, 1/8, 1/4, \], inf),
		\midinote, Pseq([24], inf).trace,
		\harmonic, Pexprand(1, 80, inf).round,
		\atk, Pwhite(0.1, 1.0, inf),
		\rel, Pwhite(5.0, 10.0, inf),
		\amp, Pkey(\harmonic).reciprocal * 0.3,
		\pan, Pwhite(-0.9, 0.8, inf)
	)
).play
)

s.plotTree
