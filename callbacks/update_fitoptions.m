% This function sets the table_fitinitial in the GUI to have the coefficients for the new
% user-inputted function names. 
% It also saves handles.guidata into handles.xrd.
% 
%Better name is update_table_fitinitial_properties
function handles = update_fitoptions(handles)
cp = handles.guidata.currentProfile;
coeff = handles.xrd.getCoeff(handles.guidata.PSfxn{cp}, handles.guidata.constraints{cp});
fcnNames = handles.guidata.PSfxn{cp};

set(handles.table_fitinitial, 'data', cell(length(coeff), 3), 'RowName', coeff);
handles.xrd.Fmodel=[];

try
        assert(length(fcnNames) == length(handles.guidata.PeakPositions{cp}));
catch
        return
end

[SP,LB,UB] = handles.xrd.getDefaultStartingBounds(fcnNames, handles.guidata.PeakPositions{cp});

handles.guidata.fit_initial{cp} = {SP;LB;UB};
handles.guidata.coeff{cp} = coeff;
handles.xrd.PSfxn = handles.guidata.PSfxn{cp};
handles.xrd.PeakPositions = handles.guidata.PeakPositions{cp};

handles.xrd.Status = [handles.xrd.Status, 'Done.'];
plotX(handles);

guidata(handles.figure1, handles)