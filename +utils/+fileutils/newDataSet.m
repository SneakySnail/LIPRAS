%% newDataSet(handles, filename, path)
% Imports new data.
function [data, filename, path] = newDataSet(filename, path)
try
    PrefFile=fopen('Preference File.txt','r');
    data_path=fscanf(PrefFile,'%c');
    data_path(end)=[]; % method above adds a white space at the last character that messes with import
    fclose(PrefFile);
catch
    data_path=cd;
end


data = [];

if nargin < 1
    allowedFiles = {'*.csv; *.txt; *.xy; *.fxye; *.dat; *.xrdml; *.chi; *.spr'};
    title = 'Select Diffraction Pattern to Fit';
    [filename, path, ~] = uigetfile(allowedFiles, title, 'MultiSelect', 'on', data_path);
end
if nargin < 2
    path = [];
end


if ~isequal(filename, 0)
    data = readNewDataFile(filename, path);
        
else
    
end

end


function data = readNewDataFile(filename, path)
% DATA - First row is the 2theta, second row and above are the intensities

    if isa(filename,'char')
        filename = {filename};
    end
    
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
            datatemp = parseXRDML(handles.gui, i);
        end
        
        data.two_theta = datatemp(1, :);
        data.data_fit(i, :) = datatemp(2,:);
        
        fclose(fid);

    end
    
    


end
% ==============================================================================

function data = readSpreadsheet(filename)
data = xlsread(filename);
% Method for reading of data that does not start with numerial
% twotheta and intensity
cc=isnan(data(:,1)); % checks if any NaN were read in

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
data = data(p:end,:);

% now takes the first two columns of intesity and 2-theta and transpose
data = data(:,1:2)'; 
end


function data = readFile(fid, ext)

if strcmp(ext, '.xy')
    data = fscanf(fid,'%f',[2 ,inf]);
    
elseif strcmp( ext, '.fxye')
    data = fscanf(fid,'%f',[3 ,inf]);
    data(1,:) = data(1,:) ./ 100;
    
elseif strcmp( ext, '.chi')
    fgetl(fid);fgetl(fid);fgetl(fid);fgetl(fid);
    data = fscanf(fid,'%f',[2 ,inf]);
    
else
    data = fscanf(fid,'%f',[2 ,inf]);
end

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


function data = parseXRDML(gui, index)
% TODO - NOT IMPLEMENTED
keyboard
DataIndex = 1;
Data = {};
Data{1,1} = 0;
X = 0;
Z = 0;
fileIndex = 0;

fileNumb=index;
file = strcat(Stro.DataPath,Stro.Filename{fileNumb});
[parthstr,name,ext] = fileparts(file);
data = parseXML(file);
for i = 1:length(data.Children)
    if strcmp(data.Children(1,i).Name, 'xrdMeasurement')
        dataIndex = i;
    end
end

for i = 1:length(data.Children(1,dataIndex).Children)
    if strcmp(data.Children(1,dataIndex).Children(1,i).Name, 'scan')
        tth = 0;
        fileIndex = fileIndex + 1;
        scanIndex = i;
        
        
        for PosI = 1:length(data.Children(1,dataIndex).Children(1,scanIndex).Children)
            if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Name, 'dataPoints')
                for DataPointsi = 1:length(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children)
                    if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Name, 'positions')
                        if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Attributes(1,1).Value, '2Theta')
                            if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,2).Name, 'listPositions')
                                tth = strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,2).Children(1,1).Data,'%f');
                            else
                                ttho = strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,2).Children(1,1).Data,'%f');
                                tthf = strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,4).Children(1,1).Data,'%f');
                            end
                        end
                    end
                    if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Name, 'intensities')
                        intensity = strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,1).Data,'%f');
                    end
                end
            end
            if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Name, 'nonAmbientPoints')
                temperature(PosI,:) = mean(strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,4).Children(1,1).Data,'%f'))-273.15;
            else
                temperature(PosI,:) = 25;
            end
            
        end
        if tth == 0
            step = (tthf - ttho) / (length( intensity )-1);
            tth = ttho:step:tthf;
            tth = tth';
            if length(tth') ~= length( Data{DataIndex,1}(1,:))
                DataIndex = DataIndex + 1;
                Data{DataIndex,1} = 0;
                fileIndex = 1;
            end
        end
        
        
        
    end
    
end

% Reading Kalpha1, Kalpha2, Kbeta, and Ratio from XRDML
% how to read XML, if the element is tabbed over twice,
% you need two instances of Children to access it then
% the Name, or Attribute. To read the value within it,
% you will need another Children since it will be
% tabbed over again.
for p=1:scanIndex
    if strcmp(data.Children(1,dataIndex).Children(1,p).Name, 'usedWavelength')
        KAlpha1=data.Children(1,dataIndex).Children(1,4).Children(1,2).Children(1,1).Data;
        KAlpha2=data.Children(1,dataIndex).Children(1,4).Children(1,4).Children(1,1).Data;
        kBeta=data.Children(1,dataIndex).Children(1,4).Children(1,6).Children(1,1).Data;
        Ratio_alph1_alph2=data.Children(1,dataIndex).Children(1,4).Children(1,8).Children(1,1).Data;
        disp('1')
    end
    
end


Stro.KAlpha1(index,:)=str2double(KAlpha1);
Stro.KAlpha2(index,:)=str2double(KAlpha2);
Stro.KBeta(index,:)=str2double(kBeta);
Stro.RKa1Ka2(index,:)=str2double(Ratio_alph1_alph2);

Stro.two_theta = tth';
Stro.data_fit(index,:) = intensity';
if length(unique(temperature))==2
    temperature=unique(temperature);
    temperature=temperature(2);
else
    temperature=25;
end
Stro.Temperature(index,:) = temperature;
end