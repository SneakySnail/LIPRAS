function onPlotFitChange(this, viewname)
%ONPLOTVIEWCHANGE changes the available components in the Results tab.
import utils.plotutils.*
handles = this.hg;
fitresults = handles.profiles.getProfileResult;
fitted = fitresults{handles.gui.CurrentFile};
coeffvals = zeros(length(fitresults), length(fitted.CoeffNames));
for i=1:length(fitresults)
    coeffvals(i, :) = fitresults{i}.CoeffValues;
end
coeffvals = transpose(coeffvals);
switch viewname
    case 'peakfit'
        cla(handles.axes1)
        handles.btns3.SelectedObject = handles.radio_peakeqn;
        coeffs = fitted.CoeffNames;
        set(handles.table_results, ...
            'Data', num2cell(coeffvals), ...
            'RowName', coeffs, ...
            'ColumnName', num2cell(1:length(fitresults)), ...
            'ColumnFormat', {'numeric'}, ...
            'ColumnWidth', {75}, ...
            'ColumnEditable', false);
        set(handles.listbox_files, 'enable', 'on');
        set(handles.popup_filename, 'enable', 'on');
        handles.gui.Plotter.updateXLabel(handles.axes1);
        handles.gui.Plotter.updateYLabel(handles.axes1);
        plotX(handles, 'fit');
        
    case 'coeff'
        cla(handles.axes1)
        handles.btns3.SelectedObject = handles.radio_coeff;
        set(handles.listbox_files, 'enable', 'off');
        set(handles.popup_filename, 'enable', 'off');
        coefflength = length(fitted.CoeffNames);
        set(handles.table_results, ...
            'Data', num2cell([false(coefflength, 1), coeffvals]), ...
            'ColumnName', [{''} num2cell(1:length(fitresults))], ...
            'ColumnFormat', {'logical', 'numeric'}, ...
            'ColumnWidth', {30, 75}, ...
            'ColumnEditable', [true false]);
        handles.table_results.Data(:,1) = {false};
        handles.table_results.Data{1, 1} = true;
        plotX(handles, 'coeff');
                
    case 'stats'
        plotX(handles, 'stats');
        
end