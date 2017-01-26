function table_paramselection_CellEditCallback(hObject, evt, handles)
row = evt.Indices(1);
col = evt.Indices(2);
colnames = hObject.ColumnName;
if col == 1
    if isempty(evt.PreviousData) && length(colnames) > 1
        hObject.Data(row, 2:end) = {true};
    elseif isempty(evt.NewData) && length(colnames) > 1
        hObject.Data(row, 2:end) = [];
    end
    % Function change
    handles.profiles.xrd.setFunctions(handles.gui.FcnNames);
    ui.update(handles, 'functions');
    handles.profiles.xrd.constrain(handles.gui.Constraints);
    ui.update(handles, 'constraints');
else
    % On constraint value change
    handles.profiles.xrd.unconstrain('Nxfwm');
    handles.profiles.xrd.constrain(handles.gui.ConstraintsInTable);
    ui.update(handles, 'Constraints');
    
    if length(colnames) > 1
        idx = find(cellfun(@isempty, handles.gui.FcnNames));
        for i=1:length(idx)
            hObject.Data(idx(i), 2:end) = {[]};
        end
    end
end
