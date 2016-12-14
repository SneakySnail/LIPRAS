function handles = plotBackgroundFit( handles )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here


plotBkPoints(handles);

function plotBkPoints(handles) % plots points and BkgFit
% The current file TODO: "getCurrentFile(handles.popup_filename)"
iFile = handles.popup_filename.Value;
data = handles.xrd.getRangedData(iFile);

% Get Background
wprof=handles.guidata.currentProfile;
bkgModel=handles.popup_bkgdmodel.Value;
if handles.popup_bkgdmodel.Value==1
[bkgArray, S, U]=handles.xrd.fitBkgd(data,handles.points{wprof}, data(2,handles.pos{wprof}), handles.xrd.PolyOrder,bkgModel);
else
    % A bit silly, bkgx and bkgy need the end points, otherwise, the final
    % function wont evaluate the last points and it will lead to a value of
    % zero...
  bkgx=handles.points{wprof}';
  bkgy(1,:)=data(2,handles.pos{wprof});
[bkgArray]=handles.xrd.fitBkgd(data,bkgx, bkgy, handles.xrd.PolyOrder,bkgModel);
end

points=handles.points{wprof};
idx=handles.pos{wprof};

cla(handles.axes1)

hold on
plot(handles.axes1,data(1,:),data(2,:),'-o','LineWidth',0.5,'MarkerSize',4, 'MarkerFaceColor', [0 0 0])
plot(handles.axes1, points, data(2,idx), 'rd', 'markersize', 5, ...
    'markeredgecolor', 'r', 'markerfacecolor','r');
plot(handles.axes1,data(1,:),bkgArray,'--')

