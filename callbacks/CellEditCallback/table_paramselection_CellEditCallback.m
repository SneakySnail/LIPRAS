% better name is table_fcnNames
function table_paramselection_CellEditCallback(hObject, evt, handles)
cp = handles.guidata.currentProfile;

% Update guidata.PSfxn{cp} 
handles.guidata.PSfxn{cp} = hObject.Data(:, 1)';

getFcnData();

if evt.Indices(2) > 1
    getConsData();
end

set(handles.panel_coeffs.Children, 'enable', 'off');

set_available_constraintbox(handles);

assignin('base', 'handles', handles)
guidata(hObject, handles);



    function getFcnData()
        fcnNames = handles.guidata.PSfxn{cp};
        peakHasFunc = ~cellfun(@isempty, fcnNames);
        
        for i=2:length(hObject.ColumnName)
            data.(hObject.ColumnName{i}) = hObject.Data{:, i};
        end
        
        % Enable buttons if all peaks have a fit function selected
        if isempty(find(~peakHasFunc, 1))
            set(handles.push_selectpeak, 'enable', 'on');
            set(handles.push_update, 'enable', 'on');
            coeff = handles.xrd.getCoeff(fcnNames, handles.guidata.constraints{cp});
            
        else
            set(handles.push_selectpeak, 'enable', 'off');
            set(handles.push_update, 'enable', 'off');
        end
    end


    function getConsData()
        cMat = getConsMatrix(handles);
        
        handles.guidata.constraints{cp} = cMat;
        
        
    end
end
