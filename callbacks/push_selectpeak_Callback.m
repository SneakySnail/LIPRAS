% Executes on button press of 'Select Peak(s)'.
function push_selectpeak_Callback(~,~,handles)
	handles.xrd.Status='Selecting peak positions(s)... ';
	
	oldTableData = handles.table_fitinitial.Data;
	handles.xrd.PSfxn = handles.table_paramselection.Data(:,1)'; %DELETE
	
	coeff = handles.xrd.getCoeff(handles.xrd.PSfxn, handles.xrd.Constrains);
	setappdata(handles.uipanel3, 'coeff', coeff);
	
	peakTableRow = find(strncmp(coeff, 'x', 1));
	status='Selecting peak positions(s)... ';
	hold on
	
	% ginput for x position of peaks
	for i=1:length(peakTableRow)
		handles.table_fitinitial.Data(peakTableRow(i), 1:3) = {['<html><table border=0 width=150 ', ...
			'bgcolor=#FFA07A><tr><td></td></tr></table></html>']};
		
		handles.xrd.Status=[status, 'Peak ',num2str(i),'. Right click anywhere to cancel.'];
		[x,~, btn]=ginput(1);
		if btn == 3 % if the left mouse button was not pressed
			handles.table_fitinitial.Data = oldTableData;
			break
		end
		handles.xrd.PeakPositions(i) = x;
		handles.table_fitinitial.Data{peakTableRow(i),1} = x;
		handles.table_fitinitial.Data(peakTableRow(i),2:3)  = {[], []};
		
		pos=PackageFitDiffractionData.Find2theta(handles.xrd.two_theta,x);
		plot(x, handles.xrd.data_fit(1,pos), 'r*') % 'ko'
		
		fill_table_fitinitial(handles);
	end
	setappdata(handles.uipanel3, 'PeakPositions', handles.xrd.PeakPositions);
	
		hold off

	update_fitoptions(handles);
	set(findobj(handles.btns2), 'visible', 'on');

	
% 	set(findobj(handles.panel_coeffs.Children), 'enable', 'on');
	set(handles.push_update, 'enable', 'off');
	set(handles.push_cancelupdate, 'visible', 'off');
	set(handles.b2_toggle2, 'enable', 'on');
	set(findobj(handles.panel_coeffs.Children), 'enable', 'on');
	set(handles.push_cancelupdate, 'visible', 'off');
	
	
	
	handles.xrd.Status=[handles.xrd.Status, 'Done.'];
	
	
	
	
	
