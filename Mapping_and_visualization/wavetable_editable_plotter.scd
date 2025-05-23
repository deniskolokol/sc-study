( // Wavetable-lookup using an editable Plotter
Server.default.waitForBoot({
    // allocate Buffer (Warning: twice the size of the signal!)
	var buffer = Buffer.alloc(Server.default, 512);
	var plotter = Plotter.new("Wavetable", 800@300).value_(0!256).editMode_(true).editFunc_({ |plotter|
        // convert Array to Signal
        var signal = plotter.value.as(Signal);
        // convert signal to a wavetable
		var wavetable = signal.asWavetable;
        // send to Buffer
		buffer.sendCollection(wavetable, 0);
	});

    // wavetable lookup synthesis
	{
        Out.ar(0,Osc.ar(buffer,250))
    }.scope(zoom:1.8);
})
)
