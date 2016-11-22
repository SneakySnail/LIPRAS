function plotX(handles)

set(findobj(handles.axes2), 'visible', 'off');
cla(handles.axes1)
cla(handles.axes2)
filenum=handles.popup_filename.Value;

if isempty(handles.xrd.Fmodel) % If there isn't a fit yet
	plotData(handles, filenum);
	try
		handles = plot_sample_fit(handles);
	catch
			
	end
else
	plotFit(handles, filenum);
end

xlabel('2\theta','FontSize',11);
ylabel('Intensity','FontSize',11);
set(handles.axes1, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
title(handles.axes1, [handles.xrd.Filename{filenum} ' (' num2str(filenum) ' of ' num2str(length(handles.xrd.Filename)) ')']);
