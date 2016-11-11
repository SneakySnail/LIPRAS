function edit_numpeaks_Callback(hObject, evt, handles)
	str = get(hObject, 'string');
	num = str2double(str);
	
	if length(handles.xrd.PeakPositions) ~= num
		handles.guidata.PeakPositions = [];
	end
	
	if isempty(str) || isnan(num) || num < 1 || num > 25
		set(handles.panel_parameters.Children, 'visible', 'off');
		t12 = findobj(handles.uipanel3, 'tag', 'text12');
		set([t12, handles.edit_numpeaks], 'visible', 'on');
 		handles.guidata.numPeaks = 0;
		setappdata(handles.uipanel3, 'numPeaks', 0);
		return
	end
	
 	handles.guidata.numPeaks = num;
	setappdata(handles.uipanel3, 'numPeaks', num);
	handles.xrd.Status=['Number of peaks set to ',num2str(num),'.'];
	
	set(findobj(handles.btns2), 'visible', 'on');
% 	set(handles.panel_constraints, 'visible', 'off');
	set(handles.panel_constraints.Children, 'visible', 'on', 'enable', 'off', 'value', 0);
	set(handles.panel_coeffs, 'visible', 'off');
	set(handles.tab2_panel1, 'visible', 'on');
	set(handles.table_paramselection, 'visible', 'on', ...
		'enable', 'on', 'ColumnName', {'Peak function'}, ...
		'ColumnWidth', {250}, 'Data', cell(num, 1));
	set(handles.push_selectpeak, 'visible', 'on', 'enable', 'off');
	
	%************************************************
	% Fixes bug where focus remains on edit field 
	%************************************************
	set(hObject, 'enable', 'off');
	drawnow;
	set(hObject,'enable', 'on');
	%************************************************
	
	guidata(hObject, handles)

		
	