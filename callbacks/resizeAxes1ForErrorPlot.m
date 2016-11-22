function resizeAxes1ForErrorPlot(handles)
% resize is either 'larger' or 'smaller'
persistent resized;
persistent originalSize;

ax2h = 1.5*handles.axes2.Position(4);
out1 = handles.axes1.OuterPosition;
cp=handles.guidata.currentProfile;

if isempty(resized)
    resized = false;
end

if handles.guidata.fitted{cp} && resized == false
    originalSize = handles.axes1.OuterPosition;
    handles.axes1.OuterPosition = out1 + [0 ax2h 0 -ax2h];
    resized = true;
    
elseif ~handles.guidata.fitted{cp} && resized == true
    handles.axes1.OuterPosition = originalSize;
    resized = false;
end
