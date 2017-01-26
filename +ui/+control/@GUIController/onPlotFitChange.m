function onPlotFitChange(this, viewname)
%ONPLOTVIEWCHANGE changes the available components in the Results tab.
import utils.plotutils.*
handles = this.hg;
fitresults = handles.profiles.xrd.getFitResults;
fitted = fitresults{handles.gui.CurrentFile};

for i=1:length(fitresults)
    coeffvals(i, :) = fitresults{i}.CoeffValues;
end
coeffvals = transpose(coeffvals);

switch viewname
    case 'peakfit'
        handles.btns3.SelectedObject = handles.radio_peakeqn;
        coeffs = fitted.CoeffNames;
        set(handles.table_results, ...
            'Data', num2cell(coeffvals), ...
            'RowName', coeffs, ...
            'ColumnName', num2cell(1:length(fitresults)), ...
            'ColumnFormat', {'numeric'}, ...
            'ColumnWidth', {'auto'}, ...
            'ColumnEditable', false);
        set(handles.listbox_files, 'enable', 'on');
        set(handles.popup_filename, 'enable', 'on');

        plotX(handles, 'fit');
        
        
    case 'coeff'
        handles.btns3.SelectedObject = handles.radio_coeff;
        set(handles.listbox_files, 'enable', 'off');
        set(handles.popup_filename, 'enable', 'off');
        coefflength = length(fitted.CoeffNames);
        set(handles.table_results, ...
            'Data', num2cell([false(coefflength, 1), coeffvals]), ...
            'ColumnName', [{''} num2cell(1:length(fitresults))], ...
            'ColumnFormat', {'logical', 'numeric'}, ...
            'ColumnWidth', {30, 'auto'}, ...
            'ColumnEditable', [true false]);
        handles.table_results.Data(:,1) = {false};
        handles.table_results.Data{1, 1} = true;
               
         plotX(handles, 'coeff');
                
    case 'stats'
        
        plotX(handles, 'stats');
        
end