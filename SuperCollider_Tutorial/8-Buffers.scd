~samplePath = PathName("~/Music/material/generated/mel_discrete_breath0.wav").fullPath;
~b0 = Buffer.read(s, ~samplePath);

// confirm it's been loaded
~b0.play;

// clear but not remove the buffer from the server
~b0.zero;

// re-fill the (already allocated) buffer
~b0.read(~samplePath)

// remove entirely
~b0.free;

// free all buffers
Buffer.freeAll;


// * * *

~b0 = Buffer.read(s, PathName("~/Music/material/samples/241262__lewis100011__sci-fi-engine.wav").absolutePath);
~b1 = Buffer.read(s, PathName("~/Music/material/samples/327666__juan_merie_venter__dog-bark.wav").absolutePath);
~b2 = Buffer.read(s, PathName("~/Music/material/samples/334149__svampen__rain-heavy-loopable.wav").absolutePath);
~b3 = Buffer.read(s, PathName("~/Music/material/samples/628033__monosfera__alien_monster_mara_stereo.wav").absolutePath);
~b4 = Buffer.read(s, PathName("~/Music/material/samples/712017__audiopapkin__thunder.wav").absolutePath);

~b0.play;
~b1.play;
~b2.play;
~b3.play;
~b4.play;

// FRAMES (length of the buffer):
~b0.numFrames;

// CHANNELS:
~b0.numChannels;

// SAMPLES:
// numSamples = numFrames * numChannels

// Load just one channel
~b5 = Buffer.readChannel(
    s,
    PathName("~/Music/material/samples/628033__monosfera__alien_monster_mara_stereo.wav").fullPath,
    channels:[1]
);
~b0.play;
~b5.play;

// LENGTH of a Buffer
~b5.duration;

// BUFFER NUMBERS (bufnums)
~b0.bufnum;

// BUFFER SAMPLE RATE
~b1.sampleRate;
// to avoid re-sampleing should be the same as Server sample rate.
s.sampleRate;

// Buffer attributes all at ones
~b5.query;

// Read part of the buffer (tail)
// head - first half second of the file
~b0_part0 = Buffer.read(s, PathName("~/Music/material/samples/241262__lewis100011__sci-fi-engine.wav").fullPath, 0, s.sampleRate/2);
~b0_part0.play

~b0.numFrames;
(
~frames = 100000;
~b0_part1 = Buffer.read(
    s,
    PathName("~/Music/material/samples/241262__lewis100011__sci-fi-engine.wav").fullPath,
    ~frames,
    ~b3.numFrames - ~frames - 1
);
)
~b0_part1.play;


// LOAD MANY SOUNDFILES AT ONES
~cymbals = Array.new;
~folder = PathName("~/Music/material/Drum samples/513TubeDrumHits_Wav_SP/Samples/Rides & Cymbals/");
(
~folder.entries.do { |path|
    ~cymbals = ~cymbals.add(Buffer.read(s, path.fullPath));
}
)
~cymbals.size
~cymbals.at(0).play;
~cymbals[1].play;
~cymbals[8].play;
~cymbals[13].play;
~cymbals[37].play;

// WARNING: there is a limit of  buffers to load:
s.options.numBuffers;


// UGen's & Buffers
(
SynthDef(\playbuf_test, {
    arg amp=1, out=0, buf, rate=1, t_trig=1, start=0, loop=0, da=2;
    var sig;
    sig = PlayBuf.ar(
        2,
        buf,
        BufRateScale.kr(buf) * rate,
        t_trig,
        start,
        loop,
        doneAction:da
    );
    sig = sig * amp;
    Out.ar(out, sig)
}).add
)

Synth(\playbuf_test, [\buf, ~b0.bufnum]);
Synth(\playbuf_test, [\buf, ~b1.bufnum, \rate, 2]); // twice as fast
Synth(\playbuf_test, [\buf, ~b2.bufnum]);
Synth(\playbuf_test, [\buf, ~b3.bufnum, \rate, 0.5]); // twice as slow

// This synth will not free itself
x = Synth(\playbuf_test, [\buf, ~b2.bufnum, \start, s.sampleRate/2, \da, 0]);
// We can jump to the start position:
x.set(\t_trig, 1);
// and we have to free it manually
x.free;

// If loop = 1, the Synth is ignoring doneAction:
x = Synth(\playbuf_test, [\buf, ~b4.bufnum, \loop, 1]);
// Stop looping (will play play until the end, though)
x.set(\loop, 0);


