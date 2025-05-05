(
Server.default = s = Server.local;
s.waitForBoot {
    // GUI
    var window = Window("Level Meter", Rect(200, 400, 60, 220))
    .background_(Color.gray);
    var bus = Bus.control();

    // An audio signal
	var sound = {
		var sound = WhiteNoise.ar(
            Demand.kr(Dust.kr(20), 0, Dbrown(0, 1,0.3))
        );
        // Track the signal's amplitude
		var amp = Amplitude.kr(sound);

        // Write amplitude data to control bus
		Out.kr(bus, amp);

        // Send sound to output bus
		Out.ar(0,sound);
	}.play;

    var indicator = LevelIndicator(window, Rect(10, 10, 40, 200))
    .warning_(0.5)
    .critical_(0.7)
    .background_(Color.white)
    .numTicks_(12)
    .numMajorTicks_(3)
    .drawsPeak_(true);

    var updateIndicator = fork {
        loop {
            // Get current value from the bus
            bus.get { |value|
                {
                    indicator.value_(value);
                    indicator.peakLevel_(value);
                }.defer
            };

            // Update indicator every 0.01 seconds
            0.01.wait;
        }
    };

    window.front;

    // Clean up.
    window.onClose_({
        updateIndicator.stop;
        sound.free;
    });
    CmdPeriod.doOnce({
        window.close
    });
}
)