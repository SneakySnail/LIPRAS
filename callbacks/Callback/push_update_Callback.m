% Executes on  'Update' button press.
function push_update_Callback(hObject, ~, handles)
handles.xrd.Status = 'Updating fit options... ';

edit_initial_bounds();

ui.control.table.fillFitInitialValues(handles);

% handles = guidata(hObject);

set_btn_clickable();

plotX(handles, 'data');

handles.xrd.Status = 'Fit options updated.';
assignin('base','handles',handles)
guidata(hObject,handles)

    function edit_initial_bounds()
    cp = handles.guidata.currentProfile;
    % get new parameters
    fcnNames = handles.guidata.PSfxn{cp};
    constraints = handles.guidata.constraints{cp};
    
    % Set parameters into xrd
    handles.xrd.PSfxn = fcnNames;
    handles.xrd.Constrains = constraints;
    handles = update_fitoptions(handles);
    
    end


    function set_btn_clickable()
    set(handles.panel_coeffs,'visible','on');
    set(handles.panel_coeffs.Children,'visible','on', 'enable', 'on');
    
    emptyCell=find(cellfun(@isempty, handles.table_fitinitial.Data(:, 1:3)), 1);
    
    if isempty(emptyCell)
        set(handles.push_fitdata, 'enable', 'on');
    else
        set(handles.push_fitdata, 'enable', 'off');
    end
    end

end
