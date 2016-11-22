% Resets all buttons in handles.uipanel3 to the last time the 'Update' button
% was clicked. Used in: [FDGUI.m, changeProfile.m].
function reset_panel_view(handles)
set(handles.edit_min2t,'String',sprintf('%2.4f',handles.xrd.Min2T));
set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));
set(handles.edit_fitrange,'String',sprintf('%2.3f',handles.xrd.fitrange));
set(handles.push_update, 'enable', 'off', 'visible', 'off');

set(handles.panel_profilecontrol, 'visible', 'on');
set(handles.uipanel3, 'visible', 'off');

% % 	set(findobj(handles.tab_peak.Children), 'visible', 'off');
% % 	set(findobj(handles.tab_results.Children), 'visible', 'off');
% % 	set([handles.tab_peak, handles.tab_results],'ForegroundColor',[0.8 0.8 0.8]);

assert(handles.profiles(7).UserData == handles.guidata.numProfiles);
if handles.profiles(7).UserData == 0
    tab0(handles);
    
    % If there are no background points yet
elseif isempty(handles.xrd.bkgd2th)
    tab1(handles);
    
elseif isempty(handles.xrd.Fmodel)
    tab2(handles);
else
    tab3(handles);
    
end

% Check/uncheck to calculate CuKa2 peak
set(handles.edit_lambda,'string', num2str(handles.xrd.lambda));

if handles.xrd.CuKa
    set(handles.checkbox_lambda,'value',1);
    set(handles.edit_lambda,'enable','on');
else
    set(handles.checkbox_lambda,'value',0);
    set(handles.edit_lambda,'enable','off');
end

set(handles.uipanel3,'visible', 'on');



function tab0(handles)
set(handles.text22, 'visible', 'on');
set(handles.edit8, 'visible', 'on', ...
    'string', 'Upload new file(s)...', ...
    'fontangle','italic', ...
    'foregroundcolor', [0.502 0.502 0.502]);
set(handles.button_browse, 'visible', 'on');
set(handles.checkbox_reverse, 'visible', 'on');
set(handles.text40, 'visible', 'on');
set(handles.panel_rightside, 'visible', 'off');
set(handles.panel_profilecontrol, 'visible', 'off');



function tab1(handles)
cp = handles.guidata.currentProfile;
set(handles.panel_constraints.Children,'Value',0);
handles.guidata.constraints{cp} = zeros(1,5);
set(handles.tabpanel, 'tabenables', {'on', 'off','off'}, 'selection', 1);


set(findobj(handles.panel_profilecontrol), 'visible', 'on');
set(handles.panel_range, 'visible','on');
set(handles.panel_rightside,'Visible','on');
set(handles.menu_save,'Enable','off');
set(findobj(handles.axes2),'Visible','off');
set(handles.panel_coeffs.Children,'Enable','off');


function tab2(handles)
set(handles.uipanel3, 'visible', 'on');
set(findobj(handles.panel_profilecontrol), 'visible', 'on');
set(handles.tabpanel, 'tabenables', {'on', 'on','off'}, 'selection', 2);


if ~isempty(handles.xrd.PSfxn)
    set(handles.edit_numpeaks, 'string', num2str(handles.xrd.nPeaks));
end

edit_numpeaks_Callback(handles.edit_numpeaks, [], handles);

assert(size(handles.table_paramselection.Data, 1)== handles.xrd.nPeaks);

[handles.table_paramselection.Data{:, 1}] = deal(handles.xrd.PSfxn{:});

set_available_constraintbox(handles);
handles.panel_constraints.UserData = handles.xrd.Constrains;
cboxes = flip(handles.panel_constraints.Children);
temp = num2cell(handles.xrd.Constrains);
[cboxes.Value] = deal(temp{:});


function tab3(handles)
set(handles.uipanel3, 'visible', 'on');
set(findobj(handles.panel_profilecontrol), 'visible', 'on');
set(handles.tabpanel, 'tabenables', {'on', 'on','on'}, 'selection', 3);


