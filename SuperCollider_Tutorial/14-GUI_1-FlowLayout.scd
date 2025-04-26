(
Window.closeAll;

w = Window.new("flow", Rect(
    Window.screenBounds.width/2+2500,
    Window.screenBounds.height,
    400,
    400))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 15@15, 7@7));

10.do { |i|
    Knob(w, 40@40).background_(Color.blue(alpha:0.1*i))
};

Knob(w, 70@70).background_(Color.rand);

w.view.decorator.nextLine;

10.do { |i|
    Knob(w, 40@40).background_(Color.red(alpha:0.1*i))
};

w.view.children.collect(_.value_(rrand(0.0, 1.0)))
)


// delete mutiple objects
w.view.children.collect(_.remove)

// after this the next created element will appear at the current position
// (not in the origin), so make sure to reset decorator
w.view.decorator.reset;

10.do { |i| Knob(w, 40@40).background_(Color.green(alpha:0.1*i))};


// * * *

// CompositeView
(
Window.closeAll;

w = Window.new("flow", Rect(
    Window.screenBounds.width/2+2500,
    Window.screenBounds.height,
    500,
    500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, 30@30));

c = Array.fill(4, { |view|
    view = CompositeView(w, 200@200)
    .background_(Color.rand);

    view.decorator_(FlowLayout(view.bounds, 5@5, 5@5));
});

Array.fill(5, { |i| Slider(c[0], 30@150).background_(Color.red(alpha:0.1*i))});
Array.fill(10, { |i| Knob(c[1], 30@30).background_(Color.green(alpha:0.1*i))});
)

c[0].children[2].value_(0.5)
c[1].children[4].value_(0.15)