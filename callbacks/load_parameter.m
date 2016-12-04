function handles = load_parameter(handles)
cp = handles.guidata.currentProfile;

[filename, pathName]  = uigetfile({'*.txt;','*.txt'},'Select Input File','MultiSelect', 'off');
if isequal(filename,0)
    handles.xrd.Status = ['Parameters file not found. '];
    return
end

try
% Begin parsing code
fid = fopen(strcat(pathName,filename),'r');

% Skip first 2 lines
fgetl(fid);
fgetl(fid);

while ~feof(fid)
    line = fgetl(fid);
    a = strsplit(line,' ');
    % a{1} is the name of the property.
    % The rest are values of property.
    
    switch(a{1})
        case '2theta_fit_range:'
            min2t = str2double(a{2});
            max2t = str2double(a{3});
            
        case 'Number_of_background_points:'
            numbkgdpts = str2double(a{2});
            
        case 'Background_order:'
            polyorder = str2double(a{2});
            
        case 'Background_points:'
            bkgd = str2double(a(2:end));
        
        case 'PeakPos:'
            peakpos = str2double(a(2:end));
            
        case 'fitrange:'
            fitrange = str2double(a(2:end));
            
        case 'Fxn:'
            j = 1; i =2;
            while i<=length(a)
                if strcmpi(a{i}, 'Pearson') || strcmpi(a{i}, 'Psuedo')
                    fxn{j} = [a{i}, ' ', a{i+1}];
                    i = i+2;
                elseif strcmpi(a{i}, 'Asymmetric') && strcmpi(a{i+1}, 'Pearson')
                    fxn{j} = [a{i}, ' ', a{i+1}, ' ', a{i+2}];
                    i = i+3;
                else
                    fxn{j}=a{i};
                    i=i+1;
                end
                j = j+1;
            end
            
        case 'Constraints:'
            constraints = str2double(a(2:end));
            
        case 'DataPath:'
            datapath = a(2);
            
        case 'Files:'
            filename = a(2:end);
            
        case 'Fit_Range'
            fitrange = str2double(a(2:end));
            
        case 'Fit_initial'
            break
            
        otherwise
            
    end
end

%This is the section that enables the read in or originial and
%fit_initial parameters from an input file

% Read coefficient names
line  = fgetl(fid);
coeff = textscan(line, '%s'); 
coeff = coeff{1}';

% Read SP values
line  = fgetl(fid);
sp    = textscan(line,'%s');
sp    = sp{1}';
sp    = str2double(sp(2:end));

% Read UB values
line  = fgetl(fid);
ub    = textscan(line,'%s');
ub    = ub{1}';
ub    = str2double(ub(2:end));

% Read LB values
line  = fgetl(fid);
lb    = textscan(line,'%s');
lb    = lb{1}';
lb    = str2double(lb(2:end));

fclose(fid);
catch
    msg = 'The selected file is not in the valid format. Please choose a different file.';
    handles.xrd.Status = ['<html><font color="red">' msg];
    uiwait(errordlg(msg));
    return
end

% Begin save into handles.guidata
resetGuiData(handles, cp, 'profile');
handles.guidata.range2t{cp} = [min2t max2t];
% TODO handles.guidata.BackgroundModel{cp} = 
handles.guidata.nBackgroundCoeffs{cp} = polyorder;
handles.guidata.BackgroundPoints{cp} = bkgd;
handles.guidata.PeakPositions{cp} = peakpos;
handles.guidata.PSfxn{cp} = fxn;
handles.guidata.numPeaks(cp) = length(fxn);
handles.guidata.constraints{cp} = constraints;
handles.guidata.fit_initial{cp} = {sp; ub; lb};
handles.guidata.fitrange{cp} = fitrange;
handles.guidata.coeff{cp} = coeff;
handles.guidata.fitted{cp} = false;

% Begin updating the GUI
handles.edit_min2t.String = num2str(min2t); % guidata.range2t
handles.edit_max2t.String = num2str(max2t); % guidata.range2t
% TODO handles.popup_bkgdmodel.Value = find( % guidata.BackgroundModel
handles.edit_polyorder.String = num2str(polyorder); % guidata.nBackgroundCoeffs
handles.edit_bkgdpoints.String = num2str(length(bkgd)); 
handles.edit_numpeaks.String = num2str(length(fxn)); % guidata.numPeaks
set(handles.table_paramselection, 'Data', fxn', 'ColumnWidth', {250}, ...
    'ColumnName', 'Peak Function');     %guidata.PSfxn

% Input constraints 


    
    

% If current file




% % tab_setup
% set(handles.edit_min2t,'String',sprintf('%2.4f',handles.xrd.Min2T));
% set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));

% %   tab_parameters
% handles.tabpanel.Selection = 2;
% handles.tabpanel.TabEnables{2} = 'on';
% set(handles.edit_fitrange,'String',num2str(handles.xrd.fitrange));

% set(handles.text12,'visible','on');
% set(handles.edit_numpeaks,'visible','on','String',num2str(length(handles.xrd.PSfxn)));

% edit_numpeaks_Callback(handles.edit_numpeaks, [], handles);

% % load peak functions into table
% assert(length(handles.xrd.PSfxn) == length(handles.table_paramselection.Data(:,1)));
% handles.table_paramselection.Data(:, 1) = handles.xrd.PSfxn';

% % load constraints into constraints panel
% handles.panel_constraints.UserData = handles.xrd.Constrains;
% set(flipud(handles.panel_constraints.Children), 'value', handles.xrd.Constrains);

% SP = handles.xrd.fit_initial{1};
% UB = handles.xrd.fit_initial{2};
% LB = handles.xrd.fit_initial{3};

% coeff=handles.xrd.Fcoeff;
% handles.table_fitinitial.RowName = coeff;
% handles.table_fitinitial.Data    = cell(length(coeff), 3);

% for i=1:length(coeff)
    % handles.table_fitinitial.Data{i,1}=SP(i);
    % handles.table_fitinitial.Data{i,2}=LB(i);
    % handles.table_fitinitial.Data{i,3}=UB(i);
% end

% set(handles.panel_coeffs,'Visible','on');
% set(handles.panel_coeffs.Children,'Enable','on', 'visible','on');
% set(handles.push_selectpeak,'string','Reselect Peak(s)');


% plotX(handles, 'data');