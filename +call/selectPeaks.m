% 
function selectPeaks(handles)

handles.xrd.Fmodel=[];
oldTableData = handles.table_coeffvals.Data;

plotX(handles);

p = call.getSavedParam(handles);
peakTableRow = find(strncmp(p.coeff, 'x', 1));
status='Selecting peak positions(s)... ';
hold on

% ginput for x position of peaks
for i=1:length(peakTableRow)
	handles.table_coeffvals.Data(peakTableRow(i), 1:3) = {['<html><table border=0 width=150 ', ... 
			'bgcolor=#FFA07A><tr><td></td></tr></table></html>']};
	
	handles.xrd.Status=[status, 'Peak ',num2str(i),'. Right click anywhere to cancel.'];
	[x,~, btn]=ginput(1);
	if btn == 3 % if the left mouse button was not pressed
		handles.table_coeffvals.Data = oldTableData;
		break
	end
	handles.xrd.PeakPositions(i) = x;
	handles.table_coeffvals.Data{peakTableRow(i),1} = x;
	handles.table_coeffvals.Data(peakTableRow(i),2:3)  = {[], []};
	
	pos=PackageFitDiffractionData.Find2theta(handles.xrd.two_theta,x);
	plot(x, handles.xrd.data_fit(1,pos), 'r*') % 'ko'
	
	fill_table_coeffvals(handles);
end
hold off

set(handles.push_selectpeak,'string','Reselect Peak(s)');
set(handles.push_fitdata,'enable','on');
plotX(handles);
plot_sample_fit(handles);