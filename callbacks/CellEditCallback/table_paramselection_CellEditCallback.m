% better name is table_fcnNames
function table_paramselection_CellEditCallback(hObject, evt, handles)
cp = handles.guidata.currentProfile;

getFcnData();

if evt.Indices(2) > 1
    getConsData();
end

set_available_constraintbox(handles);

set(handles.panel_coeffs.Children, 'enable', 'off');

assignin('base', 'handles', handles)
guidata(hObject, handles);



    function getFcnData()
        try
            fcnNames = hObject.Data(:, 1)';
        catch
            fcnNames=hObject.Data';
        end
        peakHasFunc = ~cellfun(@isempty, fcnNames);
        
        handles.guidata.PSfxn{cp} = fcnNames;
        
        data.PSfxn = fcnNames;
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
