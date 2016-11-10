function checkbox_reverse_Callback(o, e, handles)
	handles.xrd.Status = 'Dataset order was reversed.';
	handles = reverse_dataset_order(handles);
	guidata(o, handles);
	
	% Reverses the order of the current dataset.
function handles = reverse_dataset_order(handles)
	if isempty(handles.xrdContainer(7).Filename)
		return
	end
	
	numprofiles = handles.guidata.numProfiles;
	numprofiles = handles.profiles(7).UserData; % delete
	assert(numprofiles == handles.guidata.numProfiles);
	
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
		if ~isempty(handles.xrdContainer(j).fit_initial)
			handles.xrdContainer(j).fit_initial(1,:) = fliplr(handles.xrdContainer(j).fit_initial(1,:));
		end
		
		
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
