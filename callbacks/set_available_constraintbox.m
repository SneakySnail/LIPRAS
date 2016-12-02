function set_available_constraintbox(handles)
cp = handles.guidata.currentProfile;

set(handles.checkboxN,'Enable','off');
set(handles.checkboxf,'Enable','off');
set(handles.checkboxf,'Enable','off');
set(handles.checkboxw,'Enable','off');
set(handles.checkboxm,'Enable','off');


fcnNames = handles.guidata.PSfxn{cp};
peakHasFunc = ~cellfun(@isempty, fcnNames);

% If there is a peak without a function, disable update button
if find(~peakHasFunc, 1)
 	set(handles.push_update, 'enable', 'off');
	set(handles.push_selectpeak, 'enable', 'off');
end


% Enable constraints N and f if there is more than 1 fcn
if length(find(peakHasFunc)) > 1
	set(handles.checkboxN,'Enable','on');
	set(handles.checkboxf,'Enable','on');
    set(handles.checkboxx, 'enable', 'on');
else
	set(handles.checkboxN,'Enable','off');
	set(handles.checkboxf,'Enable','off');
    set(handles.checkboxx, 'enable', 'on');
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

% Save into handles.guidata
handles.guidata.constraints{cp} = handles.panel_constraints.UserData;

try
    handles.guidata.coeff{cp} = handles.xrd.getCoeff(fcnNames, handles.guidata.constraints{cp});
catch ME
    
   handles.guidata.coeff{cp} = [];
   [info,index] = dbstack('-completenames', 1);
   uiwait(errordlg(['Error in ' info(1).file ' line ' num2str(info(1).line) ': ' ME.message]))
   
end
