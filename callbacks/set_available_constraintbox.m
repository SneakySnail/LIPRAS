function set_available_constraintbox(handles)

set(handles.checkboxN,'Enable','off');
set(handles.checkboxf,'Enable','off');
set(handles.checkboxw,'Enable','off');
set(handles.checkboxm,'Enable','off');

% Function names
try
	fcnNames = handles.table_paramselection.Data(:, 1)';
catch
	fcnNames=handles.table_paramselection.Data';
end

peakHasFunc = ~cellfun(@isempty, fcnNames);

% If there is a peak without a function, disable update button
if find(~peakHasFunc, 1)
% 	set(handles.push_update, 'enable', 'off');
end


% Enable constraints N and f if there is more than 1 fcn
if length(find(peakHasFunc)) > 1
	set(handles.checkboxN,'Enable','on');
	set(handles.checkboxf,'Enable','on');
else
	set(handles.checkboxN,'Enable','off');
	set(handles.checkboxf,'Enable','off');
end

% Enable constraint m for Pearson VII fcns
if length(find(strcmpi(fcnNames, 'Pearson VII'))) + ... 
		length(find(strcmpi(fcnNames, 'Asymmetric Pearson VII'))) > 1	
	set(handles.checkboxm,'Enable','on');
else
	set(handles.checkboxm,'Enable','off');
end
	
% Enable constraint w for Psuedo Voigt fcn
if length(find(strcmpi(fcnNames, 'Psuedo Voigt'))) > 1
	set(handles.checkboxw,'Enable','on');
else
	set(handles.checkboxw,'Enable','off');
end

