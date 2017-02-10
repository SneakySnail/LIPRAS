function table_paramselection_CellEditCallback(hObject, evt, handles)
%   EVT can be used to test the GUI by passing a struct variable with the field name 'test'
%   containing the value to set. It also has the field 'Indices'.
row = evt.Indices(1);
col = evt.Indices(2);
if isfield(evt, 'test')
    handles.gui.FcnNames{row} = evt.test;
end
if col == 1
    % Function change
    handles.profiles.xrd.setFunctions(handles.gui.FcnNames{row}, row);
    ui.update(handles, 'functions');
    handles.profiles.xrd.constrain(handles.gui.Constraints);
    ui.update(handles, 'constraints');
else
    % On constraint value change
    handles.profiles.xrd.unconstrain('Nxfwm');
    handles.profiles.xrd.constrain(handles.gui.ConstraintsInTable);
    ui.update(handles, 'Constraints');
    
end
