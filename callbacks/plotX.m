function plotX(handles)

set(findobj(handles.axes2), 'visible', 'off');
cla(handles.axes1)
cla(handles.axes2)
filenum=handles.popup_filename.Value;

if isempty(handles.xrd.Fmodel) % If there isn't a fit yet
	handles.xrd.plotData(get(handles.popup_filename,'Value'));
	handles = plot_sample_fit(handles);
else
	handles.xrd.plotFit(get(handles.popup_filename,'Value'));
end

set(handles.axes1, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')

if strcmpi(handles.uitoggletool5.State,'on') 
	legend(handles.xrd.DisplayName)
end