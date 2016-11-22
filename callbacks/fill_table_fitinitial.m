% ---
function isFilled = fill_table_fitinitial(handles)
% --- Fills empty cells in table_coeffvals with their default values only if the
% initial peak peakPositionsitions are in the table.
isFilled = false;
% If not enough peak peakPositions for each function
cp = handles.guidata.currentProfile;
if length(handles.guidata.PeakPositions{cp}) < length(handles.guidata.PSfxn{cp})
    return
end
try
    [SP,LB,UB] = handles.xrd.getDefaultStartingBounds(handles.guidata.PSfxn{cp}, handles.guidata.PeakPositions{cp});
catch
    return
end

coeff = handles.xrd.getCoeff(handles.guidata.PSfxn{cp}, handles.guidata.constraints{cp});

try
    assert(length(coeff) == size(handles.table_fitinitial.Data, 1));
    
%     handles.guidata.fit_initial = {SP;UB;LB};
    
    % Fill in table with default values if cell is empty
    for i=1:length(coeff)
        if isempty(handles.table_fitinitial.Data{i,1})
            handles.table_fitinitial.Data{i,1} = SP(i);
        end
        if isempty(handles.table_fitinitial.Data{i,2})
            handles.table_fitinitial.Data{i,2}  =LB(i);
        end
        if isempty(handles.table_fitinitial.Data{i,3})
            handles.table_fitinitial.Data{i,3} = UB(i);
        end
    end
    
    isFilled = true;    
catch
    
end

handles.xrd.fit_initial = handles.guidata.fit_initial{cp};

guidata(handles.table_fitinitial,handles)
