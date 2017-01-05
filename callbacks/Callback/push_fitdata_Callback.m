
% Executes on button press in push_fitdata.
function push_fitdata_Callback(hObject, ~, handles)
handles.xrd.Status='Fitting dataset...';
set(handles.radio_stopleastsquares, 'enable', 'on');

cp = handles.guidata.currentProfile;
profiledata = handles.cfit(cp);

fitNames = profiledata.FcnNames;
constraints = profiledata.Constraints;
SP = profiledata.FitInitial.start;
LB = profiledata.FitInitial.lower;
UB = profiledata.FitInitial.upper;

% Save into xrd object
handles.xrd.PSfxn = fitNames;
handles.xrd.fit_initial = {SP; LB; UB};
handles.xrd.Constrains = constraints;

try
    resizeAxes1ForErrorPlot(handles, 'fit');
    handles.xrd.fitData(handles);	% Function - fit data
%     handles = guidata(hObject);
    
    if isempty(handles.xrd.Fmodel)
        handles.guidata.fitted{cp} = false; 
    else
        handles.guidata.fitted{cp} = true;
    end
    
    plotX(handles, 'fit');
    
catch ME
    
    resizeAxes1ForErrorPlot(handles, 'data');
    
    plotX(handles, 'data');
    
    keyboard
end

if ~handles.guidata.fitted{cp}
    errordlg('There was a problem with fitting your dataset. Please try again.')
    return
end

guidata(handles.figure1, handles);

fill_table_results(handles);

set_btn_availability(hObject, handles);

handles.xrd.Status = 'Fitting dataset... Done.';



function set_btn_availability(hObject, handles)
set(handles.menu_save,'Enable','on');
set(handles.tabpanel, 'TabEnables', {'on', 'on', 'on'});
set(handles.tab2_next, 'visible', 'on');
set(handles.radio_stopleastsquares, 'enable', 'off', 'value', 0);
set(handles.push_viewall, 'enable', 'on', 'visible', 'on');

assignin('base','handles',handles)
guidata(hObject, handles)



