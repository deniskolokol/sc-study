(
SynthDef.new(\saw, {
	arg freq = 200, offset=2, lpf=1500, amp=0.2, out=0;
	var sig = Saw.ar(freq + [0, offset]);
	var env = XLine.ar(1.01, 0.01, 2, doneAction: 2) - 0.01; // cheating: XLine cannot go to 0,
														  // so even if amp=0.01 is perceptualy silence,
														  // this will take it to a real zero.
	sig = LPF.ar(sig, lpf);
	sig = sig * amp;
	sig = sig * env;

	Out.ar(out, sig)
}).add;
)

// gated envelope
(
SynthDef.new(\saw, {
	arg freq = 200, offset=2, lpf=1500, amp=0.2, gate=1, out=0;
	var sig = Saw.ar(freq + [0, offset]);
	var env = EnvGen.ar(
		Env.new(
			levels: [0, 1, 0.5, 0],
			times: [1, 1, 1],
			curve: [1, -2, -3],
			releaseNode: 2
		),
		gate: gate,
		doneAction: 2);
	sig = LPF.ar(sig, lpf);
	sig = sig * amp;
	sig = sig * env;

	Out.ar(out, sig)
}).add;
)

x = Synth.new(\saw, [\freq, 70, \lpf, 3000]);
x.set(\gate, 0);


// ----------------------

// ITERATIONS

(
x = [45, 55, 59, 61, 62, 64].collect({ |n, i|
	Synth.new(\saw, [\freq, n.midicps, \lpf, 3000, \amp, 0.15]);
})
)

x.do { |i| i.set(\gate, 0)}