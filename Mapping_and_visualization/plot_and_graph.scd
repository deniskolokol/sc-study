// Using plotter
(
var window = Window("Plot and Graph", Rect(0, 0, 640, 480));
var datasetA = Array.fill(100, { rrand(-1.0, 1.0) });
var datasetB = [
    Array.fill(10, { rrand(-1.0, 1.0) }),
    Array.fill(10, { rrand(-1.0, 1.0) })
];
var plotterA = Plotter("datasetA", Rect(5, 5, 630, 235), window).value_(datasetA);
var plotterB = Plotter("datasetB", Rect(5, 250, 630, 235), window).value_(datasetB);

plotterA.setProperties(
    \plotColor, Color.red,
    \gridColorX, Color.white,
    \gridColorY, Color.yellow,
    \backgroundColor, Color.black
).editMode_(true)
.editFunc_({ |plotter, plotIndex, index, val, x, y|
    postf("Plotter A: Value % @ % (%, %)\n", val, index, x, y);
});
plotterB.superpose_(true);
plotterB.setProperties(
    \gridOnX, false,
    \gridOnY, false,
    \plotColor, [Color.blue, Color.green],
    \backgroundColor, Color.gray
).plotMode_(\steps);
window.front;
)
