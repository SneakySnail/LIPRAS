function colorOrderIndexChanged(~, ~, handles)
% Property listener for the color order index. If ColorOrderIndex changes, make
% sure it doesn't go over the max index.
colors = get(handles.axes1, 'ColorOrder');
index = get(handles.axes1, 'ColorOrderIndex');

if index > length(colors)
    set(handles.axes1, 'ColorOrderIndex', mod(index, length(colors)));
end

