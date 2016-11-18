% This function sets the table_fitinitial in the GUI to have the coefficients for the new
% user-inputted function names. 
% It also saves handles.guidata into handles.xrd
% 
%Better name is update_table_fitinitial_properties
function handles = update_fitoptions(handles)
coeff = handles.xrd.getCoeff(handles.guidata.PSfxn, handles.guidata.constraints);
fcnNames = handles.guidata.PSfxn;

set(handles.table_fitinitial, 'data', cell(length(coeff), 3), 'RowName', coeff);
handles.xrd.Fmodel=[];

try
        assert(length(fcnNames) == length(handles.guidata.PeakPositions));
catch
        return
end

[SP,LB,UB] = handles.xrd.getDefaultStartingBounds(fcnNames, handles.guidata.PeakPositions);

handles.guidata.fit_initial = {SP;LB;UB};
handles.guidata.coeff = coeff;
handles.xrd.PSfxn = handles.guidata.PSfxn;
handles.xrd.PeakPositions = handles.guidata.PeakPositions;

handles.xrd.Status = [handles.xrd.Status, 'Done.'];
plotX(handles);

guidata(handles.figure1, handles)