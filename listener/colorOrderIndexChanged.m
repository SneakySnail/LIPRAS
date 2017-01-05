function colorOrderIndexChanged(hObject, eventdata, handles)
% Property listener for the color order index. If ColorOrderIndex changes, make
% sure it doesn't go over the max index.

colors = get(gca, 'ColorOrder');
index = get(gca, 'ColorOrderIndex');

if index > length(colors)
    set(gca, 'ColorOrderIndex', mod(index, length(colors)));
end

