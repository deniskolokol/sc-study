// https://www.youtube.com/watch?v=WrhL85eXXMU
s.boot;

(
SynthDef(\tone, {
	var sig, env;
	env = Env.adsr(
		\atk.ir(0.001), \dec.ir(0.2), \slev.ir(0.4), \rel.ir(0.3)
	).ar(Done.freeSelf, \gate.kr(1));
	sig = LFTri.ar(\freq.kr(880));
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.3));
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add
)

// Check
x = Synth(\tone);
x.set(\gate, 0)


// (1) Tempo / Quantization

t = TempoClock.new(115/60).permanent_(true).schedAbs(0, { t.beatsPerBar_(3) });
t.beats;
t.nextBar;

t.schedAbs(t.nextBar, { t.beatsPerBar_(4) });
t.nextBar;


(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\degree, Pseq([5, 7, 8, 9], inf)
);

x = p.play(t, quant: Quant(4));
)
x.stop;

t.schedAbs(t.nextBar, { t.tempo_(80/60) })

(
q = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\degree, Pseq([0, 1, 3s, 4], inf)
);

y = q.play(t); // not synchronized
)
y = q.play(t, quant: c); // one beat earlier
y = q.play(t, quant: Quant(4, -0.25)); // one quarter of a beat earlier
y = q.play(t, quant: [4, 0.25]); // the same as above, but one quarter of a beat late
y = q.play(t, quant: 4); // only granularity provided, no offset (i.e., starts simultaneusly with the next beat)
y.stop;


// change tempo gradually over N beats
(
~tempoChange = {
	arg clock, newTempo, numBeats;
	var i=0;
	var tempoArray = Array.interpolation(numBeats, clock.tempo, newTempo/60);
	clock.schedAbs(clock.nextBar, {
		clock.tempo_(tempoArray[i]);
		i = i + 1;
		// returning 1 means to re-schedule, returning a Symbol means "do nothing" (i.e. stop)
		if (i < numBeats) {1} {\done.postln};
	});
};
)

//smooth change to a new tempo (125bpm) over 12 bars
~tempoChange.(t, 125, 12);

(
~post = {
	t.beats.postln;
	1; // returning 1 means to re-schedule
};
t.schedAbs(t.nextBar, { ~post.() });
)
// Stop re-scheduling.
~post = { };

t.stop;

// (2) \sustain and \legato

// default sustain (played in a mini-Event):
(instrument: \tone).play;

// compiled strings
Event.partialEvents.durEvent[\sustain].postcs;
Event.partialEvents.pitchEvent[\freq].postcs;
Event.partialEvents.ampEvent[\amp].postcs;

(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\degree, Pseq([5, 7, 8, 9], inf),
	\legato, 1
);

x = p.play(t, quant: Quant(4));
)
x.stop;


// (3) Pfunc and other function based patterns

~deg = 5;
(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\sustain, 0.1,
	\amp, Pseq([0.5] ++ (0.1 ! 7), inf),
	\degree, Pfunc({ ~deg }),
);

x = p.play(t, quant: 4);
)

// WARNING: the function shouldn't return a number, otherwise it'll
// automatically re-schedule the change that many beats later -> use nil.

t.schedAbs(t.nextBar, { ~deg = 8; nil; })
x.stop;


// Posting the event's details
(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\sustain, 0.1,
	\amp, Pexprand(0.03, 0.6, inf),
	\degree, Pfunc({ |ev|
		var degrees=[5, 7, 8, 9, 10s, 11, 12];
		var index;
		// Warning: \amp should be defined earlier - in this case order matters!
		index = ev[\amp].explin(0.03, 0.6, 6, 0).round;
		degrees[index]
	}),
);

x = p.play(t, quant: 4);
)

// Locking parameters
(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\sustain, 0.1,
	#[amp, degree], Pfunc({
		#[ [0.75, 5], [0.25, 9], [0.08, 12] ].choose;
	}).trace;
);

x = p.play(t, quant: 4);
)

x.stop;


// Prout
// Locking parameters
(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\sustain, 0.1,
	\degree, Prout({
		inf.do {
			5.yield;
			if (0.5.coin) {[12, 12s, 13].do { |n| n.yield }}
		}
	})
);

x = p.play(t, quant: 4);
)

// Syntactic sugar
(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\sustain, 0.1,
	\degree, p{ loop({
		5.yield;
		if (0.5.coin) {
			7.yield;
			if (0.4.coin) { [12, 12s, 13].do { |n| n.yield; }}
		}
	})
	}
);

x = p.play(t, quant: 4);
)


// Plazy - the same as Pfunc except its function should return a pattern instead of a value

[-2, 0, 1, 2, 3s, 4, 5, 7].keep(rrand(2, 8));

