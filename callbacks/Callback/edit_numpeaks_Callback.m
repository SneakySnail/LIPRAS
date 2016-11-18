function edit_numpeaks_Callback(hObject, evt, handles)
str = get(hObject, 'string');
num = str2double(str);

if length(handles.xrd.PeakPositions) ~= num
        handles.guidata.PeakPositions = [];
end

if isempty(str) || isnan(num) ...
                || num < 1 || num > 25 ...
                || ~isinteger(int8(num)) 
        t12 = findobj(handles.uipanel3, 'tag', 'text12');
        handles.guidata.numPeaks = 0;
        set(hObject, 'userdata', [], 'string', '', 'visible', 'on');
        setappdata(handles.uipanel3, 'numPeaks', 0);
        
        % set uicontrol visibility
        set(handles.panel_parameters.Children, 'visible', 'off');
        set([t12, handles.tab2_prev, handles.panel_kalpha2], 'visible', 'on');
        
        handles.xrd.Status = '<html><font color="red"><b>Error: Th number of peaks must be a valid integer between 1 and 25';
        return
end

num = int8(num);

% Set user data
set(hObject, 'userdata', num, 'string', num2str(num));
handles.guidata.numPeaks = num;
setappdata(handles.uipanel3, 'numPeaks', num);

% set uicontrol visibility
set([handles.tab2_panel1, handles.panel_constraints, handles.panel_kalpha2], 'visible', 'on');
set(handles.table_paramselection, ...'visible', 'on', ...
        'enable', 'on', 'ColumnName', {'Peak function'}, ...
        'ColumnWidth', {250}, 'Data', cell(num, 1));

% If no functions selected yet, set 'select peak' button to disabled
if find(cellfun(@isempty, handles.guidata.PSfxn),1)
        set(handles.push_selectpeak, 'enable', 'off');
        set(handles.push_update,'enable','off');
else
        set(handles.push_selectpeak, 'enable', 'on');
        set(handles.push_update, 'enable', 'on');
end

%************************************************
% Fixes bug where focus remains on edit field
%************************************************
set(hObject, 'enable', 'off');
drawnow;
set(hObject,'enable', 'on');
%************************************************

handles.xrd.Status=['Number of peaks was set to ',num2str(num),'.'];
guidata(hObject, handles)


