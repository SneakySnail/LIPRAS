% Imports new data.
function [data, filename, datapath] = newDataSet(datapath, filename)
%   DATAPATH is the folder to initially open.
try
    PrefFile=fopen('Preference File.txt','r');
    data_path=fscanf(PrefFile,'%c');
    data_path(end)=[]; % method above adds a white space at the last character that messes with import
    fclose(PrefFile);
catch
    data_path=cd;
end

allowedFiles = {'*.csv; *.txt; *.xy; *.fxye; *.dat; *.xrdml; *.chi; *.spr'};
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
initializer = struct('two_theta',[],'data_fit',[],'KAlpha1',[],'KAlpha2',[],...
    'kBeta',[],'RKa1Ka2',[],'Temperature',[],'ext','');
data(length(filename)) = initializer;

% iterate through all files
for i=1:length(filename)
    fullFileName = strcat(path, filename{i});
    [~, ~, ext] = fileparts(fullFileName);
    fid = fopen(fullFileName, 'r');
    
    if strcmp(ext, '.csv')
        datatemp = readSpreadsheet(fullFileName);
    elseif strcmp(ext, '.txt')
        datatemp = readWithHeader(i,fullFileName);
    elseif strcmp(ext, '.xy')
        datatemp = readFile(fid, ext);
    elseif strcmp(ext, '.fxye')
        datatemp = readWithHeader(i,fullFileName);
    elseif strcmp(ext, '.chi')
        datatemp = readFile(fid, ext);
    elseif strcmp(ext, '.dat')
        datatemp = readFile(fid, ext);
    elseif strcmp(ext, '.xrdml')
        datatemp = parseXRDML(fullFileName);
    end
    
    data(i) = datatemp;
    data(i).ext = ext;
    
    fclose(fid);
end
end
% ==============================================================================

function data = readSpreadsheet(filename)
data = struct('two_theta',[],'data_fit',[],'KAlpha1',[],'KAlpha2',[],...
    'kBeta',[],'RKa1Ka2',[],'Temperature',[],'ext',ext);
temp = xlsread(filename);
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

% now takes the first two columns of intesity and 2-theta and transpose
temp = temp(:,1:2)';
data.two_theta = temp(1,:);
data.data_fit = temp(2,:);
end


function data = readFile(fid, ext)
data = struct('two_theta',[],'data_fit',[],'KAlpha1',[],'KAlpha2',[],...
    'kBeta',[],'RKa1Ka2',[],'Temperature',[], 'ext',ext);
if strcmp(ext, '.xy')
    temp = fscanf(fid,'%f',[2 ,inf]);
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
% ==============================================================================

function readWithHeader(Stro,fileIndex,inFile)
keyboard
%TODO: NOT IMPLEMENTED

fid = fopen(inFile,'r');
index = 0;
done = 0;
while done == 0
    line = fgetl(fid);
    a = strsplit(line, ' ');
    try
        if strcmp(a(2),'Temp')
            temp = sprintf('%s*', cell2mat(a(5)));
            Stro.temperature(fileIndex) = sscanf(temp, '%f*');
        end
        if strcmp(a(1), '')
            S = sprintf('%s*', cell2mat(a(2)));
        else
            S = sprintf('%s*', cell2mat(a(1)));
        end
        N = sscanf(S, '%f*');
        if isempty(N)
            
        elseif isa(N, 'double')
            done = 1;
        end
    catch
        
    end
    
    index = index + 1;
end
Stro.skiplines = index;
fid = fopen(inFile,'r');
Stro.readFile(fileIndex,fid)
end
% ==============================================================================

function data = parseXRDML(filename)
%PARSEXRDML reads an xml file with the extension .xrdml. If there are multiple scans in one file,
%this function assumes that the 2theta range is the same for all scans.

% data = utils.fileutils.parseXML(filename);
% for i = 1:length(data.Children)
%     if strcmp(data.Children(i).Name, 'xrdMeasurement')
%         xrdMeasurements = data.Children(i);
%         break
%     end
% end
% 
% for i=1:length(xrdMeasurements.Children)
%     if strcmp(xrdMeasurements.Children(i).Name, 'scan')
%         scans = xrdMeasurements.Children(i);
%         tth = 0;
%     elseif strcmp(xrdMeasurements.Children(i).Name, 'usedWavelength')
%         usedWavelength = xrdMeasurements.Children(i);
%     end
% end
% 
% for PosI = 1:length(scans.Children)
%     if strcmp(scans.Children(PosI).Name, 'dataPoints')
%         dataPoints = scans.Children(PosI);
%         for DataPointsi = 1:length(dataPoints.Children)
%             if strcmp(dataPoints.Children(1,DataPointsi).Name, 'positions')
%                 positions = dataPoints.Children(1,DataPointsi);
%                 if strcmp(positions.Attributes(1,1).Value, '2Theta')
%                     if strcmp(positions.Children(1,2).Name, 'listPositions')
%                         tth = strread(positions.Children(1,2).Children(1,1).Data,'%f');
%                     else
%                         ttho = strread(positions.Children(1,2).Children(1,1).Data,'%f'); % startPosition
%                         tthf = strread(positions.Children(1,4).Children(1,1).Data,'%f'); % endPosition
%                     end
%                 end
%             elseif strcmp(dataPoints.Children(1,DataPointsi).Name, 'intensities')
%                 intensity = strread(dataPoints.Children(1,DataPointsi).Children(1,1).Data,'%f');
%             end
%         end
%     elseif strcmp(scans.Children(PosI).Name, 'nonAmbientPoints')
%         temperature = mean(strread(dataPoints.Children(1,4).Children(1,1).Data,'%f'))-273.15; %#ok<*DSTRRD>
%     else
%         temperature = 25;
%     end
%     
% end
% if tth == 0
%     step = (tthf - ttho) / (length( intensity )-1);
%     tth = ttho:step:tthf;
%     tth = tth';
% end
% 
% % Reading Kalpha1, Kalpha2, Kbeta, and Ratio from XRDML
% % how to read XML, if the element is tabbed over twice,
% % you need two instances of Children to access it then
% % the Name, or Attribute. To read the value within it,
% % you will need another Children since it will be
% % tabbed over again.
% data.KAlpha1 = str2double(usedWavelength.Children(2).Children(1).Data);
% data.KAlpha2 = str2double(usedWavelength.Children(4).Children(1).Data);
% data.KBeta = str2double(usedWavelength.Children(6).Children(1).Data);
% data.RKa1Ka2 = str2double(usedWavelength.Children(8).Children(1).Data);
% data.two_theta = tth';
% data.data_fit = intensity';
% data.Temperature = temperature;


% =====
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
    pos2thetaElement = dom.getElementsByTagName('positions').item(0);
    startPosElement = pos2thetaElement.getElementsByTagName('startPosition').item(0);
    startPosValue = str2double(startPosElement.getTextContent);
    endPosElement = pos2thetaElement.getElementsByTagName('endPosition').item(0);
    endPosValue = str2double(endPosElement.getTextContent);
    step = (endPosValue - startPosValue) / (ilen-1);
    listPosValue = (startPosValue:step:endPosValue);
else
    listPosValue = textscan(char(listPosElement.getTextContext), '%f');
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

% Save values into a struct
data = struct('KAlpha1',ka1,'KAlpha2',ka2,'kBeta',kbeta,'RKa1Ka2',ratio,'two_theta',twotheta,...
    'data_fit',intensity,'Temperature',temperature,'ext','');
end