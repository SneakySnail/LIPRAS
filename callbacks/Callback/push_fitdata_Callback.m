
% Executes on button press in push_fitdata.
function push_fitdata_Callback(~, ~, handles)
import utils.plotutils.*
% Create waitbar dialog
try
    prfn = handles.profiles.getCurrentProfileNumber;    
    fitresults = handles.profiles.fitDataSet(handles.gui, prfn);
    if ~isempty(fitresults)
        ui.update(handles, 'results');
    end
catch ME
    ME.getReport
    assignin('base','lastException',ME)
    errordlg(ME.message)
end



