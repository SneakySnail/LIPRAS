% Executes on button press of any checkbox in panel_constraints.
function checkbox_constraints_Callback(o, ~, handles)
% Save new constraint as an index from panel_constraints.UserData
if strcmpi(o.String, 'N')
    o.Parent.UserData(1) = ~o.Parent.UserData(1);
elseif strcmpi(o.String, 'x')
    o.Parent.UserData(2) = ~o.Parent.UserData(2);
elseif strcmpi(o.String, 'f')
    o.Parent.UserData(3) = ~o.Parent.UserData(3);
elseif strcmpi(o.String, 'w')
    o.Parent.UserData(4) = ~o.Parent.UserData(4);
elseif strcmpi(o.String,'m')
    o.Parent.UserData(5) = ~o.Parent.UserData(5);
end

cp = handles.guidata.currentProfile;
profiledata = handles.cfit(cp);


if o.Value == 1 % If constraint box was checked
    handles.xrd.Status=['Constraining coefficient ',get(o,'String'),'.'];
    
else % constraint box was unchecked
    handles.xrd.Status=['Deselected constraint ',get(o,'String'),'.'];
end

% if more than 3 peak functions, resize the column to fit checkboxes
if profiledata.NumPeaks > 2
    % If constraint box was checked and fitting more than 2 peaks
    width = handles.table_paramselection.ColumnWidth;
    
    if o.Value == 1
        oldTable = handles.table_paramselection.Data;
        width{1} = width{1} - 30;
        width{end+1} = 30;
        handles.table_paramselection.ColumnName{end+1} = o.String;
        handles.table_paramselection.Data(:,end+1) = {true};
        
    else  % constraint box was unchecked
        cols = handles.table_paramselection.ColumnName;
        ind = find(strcmpi(cols, o.String));
        handles.table_paramselection.ColumnName(ind) = [];
        handles.table_paramselection.Data(:, ind) = [];
        width{1} = width{1} + 30;
        width = width(1:end-1);
        
    end
    set(handles.table_paramselection, 'ColumnWidth', width);
    
end

handles.guidata.constraints{cp} = getConsMatrix(handles);
set(handles.panel_coeffs.Children,'enable', 'off');

assignin('base', 'handles', handles);
guidata(o, handles)