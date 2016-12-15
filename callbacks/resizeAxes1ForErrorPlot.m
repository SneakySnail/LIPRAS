function resizeAxes1ForErrorPlot(handles, size)
% resize is either 'larger' or 'smaller'
persistent large;
persistent originalSize;

ax2h = 1.7*handles.axes2.Position(4);
out1 = handles.axes1.OuterPosition;
cp=handles.guidata.currentProfile;

if isempty(large)
    large = false;
end

if nargin <= 1
    if handles.guidata.fitted{cp}
        size = 'fit';
    else
        size = 'data';
    end
end

if strcmpi(size, 'fit') && large == false
    set(findobj(handles.axes2), 'visible', 'on');
    originalSize = handles.axes1.OuterPosition;
    handles.axes1.OuterPosition = out1 + [0 ax2h 0 -ax2h];
    large = true;
    
    
elseif strcmpi(size, 'data') && large == true
    set(findobj(handles.axes2), 'visible', 'off');
    handles.axes1.OuterPosition = originalSize;
    large = false;
    
end
