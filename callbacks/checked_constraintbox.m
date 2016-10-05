function checked_constraintbox(hObject, handles)
	
		% Save new constraint as an index from panel_constraints.UserData
	if strcmpi(hObject.String, 'N')
		hObject.Parent.UserData(1) = ~hObject.Parent.UserData(1);
	elseif strcmpi(hObject.String, 'f')
		hObject.Parent.UserData(2) = ~hObject.Parent.UserData(2);
	elseif strcmpi(hObject.String, 'w')
		hObject.Parent.UserData(3) = ~hObject.Parent.UserData(3);
	elseif strcmpi(hObject.String,'m')
		hObject.Parent.UserData(4) = ~hObject.Parent.UserData(4);
	end
	
	if hObject.Value == 1 % If constraint box was checked
		handles.xrd.Status=['Constraining coefficient ',get(hObject,'String'),'.'];
		
	else % constraint box was unchecked
		handles.xrd.Status=['Deselected constraint ',get(hObject,'String'),'.'];
	end
	
	% if more than 3 functions
	if length(handles.table_paramselection.Data(:,1))>2
		% If constraint box was checked and fitting more than 2 peaks
		if hObject.Value == 1
			oldTable = handles.table_paramselection.Data;
			
			handles.table_paramselection.ColumnName{end+1} = hObject.String;
			handles.table_paramselection.Data(:,end+1) = {true};
			
		else  % constraint box was unchecked
			cols = handles.table_paramselection.ColumnName;
			ind = find(strcmpi(cols, hObject.String));
			handles.table_paramselection.ColumnName(ind) = [];
			handles.table_paramselection.Data(:, ind) = [];
			
		end
		resizeColumnWidth();
	end
	
	% Set xrd parameters
	handles.xrd.Constrains = hObject.Parent.UserData;
	
	guidata(hObject, handles)
	
	
	
	
	function resizeColumnWidth()
		numcts = length(find(hObject.Parent.UserData));
		
		width = {300};
		
		for i=1:numcts
			width{1} = width{1} - 30;
			width{i+1} = 30;
		end
		
		set(handles.table_paramselection, 'ColumnWidth', width);
	end
	
	
end