function table_paramselection_CellEditCallback(hObject, evt, handles)
	set_available_constraintbox(handles);
	
	try
		fcnNames = hObject.Data(:, 1)';
	catch
		fcnNames=hObject.Data';
	end
	peakHasFunc = ~cellfun(@isempty, fcnNames);
	
	% Enable buttons if all peaks have a fit function selected
	if isempty(find(~peakHasFunc, 1))
		set(handles.push_selectpeak, 'enable', 'on');
		set(handles.push_update,'enable', 'on');
	else
		set(handles.push_selectpeak, 'enable', 'off');
		set(handles.push_update, 'enable', 'off');
	end
	
	set(findobj(handles.panel_coeffs.Children), 'enable', 'off');
