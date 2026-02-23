% Imports new data.
function [data, filename, datapath] = newDataSet(datapath, filename)
%   DATAPATH is the folder to initially open.
try
%     PrefFile=fopen('Preference File.txt','r');
%     data_path=fscanf(PrefFile,'%c');
%     data_path(end)=[]; % method above adds a white space at the last character that messes with import
%     fclose(PrefFile);
catch
%     data_path=cd;
end

% allowedFiles = {'*.csv; *.txt; *.xy; *.fxye; *.dat; *.xrdml; *.chi; *.spr'}; % underdevelopment
if ispc
allowedFiles = {'*.xy; *.xye; *.xrdml; *.asc; *.ras; *.chi; *.fxye;  *.csv; *.xls; *.xlsx'};
elseif ismac
    allowedFiles = {'*.xy; *.xye; *.xrdml; *.asc; *.ras; *.chi; *.fxye; *.xls; *.xlsx'};
else % Defaults to Windows
allowedFiles = {'*.xy; *.xye; *.xrdml; *.asc; *.ras; *.chi; *.fxye;  *.csv; *.xls; *.xlsx'};

end

title = 'Select Diffraction Pattern to Fit';
if nargin < 1    
    filterspec = allowedFiles;
else
    filterspec = fullfile(datapath,allowedFiles{1});
end

if nargin < 2
    [filename, datapath] = uigetfile(filterspec, title, 'MultiSelect', 'on');
end

if ~isequal(filename, 0)
    data = readNewDataFile(filename, datapath);
    
else
    data = [];
end
end


function data = readNewDataFile(filename, path)
% DATA - First row is the 2theta, second row and above are the intensities
if isa(filename,'char')
    filename = {filename};
end

% preallocate the structure array 
[~,~,ext] = fileparts(filename{1});
data = struct('two_theta',[],'data_fit',[],'KAlpha1',[],'KAlpha2',[],...
    'kBeta',[],'RKa1Ka2',[],'Temperature',[],'Wavelength',[],'ext',ext);

% iterate through all files
for i=1:length(filename)
    [~,~,ext] = fileparts(filename{i});

    fullFileName = strcat(path, filename{i});
    fid = fopen(fullFileName, 'r');
    
    if strcmpi(ext, '.csv')|| strcmpi(ext, '.xls')||strcmpi(ext, '.xlsx') % For MAC, .csv should not be selected
        datatemp = readSpreadsheet(fullFileName);
    elseif strcmpi(ext, '.txt')

        datatemp = readXYorXYE(i,fullFileName);
    elseif strcmpi(ext, '.xy')||strcmpi(ext, '.xye')
        datatemp = readFile(fid, ext);
    elseif strcmpi(ext, '.fxye')
        datatemp = readFXYE(i,fullFileName);
        try
        data.Temperature=datatemp.temperature;
        data.Wavelength=datatemp.wave;
        catch
        end
    elseif strcmpi(ext, '.chi')
        datatemp = readFile(fid, ext);
        datatemp.error=sqrt(datatemp.data_fit);

    elseif strcmpi(ext, '.dat')
        datatemp = readFile(fid, ext);
    elseif strcmpi(ext, '.xrdml')
        datatemp = parseXRDML(fullFileName);
    elseif strcmpi(ext,'.ras')
                datatemp = utils.fileutils.Rigaku_Read(fullFileName, ext);
    elseif strcmpi(ext,'.asc')
                datatemp = utils.fileutils.Rigaku_Read(fullFileName, ext);
    end
    
    if strcmpi(ext, '.xrdml')
        if size(datatemp.two_theta,1)~=1 % this means xrdml contains multiple scans
        data.two_theta = datatemp.two_theta;
        data.two_theta = mat2cell(data.two_theta,ones(size(data.two_theta,1),1));
        data.data_fit=datatemp.data_fit;
        data.temperature(i,:)=25; % needs work, 2-26-2017
        data.KAlpha1(i,:)=datatemp.KAlpha1;
        data.KAlpha2(i,:)=datatemp.KAlpha2;
        data.RKa1Ka2(i,:)=datatemp.RKa1Ka2;
        data.ext = ext;
        data.error=sqrt(datatemp.data_fit);
        data.error= mat2cell(data.error,ones(size(data.error,1),1));
        data.data_fit= mat2cell(data.data_fit,ones(size(data.data_fit,1),1));
        data.scanType{i}=datatemp.scanType; % for when XRDML contains multiple scans in one file all get same scanType
        if length(data.two_theta)~=length(data.scanType)
            tCell=cell(1,length(data.two_theta));tCell(:)=data.scanType;
            data.scanType=tCell;
        end
   
        else % for XRDML that are single scans
        data.two_theta{i} = datatemp.two_theta;
        data.data_fit{i}=datatemp.data_fit;
        data.temperature(i,:)=datatemp.Temperature;
        data.KAlpha1(i,:)=datatemp.KAlpha1;
        data.KAlpha2(i,:)=datatemp.KAlpha2;
        data.RKa1Ka2(i,:)=datatemp.RKa1Ka2;
        data.ext = ext;
        data.error{i}=sqrt(datatemp.data_fit);
        data.scanType{i}=datatemp.scanType;
        end
    elseif strcmpi(ext,'.asc')||strcmpi(ext,'.ras')
        data.two_theta{i} = datatemp.two_theta;
        data.data_fit{i} = datatemp.data_fit;
        data.KAlpha1(i,:)=datatemp.KAlpha1;
        data.KAlpha2(i,:)=datatemp.KAlpha2;
        data.error{i}=sqrt(datatemp.data_fit);
        data.scanType{i}=datatemp.scanType;
        data.ext = ext;

    else
        data.two_theta{i} = datatemp.two_theta;
        data.data_fit{i} = datatemp.data_fit;
        try
        data.error{i}=datatemp.error;
        catch % in cases where error is not specified upon read
        data.error{i}=sqrt(data.data_fit{i});
        end

    end    
    
    fclose(fid);
