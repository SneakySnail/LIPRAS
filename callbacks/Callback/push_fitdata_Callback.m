
% Executes on button press in push_fitdata.
function push_fitdata_Callback(hObject, ~, handles)
handles.xrd.Status='Fitting dataset...';
set(handles.radio_stopleastsquares, 'enable', 'on');

cp = handles.guidata.currentProfile;
fnames = handles.guidata.PSfxn{cp};
handles.xrd.PSfxn = fnames;

data = handles.table_fitinitial.Data;	% initial parameter values to use
SP = [];UB = [];LB = [];

% Save table_coeffvals into SP, LB, and UB variables
for i = 1 : length(handles.table_fitinitial.RowName)
    SP(i) = data{i,1};
    LB(i) = data{i,2};
    UB(i) = data{i,3};
end

peakpos = handles.xrd.PeakPositions;			% Initial peak positions guess
try
    if isempty(handles.xrd.Fmodel)
        handles.guidata.fitted{cp} = true; % temporarily set to true
        set(handles.axes1, 'visible', 'off');
        resizeAxes1ForErrorPlot(handles);
    end
    
    set(handles.axes1, 'visible','on');
    
    handles.xrd.fitData(peakpos, fnames, SP, UB, LB,handles);	% Function - fit data

    if isempty(handles.xrd.Fmodel)
        handles.guidata.fitted{cp} = false;
    end
    
    plotX(handles);

catch
    handles.guidata.fitted{cp} = false;
end

if ~handles.guidata.fitted{cp}
    uiwait(errordlg('<html><font color="red">There was a problem with fitting your dataset. Please try again.'))
    return
end

filenum = get(handles.popup_filename, 'Value');		% The current file visible
vals = handles.xrd.fit_parms{filenum};			% The fitted parameter results

handles.table_fitinitial.Data = data;
guidata(handles.figure1, handles)

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