// Playing backwards:
// - \rate is negative
// - \start is the one before the last frame (it can't be the last one, because it
//   is PlayBuf's cue to check its doneAction, and if it's eq to 2, the Synth will
//   free itself immediately after instantiation)
x = Synth(\playbuf_test, [\buf, ~b1.bufnum, \rate, -1.5, \start, ~b1.numFrames-2]);
y = Synth(\playbuf_test, [\buf, ~b1.bufnum, \rate, 1.5]);


// If we work with a chromatic harmony of the samples, .midiratio is more useful than
// ration represented by mere integers:
12.midiratio; // (shift octave higher)
-12.midiratio; // (shift octave lower)
7.midiratio; // perfect fifth

// Transpose sounds by semitones:
Synth(\playbuf_test, [\buf, ~cymbals[5].bufnum]);
Synth(\playbuf_test, [\buf, ~cymbals[5].bufnum, \rate, -7.midiratio]);
Synth(\playbuf_test, [\buf, ~cymbals[5].bufnum, \rate, -10.midiratio]);
Synth(\playbuf_test, [\buf, ~cymbals[5].bufnum, \rate, -13.midiratio]);
Synth(\playbuf_test, [\buf, ~cymbals[5].bufnum, \rate, -15.midiratio]);
Synth(\playbuf_test, [\buf, ~cymbals[5].bufnum, \rate, 7.midiratio]);


g = Group.new;
(
x = Synth(\playbuf_test, [\buf, ~b1.bufnum, \rate, 1.5, \loop, 1, \amp, 0.5], g);
y = Synth(\playbuf_test, [\buf, ~b2.bufnum, \rate, 1.2, \loop, 1, \amp, 0.5], g);
z = Synth(\playbuf_test, [\buf, ~b4.bufnum, \rate, 0.7, \loop, 1, \amp, 0.5], g);
)
// Changing the rate of multiple synths at once:
g.set(\rate, 0.8);
// Change to the same buf
g.set(\buf, ~b0.bufnum);
// Still can manipulate synths individually
z.set(\rate, exprand(0.2, 2.0));
// Un-loop all synths
g.set(\loop, 0);
g.free;



// BufRd
(
SynthDef(\bufrd_test, {
    arg amp=1, out=0, buf, start, end;
    var sig, pointer;
    // read linearly from beginning to end or back (must be in audio rate, hence .ar)
    pointer = Line.ar(start, end, BufDur.kr(buf), doneAction:2);
    sig = BufRd.ar(2, buf, pointer);
    sig = sig * amp;
    Out.ar(out, sig);
}).add
)

// forward play
Synth(\bufrd_test, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1])

// backward play
Synth(\bufrd_test, [\buf, ~b4.bufnum, \start, ~b2.numFrames-1, \end, 0])


// Looper with BufRd
(
SynthDef(\bufrd_loop, {
    arg amp=1, out=0, buf, start, end, rate=1;
    var sig, pointer;
    // change pointer to Phasor - linear oscillator
    pointer = Phasor.ar(0, BufRateScale.kr(buf)*rate, start, end);
    sig = BufRd.ar(2, buf, pointer);
    sig = sig * amp;
    Out.ar(out, sig);
}).add
)

x = Synth(\bufrd_loop, [\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1]);
x.set(\start, ~b1.numFrames/3, \end, ~b1.numFrames - 1);
x.set(\rate, -3.midiratio);
x.free;

//Any Ugen can be use for playing buf
(
SynthDef(\bufrd_sine, {
    arg amp=1, out=0, buf, start, end, freq=1;
    var sig, pointer;
    // change pointer to Phasor - linear oscillator
    pointer = SinOsc.ar(freq, 3pi/2).range(start, end);
    sig = BufRd.ar(2, buf, pointer);
    sig = sig * amp;
    Out.ar(out, sig);
}).add
)

x = Synth(\bufrd_sine, [\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1, \freq, 0.8]);
x.free;

(
SynthDef(\bufrd_noise, {
    arg amp=1, out=0, buf, start, end, freq=1;
    var sig, pointer;
    // change pointer to Phasor - linear oscillator
    pointer = LFDNoise1.ar(freq).range(start, end);
    sig = BufRd.ar(2, buf, pointer);
    sig = sig * amp;
    Out.ar(out, sig);
}).add
)
