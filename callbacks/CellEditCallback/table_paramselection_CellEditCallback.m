function table_paramselection_CellEditCallback(hObject, evt, handles)
row = evt.Indices(1);
col = evt.Indices(2);
colnames = hObject.ColumnName;
if col == 1
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
    
end