(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\sustain, 0.1,
	\degree, Pn(Plazy({
		Pseq([-2, 0, 1, 2, 3s, 4, 5, 7].keep(rrand(2, 8)), 1)
	}), inf)
);

x = p.play(t, quant: 4);
)

x.stop
x.resume
x.reset
x.isPlaying


// (4) Constraint patterns

// Pfin & Pfindur
(
p = Pwhite(0, 9, inf);
x = Pfin(5, p).asStream;
)
x.next;


(
p = Pbind(
	\instrument, \tone,
	\dur, 0.25,
	\sustain, 0.1,
	\degree, Pn(Plazy({
		Pseq([-2, 0, 1, 2, 3s, 4, 5, 7].keep(rrand(2, 8)), 1)
	}), inf)
);
)

// Pfin limits the number of events.
x = Pfin(16, p).play(t, quant: 4);

// Pfindur limits he number of time signatures (durations):
// hear 8 notes (two bars * 4th)
x = Pfindur(2, p).play(t, quant: 4);


// Pfindur makes sense only with musical times (rand values will be blurred)
(
p = Pbind(
	\instrument, \tone,
	\dur, Pexprand(0.1, 0.5),
	\atk, 0.2,
	\rel, 2,
	\sustain, 0.1,
	\degree, Pn(Plazy({
		Pseq([-2, 0, 1, 2, 3s, 4, 5, 7].keep(rrand(2, 8)), 1)
	}), inf)
);

x = Pfindur(4, p).play(t, quant: 4);

// metronome
Pfin(4, Pbind(\instrument, \tone, \dur, 1, \freq, 1000, \slev, 0)).play(t, quant: 4);
)


// (5) Modular pattern composition
// Pbindf - blend keys from one pattern with another pattern

(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\degree, Pseq([5, 7, 8, 9], inf)
);
q = Pbindf(p, \degree, Pseq([0, 1, 3s, 4], inf));

// shorter triplet notes one octave higher
r = Pbindf(q, \dur, 1/3, \slev, 0, \mtranspose, 7);

Pfindur(8, Ppar([p, q, r])).play(t)
);

// Pchain - blend whole patterns together
// see "Pattern Guide 06c: Composition of Patterns" for more detailed explanation.
(
p = Pbind(\a, 3, \b, 5);
q = Pbind(\b, 6, \c, 8);
r = Pbind(\a, 16, \d, 5s);
)
x = Pchain(q, p).asStream; // `q` is dominant for `p`
x.next(()); // manually extracting events from the chain we need a starting event - ()

// Symbolic shortcut:
x = (q <> p).asStream;

// more than 2 patterns:
x = (r <> p <> q).asStream;
x.next(())

// Sound example
(
~short = Pbind(\atk, 0.001, \dec, 0.08, \slev, 0, \rel, 0, \sustain, 0.2);
~long = Pbind(\atk, 2, \dec, 0, \slev, 1, \rel, 3, \sustain, Pwhite(2.0, 9.0));
~tone = Pbind(\instrument, \tone);
p = Pbind(
	\degree, Pwhite(-7, 7),
	\dur, Pexprand(0.2, 1)
);
)

// Short notes
x = (~short <> ~tone <> p).play(t);
// Long notes
x = (~long <> ~tone <> p).play(t);

x.stop;

// (6) Sharing data across several Pbinds

// See "Pattern Guide 06g: Data Sharing"

(
~data = Pbind(
	\type, \rest,
	\dur, 8,
	#[scale, ctranspose], Prand([
		[Scale.majorPentatonic, 0], // all white keys on the piano
		[Scale.minorPentatonic, 3], // all black keys
	], inf)
).collect({ |ev| ~ev = ev});

~chd = Pbind(
	\instrument, \tone,
	#[scale, ctranspose], Pfunc({
		[~ev[\scale], ~ev[\ctranspose]]
	}),
	\dur, 8,
	\atk, 1,
	\dec, 0,
	\slev, 1,
	\rel, 2,
	\degree, (0..4),
	\db, -30
);

~mel = Pbind(
	\instrument, \tone,
	#[scale, ctranspose], Pfunc({
		[~ev[\scale], ~ev[\ctranspose]]
	}),
	\dur, Pexprand(0.5, 3).round(0.5),
	\atk, 0.005,
	\dec, 0.2,
	\slev, 0,
	\rel, 0,
	\degree, Pbrown(0, 10, 3),
	\db, -15,
)
)

(
~dataPlayer = ~data.play(t, quant: [8, 0, 0.05]);
~musicPlayer = Ppar([~chd, Pn(Pfindur(8, ~mel), inf)]).play(t, quant: 8);
)

~musicPlayer.stop;
~dataPlayer.stop;
