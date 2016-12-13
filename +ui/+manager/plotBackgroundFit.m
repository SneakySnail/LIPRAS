function handles = plotBackgroundFit( handles )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here


plotBkPoints(handles);





function plotBkPoints(handles) % plots points and BkgFit

% [points, idx] = handles.xrd.getBkgdPoints(); 
points=handles.points;
idx=handles.pos;

% The current file TODO: "getCurrentFile(handles.popup_filename)"
iFile = handles.popup_filename.Value;
data = handles.xrd.getRangedData(iFile);

if handles.popup_bkgdmodel.Value==1

[P, S, U] = polyfit(handles.xrd.bkgd2th,data(2,idx)', handles.xrd.PolyOrder);
bkgdArray = polyval(P,data(1,:),S,U);

else
    % A bit silly, bkgx and bkgy need the end points, otherwise, the final
    % function wont evaluate the last points and it will lead to a value of
    % zero...
  bkgx=points';
  bkgx=[data(1,1),bkgx,data(1,end)];
  bkgy(1,:)=data(2,idx);
  bkgy=[data(2,1),bkgy,data(2,end)];
  order=2;
yy=spapi(order,bkgx,bkgy);
bkgdArray = fnval(yy,data(1,:));
    
end

cla(handles.axes1)

hold on
plot(handles.axes1,data(1,:),data(2,:),'-o','LineWidth',0.5,'MarkerSize',4, 'MarkerFaceColor', [0 0 0])
plot(handles.axes1, points, data(2,idx), 'rd', 'markersize', 5, ...
    'markeredgecolor', 'r', 'markerfacecolor','r');
plot(handles.axes1,data(1,:),bkgdArray,'--')

