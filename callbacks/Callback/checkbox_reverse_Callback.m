function checkbox_reverse_Callback(o, e, handles)
handles.xrd.Status = 'Dataset order was reversed.';
handles = reverse_dataset_order(handles);
guidata(o, handles);

% Reverses the order of the current dataset.
function handles = reverse_dataset_order(handles)
if isempty(handles.xrd.Filename)
    return
end

% Reverse the file name order
handles.gui.FileNames = flip(handles.gui.FileNames);

% For every profile, reverse the dataset order
for j=1:handles.gui.NumProfiles

    
    % Reverse data_fit (the raw y data)
    handles.gui.FullIntensity_
    
    % Reverse fit_parms
    xrd.fit_parms = flip(xrd.fit_parms);
    
    
    % Reverse fit_parms_error
    xrd.fit_parms_error = flip(xrd.fit_parms_error);
    
    % Reverse fit_results
    xrd.fit_results = flip(xrd.fit_results);
    
    % Reverse fit_initial
    if ~isempty(xrd.fit_initial)
        xrd.fit_initial(1,:) = fliplr(xrd.fit_initial(1,:));
    end
    
    
    % Reverse Fmodel
    xrd.Fmodel = flip(xrd.Fmodel);
    
    % Reverse in GUI if not empty
    if ~isempty(xrd.Filename)
        set(findobj(handles.profiles(j), 'tag', 'listbox_files'), ...
            'string', xrd.Filename);
        set(handles.popup_filename, ...
            'string', xrd.Filename);
    end
    
    tr = findobj(handles.profiles(j), 'tag', 'table_results');
    if isprop(tr, 'data')
        set(findobj(handles.profiles(j), 'tag', 'table_results'), ...
            'data', flip(tr.Data, 2), ...
            'columnname', flip(tr.ColumnName));
    end
end

plotX(handles);

