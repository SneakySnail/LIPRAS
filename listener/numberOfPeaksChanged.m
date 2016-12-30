% Executes when the handles.edit_numpeaks spinner value is changed.
function numberOfPeaksChanged(src, ~, handles)
%NUMBEROFPEAKSCHANGED Callback function that executes when the value of the
%   JSpinner object changes. 
cp = handles.guidata.currentProfile;
profiledata = handles.cfit(cp);
value = int8(src.getValue);

% Don't do anything if the number of peaks is the same as before
if length(profiledata.FcnNames) == value
    src.setValue(value);
    return
end

if value == 0
    set(handles.panel_parameters.Children, 'visible', 'off');
    % Number of peaks label
    set(findobj(handles.panel_parameters, 'tag', 'text12'), 'visible', 'on');
    % Number of peaks uicomponent
    set(handles.edit_numpeaks, 'visible', 'on');
    set(handles.tab2_prev, 'visible', 'on');

else
    set([handles.tab2_panel1, handles.panel_constraints, handles.panel_kalpha2], ...
        'visible', 'on');
end

handles = resetGuiData(handles, cp, 'profile'); %TODELETE
set(handles.panel_constraints.Children, 'value', 0, 'enable', 'off');

% Set user data
handles.guidata.numPeaks(cp) = value; %TODELETE
handles.guidata.constraints{cp} = zeros(value, 5);

% set uicontrol visibility
set(handles.table_paramselection, ...
        'Enable', 'on', ...
        'ColumnName', {'Peak function'}, ...
        'ColumnWidth', {250}, ...
        'Data', cell(value, 1));
set(handles.panel_coeffs.Children, 'enable', 'off');
set(handles.push_selectpeak, 'enable', 'off');
set(handles.push_update, 'enable', 'off');

assignin('base', 'handles', handles);
guidata(handles.figure1, handles)

