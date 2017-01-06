function fill_table_results(handles)
try
    result_vals = transpose(vertcat(handles.xrd.fit_parms{:}));

    coeff = handles.cfit(1).Coefficients;
    set(handles.table_results, ...
        'Data', num2cell(result_vals), ...
        'RowName', coeff, ...
        'ColumnName', num2cell(1:length(handles.xrd.Filename)), ...
        'ColumnFormat', {'numeric'}, ...
        'ColumnWidth', {'auto'}, ...
        'ColumnEditable', false);
    
    for i=1:length(handles.xrd.Filename)
%          assert(length(handles.table_results.Data(i,:))==length(handles.xrd.fit_parms{i}));
        handles.table_results.Data(:,i) = num2cell(handles.xrd.fit_parms{i});
    end
    
catch ME
        keyboard
end
