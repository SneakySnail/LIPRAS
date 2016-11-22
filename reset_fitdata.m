function reset_fitdata(handles)
handles.xrd.Fmodel = [];
handles.xrd.PSfxn = '';
handles.xrd.PeakPositions = [];
handles.xrd.Constrains = zeros(1,5);
handles.xrd.fit_initial = [];

resetGuiData(handles, handles.guidata.);

guidata(handles.figure1, handles);

function updateGUI(handles)
set(handles.edit_numpeaks, 'string', '', 'userdata', []);
set(handles.panel_constraints, 'userdata', zeros(1,5));
setappdata(handles.table_paramselection, 'PSfxn', {});
setappdata(handles.table_paramselection, 'coeff', {});
handles.tabpanel.TabEnables{3} = 'off';
handles.tabpanel.Selection = 2;

plotX(handles);