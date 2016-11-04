function fill_table_results(handles)
	set(handles.table_results,'RowName',handles.xrd.Fcoeff{1});
	set(handles.table_results,'Data',cell(length(handles.xrd.Fcoeff{1}), length(handles.xrd.Filename)));
	
	assert(length(handles.xrd.Filename)==length(handles.xrd.fit_parms));
	
	for i=1:length(handles.xrd.Filename)
		assert(length(handles.table_results.Data(:,i))==length(handles.xrd.fit_parms{i}));
		handles.table_results.Data(:,i) = num2cell(handles.xrd.fit_parms{i}');
	end
		
		