function reset_fitdata(handles)
handles.xrd.Fmodel = [];
setappdata(handles.uipanel3, 'numPeaks', 0);
setappdata(handles.uipanel3, 'PSfxn', '');
setappdata(handles.uipanel3, 'coeff', []);
setappdata(handles.uipanel3, 'PeakPositions', []);
setappdata(handles.uipanel3,  'constraints', zeros(1,5));
setappdata(handles.uipanel3, 'fit_initial', []);

handles.xrd.PSfxn = '';
handles.xrd.PeakPositions = [];
handles.xrd.Constrains = zeros(1,5);
handles.xrd.fit_initial = [];

updateGUI(handles);

guidata(handles.figure1, handles);

function updateGUI(handles)
set(handles.edit_numpeaks, 'string', '', 'userdata', []);
set(handles.panel_constraints, 'userdata', zeros(1,5));
setappdata(handles.table_paramselection, 'PSfxn', {});
setappdata(handles.table_paramselection, 'coeff', {});
handles.tabpanel.TabEnables{3} = 'off';
handles.tabpanel.Selection = 2;

plotX(handles);