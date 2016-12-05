
% Executes on button press in push_fitdata.
function push_fitdata_Callback(hObject, ~, handles)
handles.xrd.Status='Fitting dataset...';
set(handles.radio_stopleastsquares, 'enable', 'on');

cp = handles.guidata.currentProfile;
fnames = handles.guidata.PSfxn{cp};
peakpos = handles.guidata.PeakPositions{cp};
fitinit = handles.guidata.fit_initial{cp};
constraints = handles.guidata.constraints{cp};

handles.xrd.PSfxn = fnames;
handles.xrd.fit_initial = fitinit;
handles.xrd.PeakPositions = peakpos;
handles.xrd.Constrains = constraints;

SP = fitinit{1};
UB = fitinit{2};
LB = fitinit{3};

try
    resizeAxes1ForErrorPlot(handles, 'fit');
    handles.xrd.fitData(peakpos, fnames, SP, UB, LB, handles);	% Function - fit data
    handles = guidata(hObject);
    
    if isempty(handles.xrd.Fmodel)
        handles.guidata.fitted{cp} = false; 
    else
        handles.guidata.fitted{cp} = true;
    end
    
    plotX(handles, 'fit');
    
catch ME
    
    resizeAxes1ForErrorPlot(handles, 'data');
    
    plotX(handles, 'data');
    
    rethrow(ME)
end

if ~handles.guidata.fitted{cp}
    errordlg('There was a problem with fitting your dataset. Please try again.')
    return
end

filenum = get(handles.popup_filename, 'Value');		% The current file visible
vals = handles.xrd.fit_parms{filenum};			% The fitted parameter results

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



