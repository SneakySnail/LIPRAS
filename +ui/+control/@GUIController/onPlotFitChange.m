function onPlotFitChange(this, viewname)
%ONPLOTVIEWCHANGE changes the available components in the Results tab.
import utils.plotutils.*
handles = this.hg;
switch viewname
    case 'peakfit'
        cla(handles.axes1)
        handles.panel_choosePlotView.SelectedObject = handles.radio_peakeqn;
        changeListedItemsToFiles(handles);
        handles.gui.Plotter.updateXLabel(handles.axes1);
        handles.gui.Plotter.updateYLabel(handles.axes1);
        plotX(handles, 'fit');
    case 'coeff'
        cla(handles.axes1)
        handles.panel_choosePlotView.SelectedObject = handles.radio_coeff;
        changeListedItemsToCoeffs(handles);
        plotX(handles, 'coeff');
end

function changeListedItemsToFiles(handles)
set(handles.popup_filename, 'enable', 'on');
set(handles.listbox_results, 'String', handles.gui.FileNames);
set(handles.text_results, 'String', 'Files');
handles.gui.CurrentFile = 1;

function changeListedItemsToCoeffs(handles)
set(handles.listbox_results, 'String', handles.gui.Coefficients);
set(handles.text_results, 'String', 'Coefficients');
set(handles.popup_filename, 'enable', 'off');
handles.listbox_results.Value = 1;
