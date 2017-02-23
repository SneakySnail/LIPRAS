function colorOrderIndexChanged(~, ~, handles)
% Property listener for the color order index. If ColorOrderIndex changes, make
% sure it doesn't go over the max index.
colors = get(handles.axes1, 'ColorOrder');
index = get(handles.axes1, 'ColorOrderIndex');
if isempty(handles.axes1.Children)
    index = 1;
elseif index > length(handles.axes1.Children)+1
    index = length(handles.axes1.Children)+1;
end
if index > length(colors)
    index = mod(index, length(colors));
end
set(handles.axes1, 'ColorOrderIndex', index);

