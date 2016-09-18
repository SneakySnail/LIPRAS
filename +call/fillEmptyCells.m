% --- 
function isFilled = fillEmptyCells(handles)
% --- Fills empty cells in table_coeffvals with their default values only if the
% initial peak upd.peakPositionsitions are in the table. 
upd = call.getSavedParam(handles);
isFilled = false;

% If not enough peak upd.peakPositions for each function
if length(upd.peakPositions) < length(upd.fcnNames) 
	return
end

[SP,LB,UB] = handles.xrd.getDefaultStartingBounds(upd.fcnNames, upd.peakPositions);

% Fill in table with default values if cell is empty
for i=1:length(upd.coeff)
	if isempty(handles.table_coeffvals.Data{i,1})
		handles.table_coeffvals.Data{i,1} = SP(i);
	end
	if isempty(handles.table_coeffvals.Data{i,2})
		handles.table_coeffvals.Data{i,2}  =LB(i);
	end
	if isempty(handles.table_coeffvals.Data{i,3})
		handles.table_coeffvals.Data{i,3} = UB(i);
	end
end

isFilled = true;

if strcmpi(handles.uitoggletool5.State,'on')
	legend(handles.xrd.DisplayName,'box','off')
end


guidata(handles.table_coeffvals,handles)
