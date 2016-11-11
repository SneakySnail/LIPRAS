function edit_numpeaks_Callback(hObject, evt, handles)
	str = get(hObject, 'string');
	num = str2double(str);
	
	if isempty(str) || isnan(num) || num < 1
% 		set(findobj(handles.tab_peak.Children), 'visible', 'off');
		% 		set(hObject, 'String', '1-10', ...
		% 				'FontAngle', 'italic', ...
		% 				'ForegroundColor', [0.8 0.8 0.8], ...
		% 				'Enable', 'inactive');
% 		t12 = findobj(handles.tab_peak, 'tag', 'text12');
		set([t12, handles.edit_numpeaks], 'visible', 'on');
		handles.guidata.numPeaks = 0;
		return
	end
	
	handles.guidata.numPeaks = num;
	if length(handles.xrd.PeakPositions) ~= num
		handles.guidata.PeakPositions = [];
	end
	handles.xrd.Status=['Number of peaks set to ',num2str(num),'.'];
% 	set(findobj(handles.tab_peak.Children), 'visible', 'on');
	set(handles.panel_constraints.Children, 'enable', 'off', 'value', 0);
	set(findobj(handles.panel_coeffs.Children),'enable','off');
	if isempty(handles.guidata.fit_initial)
		set(handles.panel_coeffs, 'visible', 'on');
		set(handles.push_cancelupdate, 'visible', 'on', 'enable', 'on');
	else
		set(handles.panel_coeffs, 'visible', 'off');
		set(handles.push_cancelupdate, 'visible', 'off');
	end
	
	set(handles.table_paramselection, ...
		'enable', 'on', ...
		'ColumnName', {'Peak function'}, ...
		'ColumnWidth', {250}, ...
		'Data', cell(num, 1));
	
	
	set(hObject, 'enable', 'off');
	drawnow;
	set(hObject,'enable', 'on');
	guidata(hObject, handles)

		
	