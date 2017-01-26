% Executes on button press of any checkbox in panel_constraints.
function checkbox_constraints_Callback(o, ~, handles)
% Save new constraint as an index from panel_constraints.UserData

handles.gui.onCheckedConstraints();

constraints = handles.gui.Constraints;
model.update(handles, 'constraints', constraints);

assignin('base', 'handles', handles);
guidata(o, handles)