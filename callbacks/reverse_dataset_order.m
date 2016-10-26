% Reverses the order of the current dataset.
function handles = reverse_dataset_order(handles)
	if isempty(handles.xrdContainer(7).Filename)
		return
	end
	
	numprofiles = handles.profiles(7).UserData;
	
	% For every profile, reverse the dataset order
	for j=1:7
		% Reverse the file name order
		handles.xrdContainer(j).Filename = flip(handles.xrdContainer(j).Filename);
		
		% Reverse data_fit (the raw y data)
		handles.xrdContainer(j).data_fit = flip(handles.xrdContainer(j).data_fit, 1);
		
		% Reverse fit_parms
		handles.xrdContainer(j).fit_parms = flip(handles.xrdContainer(j).fit_parms);
		
		
		% Reverse fit_parms_error
		handles.xrdContainer(j).fit_parms_error = flip(handles.xrdContainer(j).fit_parms_error);
		
		% Reverse fit_results
		handles.xrdContainer(j).fit_results = flip(handles.xrdContainer(j).fit_results);
		
		% Reverse fit_initial
		handles.xrdContainer(j).fit_initial = flip(handles.xrdContainer(j).fit_initial);
		
		% Reverse Fmodel
		handles.xrdContainer(j).Fmodel = flip(handles.xrdContainer(j).Fmodel);
		
		% Reverse in GUI if not empty
		if ~isempty(handles.xrdContainer(j).Filename)
			set(findobj(handles.profiles(j), 'tag', 'listbox_files'), ...
				'string', handles.xrdContainer(j).Filename);
			set(handles.popup_filename, ...
				'string', handles.xrdContainer(j).Filename);
		end
		
		tr = findobj(handles.profiles(j), 'tag', 'table_results');
		if isprop(tr, 'data')
			set(findobj(handles.profiles(j), 'tag', 'table_results'), ...
				'data', flip(tr.Data, 2), ...
				'columnname', flip(tr.ColumnName));
		end
	end
	
	plotX(handles);
end

