function edit_numpeaks_Callback(hObject, evt, handles)
str = get(hObject, 'string');
num = str2double(str);
cp = handles.guidata.currentProfile;

% Don't do anything if the number of peaks is the same as before
if handles.guidata.numPeaks(cp) == int8(num)
    set(hObject, 'string', num2str(int8(num)));
    return
end

handles = resetGuiData(handles, cp, 'profile');
set(handles.panel_constraints.Children, 'value', 0, 'enable', 'off');

if isempty(str) || isnan(num) ...
                || num < 1 || num > 25 ...
                || ~isinteger(int8(num)) 
        
        % set uicontrol visibility
        set(handles.panel_parameters.Children, 'visible', 'off');
        t12 = findobj(handles.uipanel3, 'tag', 'text12');
        set(hObject, 'userdata', [], 'string', '', 'visible', 'on');
        set([t12, handles.tab2_prev, handles.panel_kalpha2], 'visible', 'on');
        
        handles.xrd.Status = '<html><font color="red">Error: Th number of peaks must be a valid integer between 1 and 25.';
        return
end

num = int8(num);

% Set user data
set(hObject, 'userdata', num, 'string', num2str(num));
handles.guidata.numPeaks(cp) = num;

% set uicontrol visibility
set([handles.tab2_panel1, handles.panel_constraints, handles.panel_kalpha2], 'visible', 'on');
set(handles.table_paramselection, ...'visible', 'on', ...
        'enable', 'on', 'ColumnName', {'Peak function'}, ...
        'ColumnWidth', {250}, 'Data', cell(num, 1));
set(handles.panel_coeffs.Children, 'enable', 'off');

%************************************************
% Fixes bug where focus remains on edit field
%************************************************
set(hObject, 'enable', 'off');
drawnow;
set(hObject,'enable', 'on');
%************************************************

handles.xrd.Status=['Number of peaks was set to ',num2str(num),'.'];
guidata(hObject, handles)


