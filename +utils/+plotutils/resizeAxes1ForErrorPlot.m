function resizeAxes1ForErrorPlot(handles, size)
% resize is either 'larger' or 'smaller'

% persistent large;
persistent originalSize;

if ~handles.profiles.hasData
    return
end

oldunits = handles.panel_rightside.Units;
set([handles.axes1 handles.axes2], 'units', 'pixels');
ax2h = 1.7*handles.axes2.Position(4);

% if isempty(large)
%     large = false;
% end
if isempty(originalSize)
    originalSize = handles.axes1.OuterPosition;
%     originalSize(2) = 197;
%     originalSize(4) = 721; % original height in pixels
end

if nargin <= 1
    keyboard
    if handles.profiles.hasData
        size = 'fit';
    else
        size = 'data';
    end
end

if strcmpi(size, 'fit') % && large == false
    set(findobj(handles.axes2), 'visible', 'on');
    handles.axes1.OuterPosition = originalSize + [0 ax2h 0 -ax2h];
%     large = true;
    
elseif strcmpi(size, 'data') % && large == true
    set(findobj(handles.axes2), 'visible', 'off');
    handles.axes1.OuterPosition = originalSize;
    cla(handles.axes2)
%     large = false;
    
end

set([handles.axes1 handles.axes2], 'units', oldunits);
