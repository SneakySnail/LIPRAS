% --- 
function isFilled = fill_table_coeffvals(handles)
% --- Fills empty cells in table_coeffvals with their default values only if the
% initial peak peakPositionsitions are in the table. 
isFilled = false;



% If not enough peak peakPositions for each function
if length(handles.xrd.PeakPositions) < length(handles.xrd.PSfxn) 
	return
end

[SP,LB,UB] = handles.xrd.getDefaultStartingBounds(handles.xrd.PSfxn, handles.xrd.PeakPositions);
handles.xrd.fit_initial = {SP;UB;LB};

coeff = handles.xrd.getCoeff(handles.xrd.PSfxn, handles.xrd.Constrains);
% Fill in table with default values if cell is empty
for i=1:length(coeff)
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

% if strcmpi(handles.uitoggletool5.State,'on')
% 	legend(handles.xrd.DisplayName,'box','off')
% end


guidata(handles.table_coeffvals,handles)
