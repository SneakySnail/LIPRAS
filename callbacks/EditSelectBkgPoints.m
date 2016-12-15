function varargout=EditSelectBkgPoints(handles,points, pos,Mode)
% generate the relevant data range, based on Min2T and Max2T
twotheta = handles.xrd.two_theta(1,(PackageFitDiffractionData.Find2theta( ...
    handles.xrd.two_theta(1,:),handles.xrd.Min2T) : ...
    PackageFitDiffractionData.Find2theta(...
    handles.xrd.two_theta(1,:), handles.xrd.Max2T)))';

intensity = handles.xrd.data_fit(1,(PackageFitDiffractionData.Find2theta( ...
    handles.xrd.two_theta(1,:),handles.xrd.Min2T): ...
    PackageFitDiffractionData.Find2theta( ...
    handles.xrd.two_theta(1,:),handles.xrd.Max2T)))';

if nargin<2
    cla
    plotX(handles)
    
    [points, pos]=Add_bkgpoints(handles,twotheta, intensity);
    
elseif strcmp(Mode,'Append')
    [points, pos]=Append_bkgpoints(handles,twotheta,intensity,points,pos);
    
elseif strcmp(Mode,'Delete')
    [points, pos]=Delete_bkgpoints(handles,twotheta, intensity,points,pos);
    
else
    disp('Invalid Mode')
end

varargout{1}=points;
varargout{2}=pos;

end

function varargout = Add_bkgpoints(handles,twotheta,intensity)
N=1E4;

for i=1:N
    [x,~, key]=ginput(1);
    
    if key==27 % if user pressed Esc
        break
        
    elseif key ~= 1
        k=654564465645645; % I'll be impressed if someone hits this key, dont think it exists
        
        while k~=1
            k = waitforbuttonpress; % press any key to continue
            a=1;
            if handles.radiobutton15_delete.Value==1 
                break 
            end % incase some clicks the add or delete half way
        end
        
        if handles.radiobutton15_delete.Value==1
            break;
        end % incase some clicks the add or delete half way
        
        [x,~, key]=ginput(1);
        
    else
        points(i,1)=x;
    end
    
    if key==27
        break
    end
    hold on
    points(i,1)=x;
    pos(i) = FindValue(twotheta,x);
    plot(handles.axes1,x, intensity(pos(i),1), 'r*') % 'ko'
end
points=sort(points);
pos=sort(pos);
if nargout == 1
    varargout{1} = [points pos];
else
    varargout{1} = points;
end
if nargout > 1
    varargout{1} = points;
    varargout{2} = pos';
end

end

function varargout= Append_bkgpoints(handles,twotheta, intensity, points, pos)
N=1E4;

plotX(handles)
hold on
plot(handles.axes1,twotheta(pos(:,1),:),intensity(pos(:,1),:), 'r*')
hold off

for i=1:N
    [x,~, key]=ginput(1);
    if key==27
        break
    elseif key ~= 1
        k=654564465645645; % I'll be impressed if someone hits this key, dont think it exists
        while k~=1
            k = waitforbuttonpress; % press any key to continue
            if handles.radiobutton15_delete.Value==1; break;end
        end
        if handles.radiobutton15_delete.Value==1; break;end
        [x,~, key]=ginput(1);
    else
        apoints(i,1)=x;
    end
    if key==27
        break
    end
    hold on
    apoints(i,1)=x;
    
    apos(i,1) = FindValue(twotheta,x);
    sapos(i)=apos(i,1);
    plot(handles.axes1,x, intensity(sapos(i),1), 'r*') % 'ko'
end

if exist('apoints','var')==0 % if cancel is selected from the start
    apoints=points;
    fapos=pos;
else
    apoints=sort([points;apoints]);
    fapos=sort([pos;apos]);
end

if nargout == 1
    varargout{1} = [apoints fapos];
else
    varargout{1} = apoints;
end
if nargout > 1
    varargout{1} = apoints;
    varargout{2} = fapos;
end

end

function varargout=Delete_bkgpoints(handles,twotheta, intensity, points,pos)
N=1E4;

plotX(handles)
hold on
plot(handles.axes1,twotheta(pos(:,1),:),intensity(pos(:,1),:), 'r*')
hold off
for i=1:N
    [x,~, key]=ginput(1);
    if key==27
        break
    elseif key ~= 1
        k=654564465645645; % I'll be impressed if someone hits this key, dont think it exists
        while k~=1
            k = waitforbuttonpress; % press any key to continue
            if handles.radiobutton14_add.Value==1; break;end % incase some clicks the add or delete half way
        end
        if handles.radiobutton14_add.Value==1; break;end % incase some clicks the add or delete half way
        [x,~, key]=ginput(1);
    else
        dpoints(i,1)=x;
    end
    if key==27
        break
    end
    hold on
    dpoints(i,1)=x;
    dpos = FindValue(points,x);
    points(dpos)=[];
    pos(dpos)=[];
    cla
    plotX(handles)
    hold on
    plot(handles.axes1,points, intensity(pos,1), 'r*') % 'ko'
    hold off
end
if nargout == 1
    varargout{1} = [points pos];
else
    varargout{1} = points;
end
if nargout > 1
    varargout{2} = pos;
end

end