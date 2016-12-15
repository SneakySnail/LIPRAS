% Executes on button press of 'Select Peak(s)'.
function push_selectpeak_Callback(hObject,~,handles)
handles.xrd.Status='Selecting peak position(s)... ';

plotX(handles, 'data');

oldTableData = handles.table_fitinitial.Data;
cp = handles.guidata.currentProfile;
fcns = handles.guidata.PSfxn{cp};
constraints = handles.guidata.constraints{cp};

coeff = handles.xrd.getCoeff(fcns, constraints);
peakTableRow = find(strncmp(coeff, 'x', 1));
handles = update_fitoptions(handles);

hold on
% ginput for x position of peaks
for i=1:length(peakTableRow)
    handles.table_fitinitial.Data(peakTableRow(i), 1:3) = {['<html><table border=0 width=150 ', ...
        'bgcolor=#FFA07A><tr><td></td></tr></html>']};
    
    handles.xrd.Status=['Selecting peak ',num2str(i),' (' fcns{i} '). Press the Esc key or right click to cancel.'];
    [x(i), ~, btn] = ginput(1);
                if btn==27
                        return
                    elseif btn ~= 1
                   k=654564465645645; % I'll be impressed if someone hits this key, dont think it exists
                        while k~=1
                    k = waitforbuttonpress; % press any key to continue
                        end
                [x(i),~, btn]=ginput(1);             
                else
%                 points(i,1)=x;            
                end
                if btn==27
                    return
                end               
% 				points(i,1)=x;

    if btn == 1
        handles.table_fitinitial.Data{peakTableRow(i),1} = x(i);
        handles.table_fitinitial.Data(peakTableRow(i),2:3)  = {[], []};
        
        pos=FindValue(handles.xrd.two_theta,x(i));
        plot(x(i), handles.xrd.data_fit(1,pos), 'r*') % 'ko'
        
    else % if the left mouse button was not pressed
        handles.table_fitinitial.Data = oldTableData;
        hold off
        plotX(handles, 'data');
        return
    end
end

handles.guidata.PeakPositions{cp} = x;
fill_table_fitinitial(handles); 
handles = guidata(hObject);

hold off
plotX(handles, 'data');

set(handles.panel_coeffs, 'visible', 'on');
set(handles.panel_coeffs.Children, 'enable', 'on');


assignin('base', 'handles', handles);
guidata(hObject, handles);



