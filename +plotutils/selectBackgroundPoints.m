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
handles.points{cp} = points;    % Added for compatibility with Gio's code
handles.pos{cp} = pos;          % Added for compatibility with Gio's code

% update the handles structure
guidata(handles.figure1, handles);
handles = guidata(handles.figure1);
assignin('base', 'handles', handles);

zoom reset

% Lets assign 2th points to bkgd2th in each xrdContainer
handles.xrdContainer(1,cp).bkgd2th=handles.cfit(cp).BackgroundPoints;
plotX(handles, 'data');
guidata(handles.figure1, handles)