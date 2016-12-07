function handles = plotBackgroundFit( handles )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here


plotBkPoints(handles);

plotBkFit(handles);




function plotBkPoints(handles)

[points, idx] = handles.xrd.getBkgdPoints();

% The current file TODO: "getCurrentFile(handles.popup_filename)"
iFile = handles.popup_filename.Value;
data = handles.xrd.getRangedData(iFile);


hold on

plot(handles.axes1, points, data(2,idx), 'rd', 'markersize', 10, ...
    'markeredgecolor', 'r', 'markerfacecolor','r');


function plotBkFit(handles)
polyorder = handles.xrd.PolyOrder;

% [P, S, U] = handles.xrd.fitBkgd(polyorder,  