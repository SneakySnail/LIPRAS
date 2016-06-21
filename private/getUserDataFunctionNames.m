% Returns a string of the current function names
function names = getUserDataFunctionNames(handles)
numpeaks = handles.popup_numpeaks.Value - 1;
filenum = handles.popup_filename.Value;

names = cell(1, numpeaks);
for i=1:length(handles.uipanel6.UserData)
	if handles.uipanel6.UserData(i) == 2
		names{i} = 'Gaussian';
	elseif handles.uipanel6.UserData(i) == 3
		names{i} = 'Lorentzian';
	elseif handles.uipanel6.UserData(i) == 4
		names{i} = 'PearsonVII';
	elseif handles.uipanel6.UserData(i) == 5
		names{i} = 'PsuedoVoigt';
	elseif handles.uipanel6.UserData(i) == 6
		names{i} = 'AsymmetricPVII';
	end
end