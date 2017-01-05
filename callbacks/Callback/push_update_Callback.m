% Executes on  'Update' button press.
function push_update_Callback(hObject, ~, handles)
handles.xrd.Status = 'Updating fit options... ';

profiledata = handles.cfit(handles.guidata.currentProfile);
edit_initial_bounds();

ui.control.table.fillFitInitialValues(handles);

% handles = guidata(hObject);

set_btn_clickable();

plotX(handles, 'sample');

handles.xrd.Status = 'Fit options updated.';
assignin('base','handles',handles)
guidata(hObject,handles)

    function edit_initial_bounds()
    % Set parameters into xrd
    handles.xrd.PSfxn = profiledata.FcnNames;
    handles.xrd.Constrains = profiledata.Constraints;
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
