w = Window.new;
w.front;
w.alwaysOnTop_(true);
w.close; // the ind=stance of the Window is destroyed.


// multiline syntax
(
w = Window.new
.front
.alwaysOnTop_(true);
)

// current kit
GUI.current

// position and size
w.bounds_(Rect(3400, 400, 500, 400))
w.close;


(
Window.closeAll;

w = Window.new("dotty", Rect(
    Window.screenBounds.width/2-500,
    Window.screenBounds.height,
    500,
    200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20, 20, 150, 30))
)

~slider.value_(0.25)

(
~slider.action_({ |obj|
    w.view.background_(Color(0.4, 0.1, obj.value*0.3+0.7));
    obj.value.postln;
})
)

~slider.valueAction_(rrand(0.00, 1.00))

~slider.background_(Color.rand)


// audio control

(
SynthDef(\simplebpf, {
    arg freq=440, rq=0.2;
    var signal = PinkNoise.ar(1!2);
    signal = BPF.ar(
        signal,
        freq.lag(0.5),
        rq.lag(0.5),       // when a filter's bandpass narrows, the amplitude decreases, so...
        1/rq.sqrt.lag(0.5) // this will ensure that the amp will remain constant regardless of filter quality
    );
    Out.ar(0, signal);
}).add
)

(
Window.closeAll;

w = Window.new("BPF", Rect(
    Window.screenBounds.width/2+2500,
    Window.screenBounds.height,
    380,
    80))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20, 20, 150, 30))
.background_(Color(0.2, 0.75, 0.95))
.action_({ |obj|
    var cf = obj.value.linexp(0, 1, 100, 4000);
    if (x.isPlaying) {x.set(\freq, cf)};
    ~numberBox.value_(cf);
});

~numberBox = NumberBox(w, Rect(180, 20, 80, 30))
.value_(100)
.clipLo_(100)
.clipHi_(4000)
.font_(Font("Monospace", 16))
.decimals_(2)
.action_({ |nb|
    ~slider.valueAction_(nb.value.explin(100, 4000, 0, 1))
});
~freqLabel = StaticText(w, Rect(180, 50, 80, 20))
.string_("freq")
.font_(Font("Monospace", 14))
.align_(\center);

~knob = Knob(w, Rect(270, 20, 30, 30))
.action_({ |knob|
    var quality = knob.value.linexp(0, 1, 1, 100).reciprocal;
    if (x.isPlaying) {x.set(\rq, quality)}
});

~button = Button(w, Rect(310, 20, 50, 30))
.states_([
    ["OFF", Color.black, Color.gray(0.8)],
    ["ON", Color.white, Color(0.2, 0.75, 0.95)]
])
.font_(Font("Monospace", 18))
.action_({ |bt|
    if (bt.value == 1) {
        x = Synth(\simplebpf, [
            \freq, ~slider.value.linexp(0, 1, 100, 4000),
            \rq, ~knob.value.linexp(0, 1, 1, 100).reciprocal
        ]).register;
    } {
        x.free;
    }
})
)
