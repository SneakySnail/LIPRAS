% Executes when entered data in editable cell(s) in table_coeffvals.
function table_fitinitial_CellEditCallback(hObject, eventdata, handles)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% 
% Assumes handles.gui.Coefficients == handles.profiles.xrd.getCoeffs
if ~isa(eventdata.NewData, 'double')
    num = eventdata.PreviousData;
else
    num = eventdata.NewData;
end

r = eventdata.Indices(1);
c = eventdata.Indices(2);
% If NewData is empty
if isnan(num)
    hObject.Data{r, c} = [];
    return
end

if c == 1
    bounds = 'start';
elseif c == 2
    bounds = 'lower';
elseif c == 3
    bounds = 'upper';
end

handles.profiles.xrd.FitInitial.(bounds)(r) = num;
ui.update(handles, 'fitinitial');



assignin('base', 'handles', handles);
guidata(hObject,handles)