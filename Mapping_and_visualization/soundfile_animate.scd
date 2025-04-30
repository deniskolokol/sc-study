// Using SoundFileView
(
var view = SoundFileView(Window("SoundFile view", 640@480).front, 640@480);
var file = SoundFile.new;
var cycles = 50;

file.openRead(PathName("~/Music/ch_4-test track/chnl_count_full_(mono).wav").absolutePath);
view.soundfile_(file);
view.read(0, file.numFrames);
file.close;

view.timeCursorOn_(false)
.gridOn_(false)
.background_(Color.gray)
.waveColors_([Color.blue]);

// animate the contents of the file
fork {
    cycles.do { |counter|
        {
            view.zoomToFrac(counter/cycles);
            view.scrollTo(counter/cycles);
        }.defer;
        0.05.wait
    };
}
)