function [points, idx] = EditSelectBkgPoints(handles, Mode)
% generate the relevant data range, based on Min2T and Max2T
ranged2theta = handles.xrd.two_theta(1,(PackageFitDiffractionData.Find2theta( ...
    handles.xrd.two_theta(1,:),handles.xrd.Min2T) : ...
    PackageFitDiffractionData.Find2theta(...
    handles.xrd.two_theta(1,:), handles.xrd.Max2T)))';

rangedIntensity = handles.xrd.data_fit(1,(PackageFitDiffractionData.Find2theta( ...
    handles.xrd.two_theta(1,:),handles.xrd.Min2T): ...
    PackageFitDiffractionData.Find2theta( ...
    handles.xrd.two_theta(1,:),handles.xrd.Max2T)))';

handles.axes1.UserData = [ranged2theta'; rangedIntensity'];

if nargin < 2 || strcmpi(Mode, 'Add')
%     cla
    plotX(handles, 'data');
    handles.axes1.UserData = [ranged2theta'; rangedIntensity']; % repeated because 
                                                    % plotX clears axes1.UserData
    [points, idx] = Add_bkgpoints(handles);
    
elseif strcmp(Mode,'Append')
    [points, idx] = Append_bkgpoints(handles);
    
    
elseif strcmp(Mode,'Delete')
    cla
    plotX(handles, 'Data');
    [points, idx] = Delete_bkgpoints(handles);
    
else
    error('Invalid Mode')
end

zoom reset
    
guidata(handles.figure1, handles);
% ==============================================================================


function [points, pos] = Add_bkgpoints(handles)
import plotutils.*

twotheta = handles.axes1.UserData(1,:);
intensity = handles.axes1.UserData(2,:);
i = 1;
while (true)
    [p, pidx] = selectOnePointFromPlot(handles.axes1);
    
    if isempty(p)
        break
    end
    
    points(i) = p;
    pos(i) = pidx;
    hold on
    plot(handles.axes1, twotheta(pos(i)), intensity(pos(i)), 'r*') % 'ko'
    
    i = i+1;
end

points=sort(points);
pos=sort(pos);
% ==============================================================================



function [points, pos] = Append_bkgpoints(handles)
import plotutils.*

twotheta = handles.axes1.UserData(1,:);
intensity = handles.axes1.UserData(2,:);
i = 1;
while (true)
    [p, px] = selectOnePointFromPlot(handles.axes1);
    
    if isempty(p)
        break
    end
    
    points(i) = p;
    pos(i) = px;
    
    hold on
    plot(handles.axes1, twotheta(pos(i)), intensity(pos(i)), 'r*') % 'ko'
    
    i = i+1;
end

cp = handles.guidata.currentProfile;
points = sort([handles.cfit(cp).BackgroundPoints, points]);
pos = sort([handles.cfit(cp).BackgroundPointsIdx, pos]);
% ==============================================================================

function [points, pos] = Delete_bkgpoints(handles)
% points - the remaining points to use for the background fit
% pos    - the index of the remaining points

import plotutils.*

twotheta = handles.axes1.UserData(1,:);
intensity = handles.axes1.UserData(2,:);

cp = handles.guidata.currentProfile;
points = handles.cfit(cp).BackgroundPointsIdx;
pos = handles.cfit(cp).BackgroundPointsIdx;

hold on
plot(handles.axes1, twotheta(pos,:), intensity(pos,:), 'r*'); % plot current points

i = 1;
while (true)
    [dpoint, ~] = selectOnePointFromPlot(handles.axes1); % Returns the point to delete
    
    if isempty(dpoint)
        break
    end

    dpos = FindValue(points, dpoint); % find the index into points array 
    points(dpos)=[]; % delete
    pos(dpos)=[];
    
    cla(handles.axes1);
    hold on
    plotX(handles, 'data');
    plot(handles.axes1, twotheta(pos,:), intensity(pos,:), 'r*'); % plot updated points
    
    i = i+1;
end

% ==============================================================================
