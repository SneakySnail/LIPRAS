function plotX(handles)

% axes(handles.axes1)
cla(handles.axes1)
cla(handles.axes2)
filenum=handles.popup_filename.Value;

minR = str2double(handles.edit_min2t.String);
maxR = str2double(handles.edit_max2t.String);
axes(handles.axes1)
xlim([minR, maxR])

if isempty(handles.xrd.Fmodel) % If there isn't a fit yet
	handles.xrd.plotData(get(handles.popup_filename,'Value'));
	set(handles.axes2,'Visible','off');
	set(handles.axes2.Children,'Visible','off');
	handles = call.plotSampleFit(handles);
else
	handles.xrd.plotFit(get(handles.popup_filename,'Value'));
	set(handles.axes2,'Visible','on');
	set(handles.axes2.Children,'Visible','on');
	SP = handles.xrd.fit_initial{1,filenum};
	vals = handles.xrd.fit_parms{filenum}; % Update results column
	for i=1:length(vals)
		handles.uitable1.Data{i,1} = SP(i);
		handles.uitable1.Data{i,4} = ['<html><table border=0 width=75 bgcolor=#E5E4E2><tr><td align="right"><b>',...
			num2str(vals(i),'%6G'), '</b></td></tr></table></html>'];
	end
end

if strcmpi(handles.uitoggletool5.State,'on')
	legend(handles.xrd.DisplayName,'box','off')
end
