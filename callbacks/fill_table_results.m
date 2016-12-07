function fill_table_results(handles)
	try
		set(handles.table_results, ...
            'ColumnName',handles.xrd.Fcoeff{1}, ...
            'Data',cell(length(handles.xrd.Filename),length(handles.xrd.Fcoeff{1})), ...
            'RowName', handles.xrd.Filename);
		
		assert(length(handles.xrd.Filename)==length(handles.xrd.fit_parms));
		
		for i=1:length(handles.xrd.Filename)
			assert(length(handles.table_results.Data(i,:))==length(handles.xrd.fit_parms{i}));
			handles.table_results.Data(i,:) = num2cell(handles.xrd.fit_parms{i});
		end
		
    catch
        dbstack
	end
	