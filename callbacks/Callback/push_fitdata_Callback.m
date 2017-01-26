
% Executes on button press in push_fitdata.
function push_fitdata_Callback(hObject, ~, handles)
import utils.plotutils.*

handles.profiles.xrd.fitDataSet;	% Function - fit data

handles.gui.onPushFit(handles.profiles);




