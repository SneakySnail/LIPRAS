function displayErrorPlot(handles)
set(handles.axes2, 'visible', 'on');
ax2h = handles.axes2.Position(4);
out1 = handles.axes1.Position;

handles.axes1.Position = out1 + [0 ax2h 0 -ax2h];