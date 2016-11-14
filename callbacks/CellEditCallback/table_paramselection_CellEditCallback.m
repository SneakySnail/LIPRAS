function table_paramselection_CellEditCallback(hObject, evt, handles)
	set_available_constraintbox(handles);
	
	try
		fcnNames = hObject.Data(:, 1)';
	catch
		fcnNames=hObject.Data';
	end
	peakHasFunc = ~cellfun(@isempty, fcnNames);
	
	setappdata(handles.uipanel3, 'PSfxn', fcnNames);
	
	% Enable buttons if all peaks have a fit function selected
	if isempty(find(~peakHasFunc, 1))
		set(handles.push_selectpeak, 'enable', 'on', 'visible', 'on');
	else
		set(handles.push_selectpeak, 'enable', 'off');
	end
	
	switch isempty(handles.guidata.fit_initial)
		case 1
			set(handles.push_cancelupdate, 'visible', 'off');
		case 0
			set(handles.push_cancelupdate, 'visible', 'on');
	end
	
	if ~isempty(handles.guidata.PeakPositions)
		set(handles.push_update,'enable', 'on')
	else
		set(handles.push_update,'enable', 'on')
	end
	
