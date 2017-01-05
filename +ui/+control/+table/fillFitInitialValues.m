% ---
function isFilled = fillFitInitialValues(handles)
% Fills empty cells in table_coeffvals with their default values only if the
% initial peak peakPositionsitions are in the table.
isFilled = false;
cp = handles.guidata.currentProfile;
profiledata = handles.cfit(cp);

nPeakPos = profiledata.NumPeakPositions;

% If not enough peak peakPositions for each function
if length(profiledata.PeakPositions) < nPeakPos
    return
end
try
    peakpos = profiledata.PeakPositions;
    fcns = profiledata.FcnNames;
    cons = profiledata.Constraints;
    
    [SP,LB,UB] = handles.xrd.getDefaultStartingBounds(fcns, peakpos, cons);
catch 
    return
end

coeff = profiledata.Coefficients;

try
    assert(length(coeff) == size(handles.table_fitinitial.Data, 1));
        
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

data = handles.table_fitinitial.Data;
handles.guidata.fit_initial{cp} = {[data{:,1}]; [data{:,2}]; [data{:,3}]};


assignin('base', 'handles', handles);
guidata(handles.figure1,handles)
