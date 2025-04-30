(
Server.default = s = Server.local;
s.waitForBoot {
    // GUI
    var window = Window("Frequency Analyzer", 640@480);
    var bus = Bus.audio(s, 2);
    var sound = {
        var signal = Resonz.ar(
            [
                ClipNoise.ar(MouseX.kr(0.1, 3.0, \exponential)),
                ClipNoise.ar(MouseY.kr(0.1, 3.0, \exponential))
            ],
            SinOsc.ar(1000).range(100, 500)
        );

        // Update bus for scoping
        Out.ar(bus, signal);

        //Write to output
        Out.ar(0, signal);
    }.play;

    // the frequency scope
    var scope = FreqScopeView(window, 640@480).active_(true);
    scope.background_(Color.black(0.4)).waveColors_([Color.red]);
    scope.dbRange_(120);
    scope.inBus_(bus);

    window.front;

    // Clean up.
    window.onClose_({
        sound.free;
        scope.kill;
    });
    CmdPeriod.doOnce({
        window.close
    });
}
)