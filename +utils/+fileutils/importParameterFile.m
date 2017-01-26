function handles = importParameterFile(handles)
%IMPORTPARAMETERFILE Reads a file containing parameter settings and saves it 
%   into the current profile.

cp = handles.guidata.currentProfile;

try
    fid = getParameterFileId();
catch
    %     rethrow(ME)
    return
end

try
    pVal = readParameterFile();
catch
    msg = ['The selected file is not in the valid format. ' ...
        'Please choose a different file.'];
    handles.xrd.Status = ['<html><font color="red">' msg];
    MException('LIPRAS:importParameterFile', msg);
end

% Begin save into handles.guidata
resetGuiData(handles, cp, 'profile');
    
saveParameters(pVal);

set(handles.tabpanel, 'TabEnables', {'on', 'on', 'off'}, ...
    'Selection', 2);

plotX(handles, 'sample');

% updateUiControlValues();
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
                line = fgetl(fid);
                param.fxn = strsplit(line, '; ');
                if isempty(param.fxn{end})
                    param.fxn(end) = [];
                end
                
            case 'PeakPosition(s):'
                param.peakpos = str2double(a(2:end));
                
            case 'Constraints:'
                param.constraints = str2double(a(2:end));
                numfcns = length(param.constraints)/5;
                param.constraints = reshape(param.constraints, [numfcns 5]);
                
            case 'DataPath:'
                param.datapath = a(2);
                
            case 'Filenames:'
                param.filename = a(2:end);
                if isempty(a{end})
                    param.filename = a(2:end-1);
                end
                
                
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

    function saveParameters(param)
    handles.cfit(cp).MinRange = param.min2t;
    handles.cfit(cp).MaxRange = param.max2t;
    handles.cfit(cp).PolyOrder = param.polyorder;
    handles.cfit(cp).BackgroundPoints = param.bkgd;
    handles.cfit(cp).NumPeaks = length(param.fxn);
    handles.cfit(cp).FcnNames = param.fxn;
    handles.cfit(cp).PeakPositions = param.peakpos;
    handles.cfit(cp).Constraints = param.constraints;
    handles.cfit(cp).Coefficients = param.coeff;
    handles.cfit(cp).FitInitialStart = param.sp;
    handles.cfit(cp).FitInitialLower = param.lb;
    handles.cfit(cp).FitInitialUpper = param.ub;
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
    
    
    end
%===============================================================================

end