% Reads a parameter file specified by the user into the current profile.
function handles = load_parameter(handles)
cp = handles.guidata.currentProfile;

try
    fid = getParameterFileId();
catch ME
    handles.xrd.Status = 'Parameter file not found. ';
    %     rethrow(ME)
    return
end

try
    pVal = readParameterFile();
catch
    msg = ['The selected file is not in the valid format. ' ...
        'Please choose a different file.'];
    handles.xrd.Status = ['<html><font color="red">' msg];
    errordlg(msg);
end

% Begin save into handles.guidata
resetGuiData(handles, cp, 'profile');

    
saveParametersIntoGuidata();


updateUiControlValues();


ui.adapter.state.fitReady(handles);



% =======================================
% Helper functions
% =======================================

    function fid = getParameterFileId()
    
    [filename, pathName]  = uigetfile({'*.txt;','*.txt'},'Select Input File','MultiSelect', 'off');
    if ~isequal(filename,0)
        fid = fopen(strcat(pathName,filename),'r');
    end
    end

    function param = readParameterFile()
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
                param.min2t = str2double(a{2});
                param.max2t = str2double(a{3});
                
            case 'Number_of_background_points:'
                param.numbkgdpts = str2double(a{2});
                
            case 'Background_order:'
                param.polyorder = str2double(a{2});
                
            case 'Background_points:'
                param.bkgd = str2double(a(2:end));
                
            case 'PeakPos:'
                param.peakpos = str2double(a(2:end));
                
            case 'fitrange:'
                param.fitrange = str2double(a(2:end));
                
            case 'Fxn:'
                j = 1; i =2;
                while i<=length(a)
                    if strcmpi(a{i}, 'Pearson') || strcmpi(a{i}, 'Psuedo')
                        param.fxn{j} = [a{i}, ' ', a{i+1}];
                        i = i+2;
                    elseif strcmpi(a{i}, 'Asymmetric') && strcmpi(a{i+1}, 'Pearson')
                        param.fxn{j} = [a{i}, ' ', a{i+1}, ' ', a{i+2}];
                        i = i+3;
                    else
                        param.fxn{j}=a{i};
                        i=i+1;
                    end
                    j = j+1;
                end
                
            case 'Constraints:'
                param.constraints = str2double(a(2:end));
                param.numfcns = length(param.fxn);
                param.constraints = reshape(param.constraints, [param.numfcns 5]);
                
            case 'DataPath:'
                param.datapath = a(2);
                
            case 'Files:'
                param.filename = a(2:end);
                
                %         case 'Fit_Range'
                %             fitrange = str2double(a(2:end));
                
            case 'Fit_initial'
                break
                
            otherwise
                
        end
    end
    
    % Read coefficient names
    line  = fgetl(fid);
    param.coeff = textscan(line, '%s');
    param.coeff = param.coeff{1}';
    
    % Read SP values
    line  = fgetl(fid);
    param.sp    = textscan(line,'%s');
    param.sp    = param.sp{1}';
    param.sp    = str2double(param.sp(2:end));
    
    % Read UB values
    line  = fgetl(fid);
    param.lb    = textscan(line,'%s');
    param.lb    = param.lb{1}';
    param.lb    = str2double(param.lb(2:end));
    
    % Read LB values
    line  = fgetl(fid);
    param.ub    = textscan(line,'%s');
    param.ub    = param.ub{1}';
    param.ub    = str2double(param.ub(2:end));
    
    fclose(fid);
    
    end


    function saveParametersIntoGuidata()
    
    
    
    handles.guidata.PeakPositions{cp} = pVal.peakpos;
    handles.guidata.PSfxn{cp} = pVal.fxn;
    handles.guidata.numPeaks(cp) = length(pVal.fxn);
    handles.guidata.constraints{cp} = pVal.constraints;
    handles.guidata.fit_initial{cp} = [{pVal.sp}; ...
                                      {pVal.lb}; ...
                                      {pVal.ub}];
    handles.guidata.fitrange{cp} = pVal.fitrange;
    handles.guidata.coeff{cp} = pVal.coeff;
    
    end


    function updateUiControlValues()
    % guidata.numPeaks
    handles.edit_numpeaks.String = num2str(length(pVal.fxn));
    
    %guidata.PSfxn
    set(handles.table_paramselection,...
        'Data', pVal.fxn',...
        'ColumnWidth', {250}, ...
        'ColumnName', 'Peak Function');
    
    % fit_initial
    set(handles.table_fitinitial,...
        'RowName', pVal.coeff',...
        'Data', ([num2cell(pVal.sp); ...
                  num2cell(pVal.lb); ...
                  num2cell(pVal.ub)]'));
    
    % fitrange
    handles.edit_fitrange.String = num2str(pVal.fitrange);
    
    % constraints
    constrained = model.fitcomponents.Constraints(pVal.constraints);
    
    ui.helpers.table.resizeConstraintColumns(handles, constrained);
    
    
    end


end