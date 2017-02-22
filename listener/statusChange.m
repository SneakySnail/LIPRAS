function statusChange(src,evt,handles)
%STATUSCHANGE executes when the GUIController property 'Status' is changed. 
persistent timerStart
previousText = char(handles.statusbarObj.getText);
if isempty(previousText) || isempty(timerStart) || toc(timerStart) > 2
    timerStart = tic;
else
    return
end
handles.statusbarObj.setText(handles.gui.Status);