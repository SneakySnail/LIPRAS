function resizeAxes1ForErrorPlot(handles, size)
% resize is either 'larger' or 'smaller'
persistent resized;
persistent originalSize;

ax2h = 1.7*handles.axes2.Position(4);
out1 = handles.axes1.OuterPosition;
cp=handles.guidata.currentProfile;

if isempty(resized)
    resized = false;
end

if nargin <= 1
    if handles.guidata.fitted{cp}
        size = 'fit';
    else
        size = 'data';
    end
end

if strcmpi(size, 'fit') && resized == false
    originalSize = handles.axes1.OuterPosition;
    handles.axes1.OuterPosition = out1 + [0 ax2h 0 -ax2h];
    resized = true;
    set(findobj(handles.axes2), 'visible', 'on');
    
elseif strcmpi(size, 'data') && resized == true
    handles.axes1.OuterPosition = originalSize;
    resized = false;
    set(findobj(handles.axes2), 'visible', 'off');
end
