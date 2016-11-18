% Plots the background points selected.
function push_fitbkgd_Callback(~, ~, handles)
filenum=get(handles.popup_filename,'value');

axes(handles.axes1)
plotX(handles);

% Plots the background points used to fit the background
[pos,indX]=handles.xrd.getBackground;
hold on
plot(pos,handles.xrd.data_fit(filenum,indX),'r*');

% TODO plot the background fit