end
end


function data = readSpreadsheet(filename)
if contains(filename,'csv')
    temp=table2array(readtable(filename));
else
    temp = xlsread(filename);
end
% Method for reading of data that does not start with numerial
% twotheta and intensity
cc=isnan(temp(:,1)); % checks if any NaN were read in

% Sums the results of cc if after summing 5 rows and the sum is 0, then it
%   re-shapes the data read in with xlsread
for i=1:length(cc)
    s= sum(cc(i:i+5),1);
    if s==0
        p=i;
        break
    end
end

% reshapes based on for loop results
temp = temp(p:end,:);

% now takes the first three columns of intesity and 2-theta and transpose
try
temp = temp(:,1:3)';
catch
    temp = temp(:,1:2)';
end

data.two_theta = temp(1,:);
data.data_fit = temp(2,:);
try
data.error=temp(3,:);
catch
end
end


function data = readFile(fid, ext) 
data = struct('two_theta',[],'data_fit',[],'KAlpha1',[],'KAlpha2',[],...
    'kBeta',[],'RKa1Ka2',[],'Temperature',[], 'ext',ext);
if strcmp(ext, '.xy')
    temp = fscanf(fid,'%f',[2 ,inf]);
elseif strcmp(ext,'.xye')
    temp = fscanf(fid,'%f',[3 inf]);
    data.error=temp(3,:);
elseif strcmp( ext, '.fxye')
    temp = fscanf(fid,'%f',[3 ,inf]);
    temp(1,:) = temp(1,:) ./ 100;
elseif strcmp( ext, '.chi')
    fgetl(fid);fgetl(fid);fgetl(fid);fgetl(fid);
    temp = fscanf(fid,'%f',[2 ,inf]);
else
    temp = fscanf(fid,'%f',[2 ,inf]);
end
data.two_theta = temp(1,:);
data.data_fit = temp(2,:);
end


function data = readFXYE(~, inFile)
%READFXYE Read GSAS/APS-style FXYE text file (BANK header + 3 numeric cols).
%   Column 1 is 2theta in centi-degrees -> converted to degrees.

fid = fopen(inFile,'rt');
if fid < 0
    error('readFXYE:FileOpen','Could not open file: %s', inFile);
end
C = onCleanup(@() fclose(fid));  %#ok<NASGU>

T_K    = NaN;
lambda = NaN;

% --- scan header, capture metadata, stop at BANK line
while true
    line = fgetl(fid);
    if ~ischar(line)
        error('readFXYE:NoBank','Reached EOF before BANK line: %s', inFile);
    end
    s = strtrim(string(line));
    if s == ""
        continue
    end

    % Metadata (flexible and cheap)
    tok = regexp(s, "(?i)^#\s*Temp\s*\(K\)\s*=\s*([+\-]?\d*\.?\d+(?:[eE][+\-]?\d+)?)", ...
        "tokens","once");
    if ~isempty(tok), T_K = str2double(tok{1}); end

    tok = regexp(s, "(?i)^#\s*Calibrated\s+wavelength\s*=\s*([+\-]?\d*\.?\d+(?:[eE][+\-]?\d+)?)", ...
        "tokens","once");
    if ~isempty(tok), lambda = str2double(tok{1}); end

    % Start of numeric section
    if startsWith(s,"BANK","IgnoreCase",true)
        break
    end
end

% --- numeric block: three columns until EOF
blk = textscan(fid, "%f%f%f", "CollectOutput", true);
M = blk{1};
if isempty(M) || size(M,2) ~= 3
    error('readFXYE:NoData','No 3-column numeric data after BANK in %s', inFile);
end

twoTheta_cdeg = M(:,1).';
data.two_theta = twoTheta_cdeg ./ 100;   % centi-deg -> deg
data.data_fit  = M(:,2).';
data.error     = M(:,3).';

% Optional metadata (store like your GUI expects)
if ~isnan(T_K),    data.temperature = T_K - 273.15; end
if ~isnan(lambda), data.wave        = lambda;       end
end

