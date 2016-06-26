function checkuitable1(handles)

set(handles.uipanel4.Children, 'enable', 'on');

% find if a cell in the table is **not** empty
temp = cellfun(@isempty, handles.uitable1.Data(:, 1:3));
if isempty(find(temp == 0, 1))
	% Only passes if ALL cells in the table are empty
	set(handles.push_default, 'enable', 'off');
elseif ~isempty(find(temp, 1))
	% Only passes if AT LEAST ONE is empty
	set(handles.push_fitdata, 'enable', 'off');
end
