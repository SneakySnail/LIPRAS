
% Executes on button press in push_fitdata.
function push_fitdata_Callback(~, ~, handles)
import utils.plotutils.*
% Create waitbar dialog
try
    h = waitbar(0, '1', 'Name', 'Fitting dataset...', ...
        'CreateCancelBtn', ...
        'setappdata(gcbf,''canceling'', 1)', ...
        'CloseRequestFcn', 'delete(gcbf)');
    setappdata(h, 'canceling', 0);
catch
end

Stro = handles.profiles.xrd;
try
    fitresults = cell(1, Stro.NumFiles);
    for i=1:Stro.NumFiles
        % Report current status of fitting dataset
        msg = ['Fitting Dataset ' num2str(i) ' of ' num2str(Stro.NumFiles)];
        if exist('h', 'var')
            waitbar(i/Stro.NumFiles, h, msg);
        end
        if exist('h', 'var') && getappdata(h, 'canceling')
            break
        end
        fitresults{i} = Stro.fitDataSet(i);
    end
    if exist('h', 'var') && ~getappdata(h, 'canceling')
        Stro.FitResults = fitresults;
        writer = ui.FileWriter(handles.profiles);
        writer.printFitOutputs(fitresults);
    end
    ui.update(handles, 'results');
catch ME
    errordlg(ME.message)
end
delete(h)



