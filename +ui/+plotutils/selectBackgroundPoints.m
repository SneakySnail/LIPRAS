function selectBackgroundPoints(handles)

cp = handles.guidata.currentProfile; % which profile we talking about here...

% else we are not editing bkg points

if isempty(handles.cfit(cp).BackgroundPoints) % incase of all points deleted using delete or reset
    [points, pos]=EditSelectBkgPoints(handles);
    
elseif handles.radiobutton14_add.Value==1 % activated the add feature
    [points, pos]=EditSelectBkgPoints(handles, 'Append');
    
elseif handles.radiobutton15_delete.Value == 1 % activated the delete
    [points, pos]=EditSelectBkgPoints(handles, 'Delete');
end

handles.cfit(cp).BackgroundPoints = points;
handles.cfit(cp).BackgroundPointsIdx = pos;

% update the handles structure
guidata(handles.figure1, handles);
handles = guidata(handles.figure1);

% Update the GUI
if isempty(handles.cfit(cp).FcnNames) == 0
    set(handles.panel_parameters.Children, 'visible', 'off');
    t12 = findobj(handles.uipanel3, 'tag', 'text12');
    set([t12, handles.edit_numpeaks], 'visible', 'on', 'enable', 'on');
end

if ~isempty(handles.cfit(cp).BackgroundPoints)
    handles.tabpanel.TabEnables{2}='on';
    set(handles.push_fitbkgd, 'enable', 'on');
    set(handles.tab1_next, 'visible', 'on');
else
    handles.tabpanel.TabEnables{2} = 'off';
    set(handles.push_fitbkgd, 'enable', 'off');
    set(handles.tab1_next, 'visible', 'off');
end



zoom reset

% Lets assign 2th points to bkgd2th in each xrdContainer
handles.xrdContainer(1,cp).bkgd2th=handles.cfit(cp).BackgroundPoints;
plotX(handles, 'data');
guidata(handles.figure1, handles)