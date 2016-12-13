function handles = updateConstraints(handles)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

cp = handles.guidata.currentProfile;

handles = setEnabledComponents(handles);

handles = setComponentValues(handles);

assignin('base', 'handles', handles);

% ============================================== %
% 
% ============================================== % 
function handles = setEnabledComponents(handles)
set(handles.checkboxN,'Enable','off');
set(handles.checkboxx,'Enable','off');
set(handles.checkboxf,'Enable','off');
set(handles.checkboxw,'Enable','off');
set(handles.checkboxm,'Enable','off');

try
fcnNames = handles.guidata.PSfxn{cp};
peakHasFunc = ~cellfun(@isempty, fcnNames);
catch ex
   error(ex.Message)
   
   
end

% Enable constraints N, x, and f if there is more than 1 fcn
if length(find(peakHasFunc)) > 1
	set(handles.checkboxN,'Enable','on');
    set(handles.checkboxx,'Enable','on');
	set(handles.checkboxf,'Enable','on');
else
	set(handles.checkboxN,'Enable','off');
    set(handles.checkboxx,'Enable','off');
	set(handles.checkboxf,'Enable','off');
end

% Enable constraint m for Pearson VII fcns
if length(find(strcmpi(fcnNames, 'Pearson VII'))) + ... 
		length(find(strcmpi(fcnNames, 'Asymmetric Pearson VII'))) > 1	
	set(handles.checkboxm,'Enable','on');
else
	set(handles.checkboxm,'Enable','off');
end

% Enable constraint w for Pseudo Voigt fcn
if length(find(strcmpi(fcnNames, 'Pseudo-Voigt'))) > 1
	set(handles.checkboxw,'Enable','on');
else
	set(handles.checkboxw,'Enable','off');
end
end
   

function handles = setComponentValues(handles)
% reset constraints panel
set(handles.panel_constraints.Children, 'value', 0);

constraints = model.fitcomponents.Constraints(handles.guidata.constraints{cp});

for i=1:constraints.total
   handles.(['checkbox' constraints.coeffs{i}]).Value = 1;
end
end
end