function data = readXYorXYE(~,filename)
%READXYORXYE Read a 2- or 3-column numeric text file (X Y or X Y E).
%   DATA = readXYorXYE(filename) returns a struct with fields:
%     two_theta  (row vector)  -> X
%     data_fit   (row vector)  -> Y
%     error      (row vector)  -> E (optional; [] if absent)
%
%   The file is assumed to contain numeric data only (no header).
%   Works with whitespace-, tab-, comma-, or semicolon-delimited files.

filename = string(filename);

% readmatrix is a good default for numeric text files. :contentReference[oaicite:2]{index=2}
A = readmatrix(filename);

% Drop completely empty rows (can happen with trailing blanks)
A = A(~all(isnan(A),2), :);

% Basic validation
if isempty(A) || size(A,2) < 2
    error("readXYorXYE:BadFormat", ...
        "File must contain at least 2 numeric columns (X Y): %s", filename);
end

% Keep only the first 3 columns (ignore extras)
A = A(:, 1:min(3,size(A,2)));

data = struct();
data.two_theta = A(:,1).';      % X
data.data_fit  = A(:,2).';      % Y

if size(A,2) >= 3
    data.error = A(:,3).';      % E
else
    data.error = [];            % optional
end

% A tiny sanity check: X should usually be monotone for scans (warn only)
dx = diff(data.two_theta);
if ~isempty(dx) && nnz(dx <= 0) > 0
    warning("readXYorXYE:NonMonotoneX", ...
        "X column is not strictly increasing in %s.", filename);
end
end


function data = parseXRDML(filename)
%PARSEXRDML reads an xml file with the extension .xrdml. If there are multiple scans in one file,
%this function assumes that the 2theta range is the same for all scans.



dom = xmlread(filename);

intensityElements = dom.getElementsByTagName('intensities');
ilen = textscan(char(intensityElements.item(0).getTextContent),'%f');
ilen = length(ilen{1});
intensity = zeros(intensityElements.getLength, ilen);
temperature = zeros(1,intensityElements.getLength);

for i=1:intensityElements.getLength 
    % Get the intensity values for each scan
    item = intensityElements.item(i-1);
    intensVal = textscan(char(item.getTextContent), '%f');
    intensity(i,:) = intensVal{1}';
    
    % Get the average temperature for each scan
    tempItem = dom.getElementsByTagName('nonAmbientPoints').item(0);
    if isempty(tempItem)
        temperature(i) = 25;
    else 
        temp = textscan(char(tempItem.getTextContent),'%f');
        temperature(i) = mean(temp{1}) - 273.15;
    end
end

% Get the two theta values for each intensity
listPosElement = dom.getElementsByTagName('listPositions').item(0);
if isempty(listPosElement)
    % Assuming the first item under the element 'positions' has the attribute '2Theta'
    scanType=dom.getElementsByTagName('scan').item(0).getAttribute('scanAxis');
    if  strcmp(scanType, 'Gonio') || strcmp(scanType, '2Theta') 
        pos2thetaElement = dom.getElementsByTagName('positions').item(0);
    elseif scanType=='2Theta-Omega' 
        pos2thetaElement = dom.getElementsByTagName('positions').item(0);
    elseif scanType=='Phi' 
        pos2thetaElement = dom.getElementsByTagName('positions').item(2);
    elseif scanType=='Chi' 
        pos2thetaElement = dom.getElementsByTagName('positions').item(3);
    else
        pos2thetaElement = dom.getElementsByTagName('positions').item(1);
    end
    startPosElement = pos2thetaElement.getElementsByTagName('startPosition').item(0);
    startPosValue = str2double(startPosElement.getTextContent);
    endPosElement = pos2thetaElement.getElementsByTagName('endPosition').item(0);
    endPosValue = str2double(endPosElement.getTextContent);
    step = (endPosValue - startPosValue) / (ilen-1);
    listPosValue = (startPosValue:step:endPosValue);
else
    listPosValue = textscan(char(listPosElement.getTextContent), '%f');
    listPosValue = listPosValue{1}';
end

twotheta = zeros(intensityElements.getLength,ilen);
for i=1:intensityElements.getLength
    twotheta(i,:) = listPosValue;
end
    
% Get KAlpha1, KAlpha2, kBeta, and RKa1Ka2
ka1 = str2double(dom.getElementsByTagName('kAlpha1').item(0).getTextContent);
ka2 = str2double(dom.getElementsByTagName('kAlpha2').item(0).getTextContent);
kbeta = str2double(dom.getElementsByTagName('kBeta').item(0).getTextContent);
ratio = str2double(dom.getElementsByTagName('ratioKAlpha2KAlpha1').item(0).getTextContent);

try 
    scanType; 
catch
    scanType=java.lang.String('Gonio');
end
% Save values into a struct
data = struct('KAlpha1',ka1,'KAlpha2',ka2,'kBeta',kbeta,'RKa1Ka2',ratio,'two_theta',twotheta,...
    'data_fit',intensity,'Temperature',temperature,'ext','','scanType',scanType);
end