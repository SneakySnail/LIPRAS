% Executes on button press of any checkbox in panel_constraints.
function checkbox_constraints_Callback(o, ~, handles)
	
		% Save new constraint as an index from panel_constraints.UserData
	if strcmpi(o.String, 'N')
		o.Parent.UserData(1) = ~o.Parent.UserData(1);
	elseif strcmpi(o.String, 'f')
		o.Parent.UserData(2) = ~o.Parent.UserData(2);
	elseif strcmpi(o.String, 'w')
		o.Parent.UserData(3) = ~o.Parent.UserData(3);
	elseif strcmpi(o.String,'m')
		o.Parent.UserData(4) = ~o.Parent.UserData(4);
	end
	
	setappdata(handles.uipanel3, 'constraints', o.Parent.UserData);
	
	if o.Value == 1 % If constraint box was checked
		handles.xrd.Status=['Constraining coefficient ',get(o,'String'),'.'];
		
	else % constraint box was unchecked
		handles.xrd.Status=['Deselected constraint ',get(o,'String'),'.'];
	end
	
	% if more than 3 functions
	if length(handles.table_paramselection.Data(:,1))>2
		% If constraint box was checked and fitting more than 2 peaks
		if o.Value == 1
			oldTable = handles.table_paramselection.Data;
			
			handles.table_paramselection.ColumnName{end+1} = o.String;
			handles.table_paramselection.Data(:,end+1) = {true};
			
		else  % constraint box was unchecked
			cols = handles.table_paramselection.ColumnName;
			ind = find(strcmpi(cols, o.String));
			handles.table_paramselection.ColumnName(ind) = [];
			handles.table_paramselection.Data(:, ind) = [];
			
		end
		resizeColumnWidth();
	end
	
	% Set xrd parameters
	handles.xrd.Constrains = o.Parent.UserData;
	set(findobj(handles.panel_coeffs.Children),'enable', 'off');
	if isempty(handles.xrd.fit_initial)
		set(handles.push_cancelupdate, 'enable', 'off');
	else
		set(handles.push_cancelupdate, 'enable', 'on');
	end
	
	set(handles.push_update, 'enable', 'on'); % tTODO
	guidata(o, handles)
	
	
	
	
	function resizeColumnWidth()
		numcts = length(find(o.Parent.UserData));
		
		width = {300};
		
		for i=1:numcts
			width{1} = width{1} - 30;
			width{i+1} = 30;
		end
		
		set(handles.table_paramselection, 'ColumnWidth', width);
	end
	
	
end