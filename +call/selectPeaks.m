% 
function selectPeaks(hObject, eventdata, handles)

handles.xrd.Fmodel=[];
oldTableData = handles.uitable1.Data;
handles.uitable1.Data(:, 4) = [];							% Empty results column
handles.uitable1.Data{1, 4} = [];							% In case table data was shrunk

handles.xrd.plotData(get(handles.popup_filename,'Value'));

filenum = get(handles.popup_filename, 'Value');
p = call.getSavedParam(handles);
peakTableRow = find(strncmp(p.coeff, 'x', 1));
status='Selecting peak positions(s)... ';
hold on

% ginput for x position of peaks
for i=1:length(peakTableRow)
	handles.uitable1.Data(peakTableRow(i), 1:3) = {['<html><table border=0 width=75 ', ... 
		'bgcolor=#FFA07A><tr><td></td></tr></table></html>']};
	
	handles.xrd.Status=[status, 'Peak ',num2str(i),'. Right click to cancel.'];
	[x,~, btn]=ginput(1);
	if btn == 3 % if the left mouse button was not pressed
		handles.uitable1.Data = oldTableData;
		break
	end
	handles.xrd.PeakPositions(i) = x;
	handles.uitable1.Data{peakTableRow(i),1} = x;
	handles.uitable1.Data(peakTableRow(i),2:3)  = {[], []};
	
	pos=PackageFitDiffractionData.Find2theta(handles.xrd.two_theta,x);
	plot(x, handles.xrd.data_fit(1,pos), 'r*') % 'ko'
	
	call.fillEmptyCells(handles);
end
hold off

call.checkuitable1(handles);
handles = call.plotSampleFit(handles);