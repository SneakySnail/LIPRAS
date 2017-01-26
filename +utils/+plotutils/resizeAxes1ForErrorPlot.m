function resizeAxes1ForErrorPlot(handles, size)
% resize is either 'larger' or 'smaller'
persistent large;
persistent originalSize;

if ~handles.profiles.hasData
    return
end

ax2h = 1.7*handles.axes2.Position(4);
out1 = handles.axes1.OuterPosition;

if isempty(large)
    large = false;
end

if nargin <= 1
    keyboard
    if handles.profiles.hasData
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
