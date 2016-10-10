function update_bounds_table(handles)
	
	% get new parameters
	fcnNames = handles.table_paramselection.Data(:, 1)'; % function names to use
	assert(length(fcnNames) >= length(handles.xrd.PeakPositions));
	
	constraints = handles.panel_constraints.UserData; % constraints
	coeff = handles.xrd.getCoeff(fcnNames, constraints);
	
	% Set parameters into xrd
	handles.xrd.PSfxn = fcnNames;
	handles.xrd.Constrains = constraints;
	
	if length(coeff) ~= length(handles.table_coeffvals.RowName') || ...
			~isempty(find(~strcmp(handles.table_coeffvals.RowName', coeff), 1)) % if not the same as before
		parameter_changed();
	end

	set_btn_availability();
	
	
	function parameter_changed()
		set(handles.table_coeffvals,'RowName', coeff);
		handles.table_coeffvals.Data = cell(length(coeff), 3);
		
		try
			assert(length(handles.xrd.PeakPositions) == length(fcnNames));
		catch
			return
		end
		
		[SP,LB,UB] = handles.xrd.getDefaultStartingBounds(fcnNames, handles.xrd.PeakPositions);
		
		% Fill in table with default values if cell is empty
		for i=1:length(coeff)
			if isempty(handles.table_coeffvals.Data{i,1})
				handles.table_coeffvals.Data{i,1} = SP(i);
			end
			if isempty(handles.table_coeffvals.Data{i,2})
				handles.table_coeffvals.Data{i,2}  =LB(i);
			end
			if isempty(handles.table_coeffvals.Data{i,3})
				handles.table_coeffvals.Data{i,3} = UB(i);
			end
		end
		
		handles.xrd.Status = [handles.xrd.Status, 'Done.'];
		plotX(handles);
		
	end
	
	function set_btn_availability()
		
		objs = findobj(handles.tab_peak.Children);
		for i=1:length(objs)
			if isprop(objs(i), 'Enable')
				set(objs(i), 'Enable', 'off');
			end
		end
		
		set(handles.push_update,'enable','on');
		set(handles.panel_coeffs,'visible','on');
		set(handles.panel_coeffs.Children,'visible','on', 'enable', 'on');
		
		if find(cellfun(@isempty, handles.table_coeffvals.Data(:, 1:3)), 1)
			set(handles.push_fitdata, 'enable', 'off');
		else
			set(handles.push_fitdata, 'enable', 'on');
		end
	end
	
end
