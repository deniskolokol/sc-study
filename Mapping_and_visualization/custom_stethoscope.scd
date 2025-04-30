(
Server.default = s = Server.local;
s.waitForBoot {
    var waveScope, phaseScope;

    // allocate two audio buffers
    var bufferA = Buffer.alloc(s, 1024, 2);
    var bufferB = Buffer.alloc(s, 1024, 2);

    // stereo signal
    var sound = {
        var signal = Resonz.ar(
            [ClipNoise.ar(1.7), ClipNoise.ar(1.8)],
            SinOsc.ar(1000).range(100, 500)
        );

        // update buffers
        ScopeOut2.ar(signal, bufferA.bufnum);
        ScopeOut2.ar(signal, bufferB.bufnum);

        Out.ar(0, signal);
    }.play;

    // GUI
    var window = Window("Dual Osciliscope", 640@320).front
    .onClose_({
        sound.free;
        bufferA.free;
        bufferB.free;
    });
    window.addFlowLayout;
    waveScope = ScopeView(window, 314@310).bufnum_(bufferA.bufnum);
    phaseScope = ScopeView(window, 314@310).bufnum_(bufferB.bufnum);

    waveScope.server = s;
    phaseScope.server = s;

    // customize scopes
    waveScope.style_(1) //overlay channels
    .waveColors_([Color.red, Color.white])
    .background_(Color.black(0.4))
    .xZoom_(1.7) // scaling
    .yZoom_(1.2); // factors

    phaseScope.style_(2) // lissajous mode
    .waveColors_([Color.red])
    .background_(Color.black(0.4))
    .xZoom_(1.2) // scaling
    .yZoom_(1.2); // factors

    waveScope.start;
    phaseScope.start;

    CmdPeriod.doOnce({
        window.close
    });
}
)
