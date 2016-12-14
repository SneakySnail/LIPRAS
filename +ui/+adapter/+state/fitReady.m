function fitReady(handles)
handles = ui.helpers.controls.updateConstraints(handles);

handles.tabpanel.TabEnables{2} = 'on';
handles.tabpanel.Selection = 2;

set(handles.panel_parameters.Children, 'visible', 'on');

set(handles.tab2_panel1.Children, 'enable', 'on');

set(handles.panel_coeffs.Children, 'enable', 'on');

plotX(handles, 'data');

guidata(handles.figure1, handles)
