% Enables/disables 'Fit Data' and 'Clear' buttons based on filled cells.
function checktable_coeffvals(handles)

set(handles.panel_coeffs.Children, 'enable', 'on');

% find if a cell in the table is **not** empty
temp = cellfun(@isempty, handles.table_coeffvals.Data(:, 1:3));
if isempty(find(temp == 0, 1))
	% Only passes if ALL cells in the table are empty
	set(handles.push_selectpeak, 'string', 'Select Peak(s)', 'enable', 'on');
	set(handles.push_default, 'enable', 'off');
	set(handles.push_fitdata, 'enable', 'off');
	return
end

set(handles.push_selectpeak, 'string', 'Reselect Peak(s)');

if ~isempty(find(temp, 1))
	% Only passes if AT LEAST ONE is empty
	set(handles.push_fitdata, 'enable', 'off');
end
