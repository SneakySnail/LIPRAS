
% Executes on button press in push_fitdata.
function push_fitdata_Callback(hObject, ~, handles)
import utils.plotutils.*
% Create waitbar dialog
try
    h = waitbar(0, '1', 'Name', 'Fitting dataset...', ...
        'CreateCancelBtn', ...
        'setappdata(gcbf,''canceling'', 1)');
    setappdata(h, 'canceling', 0);
catch
end

Stro = handles.profiles.xrd;
try
    steps = Stro.NumFiles;
    fitresults = cell(1, steps);
    xdata = Stro.getTwoTheta;
    for step=1:steps
        % Report current status of fitting dataset
        msg = ['Fitting Dataset ' num2str(step) ' of ' num2str(steps)];
        if exist('h', 'var')
            waitbar(step/steps, h, msg);
        end
        if exist('h', 'var') && getappdata(h, 'canceling')
            break
        end
        ydata = Stro.getDataNoBackground(step);
        fitType = Stro.getFitType();
        fitOptions = Stro.getFitOptions();
        fitresults{step} = model.FitResults(Stro, step);
    end
    
    writer = ui.FileWriter(handles.profiles);
    writer.OutputPath = [writer.OutputPath 'Fdata' filesep];
    writer.printFdataFiles(fitresults);
    
    if exist('h', 'var') && ~getappdata(h, 'canceling')
        Stro.FitResults = fitresults;
        status = true;
    end
    ui.update(handles, 'results');
catch ME
    delete(h)
    errordlg(ME.message)
end

delete(h)
   



