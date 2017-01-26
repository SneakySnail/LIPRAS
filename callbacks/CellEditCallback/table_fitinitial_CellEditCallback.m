% Executes when entered data in editable cell(s) in table_coeffvals.
function table_fitinitial_CellEditCallback(hObject, eventdata, handles)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data

if ~isa(eventdata.NewData, 'double')
    num = eventdata.PreviousData;
else
    num = eventdata.NewData;
end

% If NewData is empty
if isnan(num)
    num = [];
end

if eventdata.Indices(2) == 1
    bounds = 'start';
elseif eventdata.Indices(2) == 2
    bounds = 'lower';
elseif eventdata.Indices(2) == 3
    bounds = 'upper';
end

coeff = hObject.RowName{eventdata.Indices(1)};
model.update(handles, 'fitinitial', {bounds, coeff, num});



assignin('base', 'handles', handles);
guidata(hObject,handles)