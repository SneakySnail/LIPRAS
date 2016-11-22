% Executes on button press of 'Select Peak(s)'.
function push_selectpeak_Callback(hObject,~,handles)
handles.xrd.Status='Selecting peak positions(s)... ';

handles.xrd.Fmodel=[];
oldTableData = handles.table_fitinitial.Data;
fcns = getappdata(handles.table_paramselection, 'PSfxn');

coeff = handles.xrd.getCoeff(handles.guidata.PSfxn,handles.guidata.constraints);
peakTableRow = find(strncmp(coeff, 'x', 1));


hold on
% ginput for x position of peaks
for i=1:length(peakTableRow)
    handles.table_fitinitial.Data(peakTableRow(i), 1:3) = {['<html><table border=0 width=150 ', ...
        'bgcolor=#FFA07A><tr><td></td></tr></table></html>']};
    
    handles.xrd.Status=['Selection peak ',num2str(i),'. Right click anywhere to cancel.'];
    [x(i),~, btn]=ginput(1);
    if btn == 3 % if the left mouse button was not pressed
        handles.table_fitinitial.Data = oldTableData;
        hold off
        plotX(handles);
        return
    end
    
    handles.table_fitinitial.Data{peakTableRow(i),1} = x(i);
    handles.table_fitinitial.Data(peakTableRow(i),2:3)  = {[], []};
    
    pos=PackageFitDiffractionData.Find2theta(handles.xrd.two_theta,x(i));
    plot(x(i), handles.xrd.data_fit(1,pos), 'r*') % 'ko'
    
end

handles.guidata.PeakPositions = x;
% handles.xrd.PeakPositions = x;
handles = update_fitoptions(handles);
fill_table_fitinitial(handles);

setappdata(handles.uipanel3, 'PeakPositions', handles.guidata.PeakPositions);
hold off




set(handles.push_update, 'enable', 'off', 'visible', 'on');
set(handles.panel_coeffs, 'visible', 'on');
set(findobj(handles.panel_coeffs.Children), 'enable', 'on');
set(hObject, 'string', '<html><b>Reselect Peak(s)');

handles.xrd.Status=['The peak positions were selected.'];





