% Executes on  'Update' button press.
function push_update_Callback(hObject, eventdata, handles)
handles.xrd.Status = 'Updating fit options... ';

handles.xrd.Fmodel=[];

edit_initial_bounds();

set_btn_clickable();

fill_table_fitinitial(handles);

handles.xrd.Status = 'Fit options updated.';
assignin('base','handles',handles)
guidata(hObject,handles)

    function edit_initial_bounds()
        % get new parameters
        fcnNames = handles.table_paramselection.Data(:, 1)'; % function names to use
        handles.guidata.PSfxn = fcnNames;
        
        numpeaks = str2double(handles.edit_numpeaks.String);
        
        constraints = handles.panel_constraints.UserData; % constraints
        coeff = handles.xrd.getCoeff(fcnNames, handles.guidata.constraints);
        
        % Set parameters into xrd
        handles.xrd.PSfxn = fcnNames;
        handles.xrd.Constrains = constraints;
        
        if length(coeff) ~= length(handles.table_fitinitial.RowName') || ...
                ~isempty(find(~strcmp(handles.table_fitinitial.RowName', coeff), 1)) % if not the same as before
            update_fitoptions();
        end
    end



    function set_btn_clickable()
        
        objs = findobj(handles.panel_parameters.Children);
        for i=1:length(objs)
            if isprop(objs(i), 'Enable')
                set(objs(i), 'Enable', 'off');
            end
        end
        
        set(handles.panel_coeffs,'visible','on');
        set(handles.panel_coeffs.Children,'visible','on', 'enable', 'on');
        
        if find(cellfun(@isempty, handles.table_fitinitial.Data(:, 1:3)), 1)
            set(handles.push_fitdata, 'enable', 'off');
        else
            set(handles.push_fitdata, 'enable', 'on');
        end
    end

end
