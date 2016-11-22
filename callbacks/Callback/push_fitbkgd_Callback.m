% Plots the background points selected.
function push_fitbkgd_Callback(~, ~, handles)
filenum=get(handles.popup_filename,'value');

axes(handles.axes1)

% Plots the background points used to fit the background
[pos,indX]=handles.xrd.getBkgdPoints;
hold on
plot(pos,handles.xrd.data_fit(filenum,indX),'r*');

% TODO plot the background fit
