function selectBackgroundPoints(handles)

numpoints = length(handles.xrd.bkgd2th);
polyorder = str2num(handles.edit_polyorder.String);

cp = handles.guidata.currentProfile; % which profile we talking about here...

% lets check xrdContainer to know if bkg2th is filled
if isempty(handles.xrdContainer(1,cp).bkgd2th)
        [points, pos]=EditSelectBkgPoints(handles);
handles.points{cp}=points;
handles.pos{cp}=pos;

else % else we are not editing bkg points

if isempty(handles.points{cp}) % incase of all points deleted using delete or reset
    [points, pos]=EditSelectBkgPoints(handles);
handles.points{cp}=points;
handles.pos{cp}=pos;    
elseif handles.radiobutton14_add.Value==1 % activated the add feature
    [points, pos]=EditSelectBkgPoints(handles,handles.points{cp},handles.pos{cp},'Append');
handles.points{cp}=points;
handles.pos{cp}=pos;
elseif handles.radiobutton15_delete.Value==1 % activated the delete
    [points, pos]=EditSelectBkgPoints(handles,handles.points{cp},handles.pos{cp},'Delete');
handles.points{cp}=points;
handles.pos{cp}=pos;
end

if and(handles.radiobutton15_delete.Value==0,handles.radiobutton14_add==0)
else
    handles.xrd.bkgd2th=points; % this is here to activate the FitBackground button
end
% handles.xrd.resetBackground(numpoints,polyorder);

if handles.guidata.numPeaks(cp) == 0
    set(handles.panel_parameters.Children, 'visible', 'off');
    t12 = findobj(handles.uipanel3, 'tag', 'text12');
    set([t12, handles.edit_numpeaks], 'visible', 'on', 'enable', 'on');
end

if ~isempty(handles.xrdContainer(1,cp).bkgd2th)
    handles.tabpanel.TabEnables{2}='on';
    set(handles.push_fitbkgd, 'enable', 'on');
    set(handles.tab1_next, 'visible', 'on');
else
    handles.tabpanel.TabEnables{2} = 'off';
    set(handles.push_fitbkgd, 'enable', 'off');
    set(handles.tab1_next, 'visible', 'off');
end

end

% Lets assign 2th points to bkgd2th in each xrdContainer
handles.xrdContainer(1,cp).bkgd2th=handles.points{cp};
plotX(handles);
guidata(handles.figure1, handles)