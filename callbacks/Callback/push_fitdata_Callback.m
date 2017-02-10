
% Executes on button press in push_fitdata.
function push_fitdata_Callback(~, ~, handles)
import utils.plotutils.*
% Create waitbar dialog
h = [];
try
    h = waitbar(0, '1', 'Name', 'Fitting dataset...', 'CreateCancelBtn', ...
        'setappdata(gcbf,''canceling'',1)', 'CloseRequestFcn', 'delete(gcbf)');
    setappdata(h, 'canceling', 0);
catch
end

Stro = handles.profiles.xrd;
try
    prfn = handles.profiles.getCurrentProfileNumber;
    for i=1:Stro.NumFiles
        % Report current status of fitting dataset
        msg = ['Fitting Profile ' num2str(prfn) ': Dataset ' num2str(i) ' of ' num2str(Stro.NumFiles)];
        if exist('h', 'var')
            waitbar(i/Stro.NumFiles, h, msg);
        end
        if exist('h', 'var') && getappdata(h, 'canceling')
            break
        end
        handles.profiles.fitDataSet(i);
    end
    ui.update(handles, 'results');
catch ME
    errordlg(ME.message)
end
delete(h)



