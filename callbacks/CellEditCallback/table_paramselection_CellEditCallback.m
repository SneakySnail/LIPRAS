% better name is table_fcnNames
function table_paramselection_CellEditCallback(hObject, evt, handles)
set_available_constraintbox(handles);

fcnNames = handles.guidata.PSfxn;
try
    fcnNames = hObject.Data(:, 1)';
catch
    fcnNames=hObject.Data';
end
peakHasFunc = ~cellfun(@isempty, fcnNames);


setappdata(handles.uipanel3, 'PSfxn', fcnNames);
setappdata(hObject, 'PSfxn', fcnNames);
handles.guidata.PSfxn = fcnNames;

data.PSfxn = fcnNames;
for i=2:length(hObject.ColumnName)
    data.(hObject.ColumnName{i}) = hObject.Data{:, i};
end

% Enable buttons if all peaks have a fit function selected
if isempty(find(~peakHasFunc, 1))
    set(handles.push_selectpeak, 'enable', 'on', 'visible', 'on');
    coeff = handles.xrd.getCoeff(fcnNames, handles.guidata.constraints);
    setappdata(hObject, 'coeff', coeff);
    setappdata(handles.uipanel3, 'coeff', coeff);
    
else
    set(handles.push_selectpeak, 'enable', 'off');
end


if ~isempty(handles)
    set(handles.push_update,'enable', 'on')
else
    set(handles.push_update,'enable', 'off')
end

guidata(hObject, handles);