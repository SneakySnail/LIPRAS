function resizeAxes1ForErrorPlot(handles, size)
% resize is either 'larger' or 'smaller'
persistent large;
persistent originalSize;

if ~handles.profiles.hasData
    return
end

units = handles.panel_rightside.Units;
% set(handles.panel_rightside, 'units', 'pixels');
ax2h = 1.7*handles.axes2.Position(4);
out1 = handles.axes1.OuterPosition;

if isempty(large)
    large = false;
end
if isempty(originalSize)
    originalSize = handles.axes1.OuterPosition;
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
%     originalSize = handles.axes1.OuterPosition;
    set(findobj(handles.axes2), 'visible', 'on');
    handles.axes1.OuterPosition = originalSize + [0 ax2h 0 -ax2h*(1.1)];
    large = true;
    
elseif strcmpi(size, 'data') && large == true
    set(findobj(handles.axes2), 'visible', 'off');
    handles.axes1.OuterPosition = originalSize;
    large = false;
    
end

% set(handles.panel_rightside, 'units', units);
