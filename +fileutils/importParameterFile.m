function handles = importParameterFile(handles)
%IMPORTPARAMETERFILE Reads a file containing parameter settings and saves it 
%   into the current profile.

cp = handles.guidata.currentProfile;

try
    fid = getParameterFileId();
catch
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
    
saveParametersIntoGuidata(pVal);

plotX(handles, 'data');

updateUiControlValues();
assignin('base', 'handles', handles);
guidata(handles.figure1, handles)


uitools.adapter.state.fitReady(handles);
%===============================================================================

    function fid = getParameterFileId()
    
    [filename, pathName]  = uigetfile({'*.txt;','*.txt'},'Select Input File','MultiSelect', 'off');
    if ~isequal(filename,0)
        fid = fopen(strcat(pathName,filename),'r');
    end
    end

    function param = readParameterFile()
    
    while ~feof(fid)
        line = fgetl(fid);
        a = strsplit(line,' ');
        % a{1} is the name of the property.
        % The rest are values of property.
        
        switch(a{1})
            case '2ThetaRange:'
                param.min2t = str2double(a{2});
                param.max2t = str2double(a{3});
                
            case 'PolynomialOrder:'
                param.polyorder = str2double(a{2});
                
            case 'BackgroundPoints:'
                param.bkgd = str2double(a(2:end));
                    
            case 'FitRange:'
                param.fitrange = str2double(a(2:end));
                
            case 'FitFunction(s):'
                param.fxn = strsplit(a(2:end), '; ');
                
            case 'Constraints:'
                param.constraints = str2double(a(2:end));
                numfcns = length(param.constraints)/5;
                param.constraints = reshape(param.constraints, [numfcns 5]);
                
            case 'DataPath:'
                param.datapath = a(2);
                
            case 'Filenames:'
                param.filename = a(2:end);
                
                
            case '=='
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
%===============================================================================

    function saveParametersIntoGuidata(pVal)
    
    
    
    handles.guidata.PeakPositions{cp} = pVal.peakpos;
    handles.guidata.PSfxn{cp} = pVal.fxn;
    handles.guidata.numPeaks(cp) = length(pVal.fxn);
    handles.guidata.constraints{cp} = pVal.constraints;
    handles.guidata.fit_initial{cp} = [{pVal.sp}; ...
                                      {pVal.lb}; ...
                                      {pVal.ub}];
    handles.guidata.fitrange{cp} = pVal.fitrange;
    handles.guidata.coeff{cp} = pVal.coeff;
    
    handles.cfit(cp).Range2t = [pVal.min2t pVal.max2t];
    handles.cfit(cp).PolyOrder = pVal.polyorder;
    handles.cfit(cp).BackgroundPoints = pVal.bkgd;
    handles.cfit(cp).NumPeaks = length(pVal.fxn);
    handles.cfit(cp).PeakPositions = pVal.peakpos;
    handles.cfit(cp).Constraints = pVal.constraints;
    handles.cfit(cp).FitInitial.start = pVal.sp;
    handles.cfit(cp).FitInitial.lower = pVal.lb;
    handles.cfit(cp).FitInitial.upper = pVal.up;
    handles.cfit(cp).FitRange = pVal.fitrange;
    handles.cfit(cp).NumPeaks = length(pVal.fxn);
    end
%===============================================================================

    function updateUiControlValues()
    % guidata.numPeaks
    
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
    % constraints
    constrained = model.fitcomponents.Constraints(pVal.constraints);
    
    ui.control.table.toggleConstraints(handles, constrained);
    
    end
%===============================================================================

end