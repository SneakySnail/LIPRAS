function onPlotFitChange(this, viewname)
%ONPLOTVIEWCHANGE changes the available components in the Results tab.
import utils.plotutils.*
handles = this.hg;
switch viewname
    case 'peakfit'
        cla(handles.UIAxes)
%         handles.panel_choosePlotView.SelectedObject = handles.PeakFitButton;
        changeListedItemsToFiles(handles);
        handles.gui.Plotter.updateXLabel(handles.UIAxes);
        handles.gui.Plotter.updateYLabel(handles.UIAxes);
        handles.FitStats1.Visible='on';
        handles.FitStats2.Visible='on';
        handles.FitStats3.Visible='on';
        plotX(handles, 'fit');
    case 'coeff'
        cla(handles.UIAxes)
        handles.panel_choosePlotView.SelectedObject = handles.radio_coeff;
        changeListedItemsToCoeffs(handles);
        handles.FitStats1.Visible='off';
        handles.FitStats2.Visible='off';
        handles.FitStats3.Visible='off';
        plotX(handles, 'coeff');
    case 'stats'
        plotX(handles,'stats')
end

function changeListedItemsToFiles(handles)
set(handles.DropDown, 'enable', 'on');
set(handles.listbox_results, 'String', handles.gui.FileNames);
set(handles.text_results, 'String', 'Files');
handles.gui.CurrentFile = 1;

function changeListedItemsToCoeffs(handles)
set(handles.listbox_results, 'String', handles.gui.Coefficients); % More specific, originally handles.gui.CoeffNames, 
set(handles.text_results, 'String', 'Coefficients');
set(handles.popup_filename, 'enable', 'off');
handles.listbox_results.Value = 1;
