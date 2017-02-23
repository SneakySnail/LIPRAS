function resizeAxes1ForErrorPlot(handles, size)
% resize is either 'larger' or 'smaller'
if ~handles.profiles.hasData
    return
end
axes1Pos = getappdata(handles.axes1, 'OriginalSize');
axes2Pos = getappdata(handles.axes2, 'OriginalSize');
axes2height = 0.75*axes2Pos(4);
if nargin <= 1
    if handles.profiles.hasData
        size = 'fit';
    else
        size = 'data';
    end
end
if strcmpi(size, 'fit') % && large == false
    set(findobj(handles.axes2), 'visible', 'on');
    handles.axes1.OuterPosition = axes1Pos + [0 axes2height 0 -axes2height];
elseif strcmpi(size, 'data') % && large == true
    set(findobj(handles.axes2), 'visible', 'off');
    handles.axes1.OuterPosition = axes1Pos;
    cla(handles.axes2)    
end
