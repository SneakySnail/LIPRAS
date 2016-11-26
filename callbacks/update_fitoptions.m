% This function sets the table_fitinitial in the GUI to have the coefficients for the new
% user-inputted function names.
% It also saves handles.guidata into handles.xrd.
%
%Better name is update_table_fitinitial_properties
function handles = update_fitoptions(handles)
cp = handles.guidata.currentProfile;
fcnNames = handles.guidata.PSfxn{cp};
constraints = handles.guidata.constraints{cp};
coeff = handles.xrd.getCoeff(fcnNames, constraints);
peakpos = handles.guidata.PeakPositions{cp};

set(handles.table_fitinitial, ...
    'data', cell(length(coeff), 3), 'RowName', coeff);

handles.guidata.coeff{cp} = coeff;

% plotX(handles);

assignin('base', 'handles', handles);
guidata(handles.figure1, handles)