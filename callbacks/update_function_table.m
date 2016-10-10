function update_function_table(handles)
	objs = findobj(handles.tab_peak.Children);
	for i=1:length(objs)
		if isprop(objs(i), 'enable')
			set(objs(i), 'enable', 'on');
		end
	end
	
	set(handles.panel_coeffs.Children, 'enable', 'off');

	if ~handles.checkbox_lambda.Value
		set(handles.edit_lambda, 'enable', 'off');
	end
	
	val = find(handles.panel_constraints.UserData);
	hboxes = flipud(handles.panel_constraints.Children);
	
	for i=1:length(val)
		hboxes(val(i)).Value = 1;
	end
	
	set_available_constraintbox(handles);