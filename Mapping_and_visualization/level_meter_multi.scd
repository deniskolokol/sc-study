(
var players;
var buses = Array.fill(3, {Bus.control()});
var window, indicators, updateIndicator;

// Create and customize main window
window = Window.new("Monitoring a complex numerical dataset", 140@210);
window.addFlowLayout;
window.front;

// Create and customize Level indicators
indicators = Array.fill(3, {LevelIndicator(window, 40@200)});
indicators.do { |item|
    item
    .warning_(0.5)
    .critical_(0.7)
    .background_(Color.white)
    .numTicks_(12)
    .numMajorTicks_(3)
    .drawsPeak_(true);
};

Server.default.waitForBoot {
    SynthDef(\fm, {
        arg freq=500, amp=0.8, mRatio=1, cRatio=1, atk=0.01, rel=3, pan=0, out=0, bus=0;
        var car, mod, env, iEnv;
        iEnv = EnvGen.kr(Env([1, 5, 1], [atk, rel], [4, -4]));
        env = EnvGen.kr(Env.perc(atk, rel, curve:[0.2, -4]), doneAction:2);
        mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * iEnv); // modulator
        car = SinOsc.ar(freq * cRatio + mod) * env * amp; // carrier
        car = Pan2.ar(car, pan); // panner
        Out.kr(bus, Amplitude.kr(car)); // amp data to control bus
        Out.ar(out, car); //direct out
    }).add;

    players = [
        Pbind(
            \instrument, \fm,
			\dur, 1/6,
			\midinote, Pseq([
				Pseq([[28, 40]], 32),
				Pseq([[24, 36]], 24), Pseq([[33, 45]], 8),
			],inf) + Pwrand([0, 12], [0.9, 0.1], inf),
            \bus, buses[0],
			\mRatio, 2,
			\atk, 0,
			\rel, Pexprand(0.2,0.4,inf),
            \amp, 0.6
        ).play,
        Pbind(
            \instrument, \fm,
			\dur, 1/6,
			\midinote, Pseq([Pfin(64, Pseq([64, 67, 69, 71, 74, 76],inf))],inf),
            \bus, buses[1],
			\mRatio, Pwrand([0.5, 1.5, 2, 3], [1, 3, 6, 25].normalizeSum, inf),
			\atk, Pwrand([0, Pexprand(0.02, 0.1, 1)], [0.99, 0.01], inf),
			\rel, Pseq(Array.interpolation(64, 0.03, 0.25).mirror2, inf),
            \amp, 0.5
        ).play,
        Pbind(
            \instrument, \fm,
			\dur, 1/6 * 32,
			\midinote, Pseq([
				[40,52,57,59,62],
				[40,55,57,59,64],
				[40,52,57,59,62],
				[33,45,57,59,64],
			],inf),
            \bus, buses[2],
			\mRatio, 1,
			\atk, 1/6 * 16,
			\rel, 1/6 * 24,
            \amp, 0.3
        ).play
    ];

    updateIndicator = fork {
        loop {
            buses.do { |bus, i|
                // Get current value from the bus
                bus.get { |value|
                    {
                        indicators[i].value_(value);
                        indicators[i].peakLevel_(value);
                    }.defer
                };
            };
            // Update indicator every 0.01 seconds
            0.01.wait;
        }
    }
};

// Clean up.
window.onClose_({
    updateIndicator.stop;
    players.do(_.stop);
});
CmdPeriod.doOnce({
    window.close
});
)