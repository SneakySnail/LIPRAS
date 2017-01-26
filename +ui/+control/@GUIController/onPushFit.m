function onPushFit(this, profiles)
handles = this.hg;
if nargin < 2
    profiles = model.ProfileListManager.getInstance(this.hg.profiles);
else
    profiles = model.ProfileListManager.getInstance(profiles);
end

if profiles.xrd.hasFit
    set(handles.menu_save,'Enable','on');
    set(handles.tabpanel, 'TabEnables', {'on', 'on', 'on'}, 'Selection', 3);
    set(handles.tab2_next, 'visible', 'on');
    set(handles.push_viewall, 'enable', 'on', 'visible', 'on');
    handles.tabpanel.TabEnables{3} = 'on';
    handles.tabpanel.Selection = 3;
    
    this.onPlotFitChange('peakfit');
else
    set(handles.menu_save,'Enable','off');
    set(handles.tabpanel, 'TabEnables', {'on', 'on', 'off'}, 'Selection', 2);
    set(handles.tab2_next, 'visible', 'off');
    set(handles.push_viewall, 'enable', 'off', 'visible', 'off');
end

assignin('base','handles',handles);
