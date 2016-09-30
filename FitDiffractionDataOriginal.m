classdef FitDiffractionDataOriginal < handle
%classdef FitDiffractionDataOriginal < matlab.mixin.Copyable
    %   FitDiffractionDataOriginal Summary of this class goes here
    %   Detailed explanation goes here  
    properties
        Filename = '';
        symdata = 0;
        reduceData = 0;
        suffix   = '';
        azim = [0:15:345];
        binID = [1:1:24];
        bb 
        two_theta = [];
        originalData = [];
        data_fit = [];
        fit_parms = {};
        fit_parms_error = {};
        fit_results = {};
        fit_initial=[];
        original_SP=[];
        lambda = 1.5405980;
        inputSP= 'n';
        plotyn = 'y';
        saveyn = 'y';
        dEta = 0;
        level = 0.95;
        PolyOrder = 1;
        OutputPath = 'FitOutputs/';
        fitrange
        Min2T
        Max2T
        PSfxn
        Fdata
        Fmodel
        Fcoeff
        FmodelGOF
        FmodelCI
    end   
    properties(Hidden)
        SPR_Chi
        SPR_Angle
        SPR_Data
        numAzim
        bkgd2th
        fitRange
        PeakPositions
        skiplines = 0;
        Fit_Range
        File_Input = 'n'
        DataPath = '';
        DataAverage
        temperature_init
    end    
    
    
    methods
        function Stro = FitDiffractionDataOriginal(filename)
            
            ReadFile = 0;
            
            if nargin == 1;
                ReadFile = 1;
                pathName = '';
            else
                prompt = {'Do you want to read in the input fitting paramaters (Y/N):'};
                dlg_title = 'New Data Input';
                num_lines = 1;
                def = {'N'};
                new_input = newid(prompt,dlg_title,num_lines,def);
                if or(strcmp(new_input{1},'Y'), strcmp(new_input,'y'))
                    ReadFile = 1;
                end
            end

            if ReadFile
                
                Stro.File_Input = 'y';
                Stro.Read_Data
                Stro.Read_Inputs()
                
                Stro.fitData
            else
                Stro.Read_Data
            end
	end
        function Read_Inputs(Stro)
            [filename, pathName]  = uigetfile({'*.txt;','*.txt'},'Select Input File','MultiSelect', 'off');
            fid=fopen(strcat(pathName,filename),'r');
            
            % If the old entries have larger arrays than the new ones this
            % reset these variables so that the new entries are the only
            % entries and not the newly replaced+old
            
            Stro.PSfxn=[];
            Stro.bkgd2th=[];
            Stro.fitrange=[];
            Stro.PeakPositions=[];         
            Stro.original_SP=[];        
            Stro.fit_initial=[];
            
            while ~feof(fid)
                line=fgetl(fid);
                a=strsplit(line,' ');

                if strcmp(a(1),'2theta_fit_range:');
                    Stro.Min2T = str2double(a{2});
                    Stro.Max2T = str2double(a{3});
                elseif strcmp(a(1),'Background_order:');
                    Stro.PolyOrder= str2double(a{2});
                elseif strcmp(a(1),'Average_Data:');
                    Stro.DataAverage = str2double(a{2});
                    Stro.averageData(Stro.DataAverage)
                elseif strcmp(a(1),'SPR_Angle:');
                    Stro.SPR_Angle = str2double(a{2});
                elseif strcmp(a(1),'Background_points:');
                    for i=2:length(a);
                        Stro.bkgd2th(i-1)= str2double(a{i});
                    end
                elseif strcmp(a(1),'PeakPos:')
                    for i=2:length(a);
                        Stro.PeakPositions(i-1)= str2double(a{i});
                    end
                elseif strcmp(a(1),'fitrange:')
                    for i=2:length(a);
                        Stro.fitrange(i-1)= str2double(a{i});
                    end
                elseif strcmp(a(1),'Fxn:')
                    for i=2:length(a);
                        Stro.PSfxn{i-1}=a{i};
                    end
                elseif strcmp(a(1),'DataPath:');
                    Stro.DataPath = a(2);
                    Stro.DataPath = Stro.DataPath{1};
                elseif strcmp(a(1),'Files:')
                    for i=2:length(a);
                        Stro.Filename{i-1}=a{i};
                    end
                elseif strcmp(a(1),'Fit_Range');
                    for i=2:length(a);
                        Stro.Fit_Range(i-1)= str2double(a{i});
                    end      
                    
                end
            end
            
            %This is the section that enables the read in or originial and
            %fit_initial parameters from an input file
fid=fopen(strcat(pathName,filename),'r');            
data=textscan(fid,'%s %f %f','delimiter',',');
if strncmpi(data{1}(3),'SPR_Angle',9)
    s=9; r=12; % s and r define which rows to skip/use when reading in an input file, that has an SPR_Anlge defined, rows are shifted by 1 in these cases
else
    s=8;r=11; % for all cases when SPR_Angle is not defined
end              
sze=strsplit(cell2mat(data{1}(s)));
nsize=length(sze)-1;
data{1}(1:r)=[];

for i=1:nsize
result{1,i}=strsplit(cell2mat(data{1}(1)));
result{1,i}=result{1,i}(1,2:end); %reshape to take out SB:
result{2,i}=strsplit(cell2mat(data{1}(2)));
result{2,i}=result{2,i}(1,2:end);
result{3,i}=strsplit(cell2mat(data{1}(3)));
result{3,i}=result{3,i}(1,2:end);
data{1}(1:4)=[];
end
data{1}(1)=[];
for j=1:nsize
iresult{1,j}=strsplit(cell2mat(data{1}(1)));
dat=strsplit(cell2mat(data{1}(1)));
iresult{1,j}=iresult{1,j}(1,2:end);
iresult{2,j}=strsplit(cell2mat(data{1}(2)));
iresult{2,j}=iresult{2,j}(1,2:end);
iresult{3,j}=strsplit(cell2mat(data{1}(3)));
iresult{3,j}=iresult{3,j}(1,2:end);
data{1}(1:4)=[];
end

%Convert str to double for use in fitData
rsize=size(result);
for g=1:rsize(2)
    result{1,g}=cellfun(@str2double,result{1,g},'UniformOutput',false);
    result{2,g}=cellfun(@str2double,result{2,g},'UniformOutput',false);
    result{3,g}=cellfun(@str2double,result{3,g},'UniformOutput',false);
    iresult{1,g}=cellfun(@str2double,iresult{1,g},'UniformOutput',false);
    iresult{2,g}=cellfun(@str2double,iresult{2,g},'UniformOutput',false);
    iresult{3,g}=cellfun(@str2double,iresult{3,g},'UniformOutput',false);
end

for h=1:rsize(2)
    result{1,h}=cell2mat(result{1,h}(1,:));
    result{2,h}=cell2mat(result{2,h}(1,:));
    result{3,h}=cell2mat(result{3,h}(1,:));
    iresult{1,h}=cell2mat(iresult{1,h}(1,:));
    iresult{2,h}=cell2mat(iresult{2,h}(1,:));
    iresult{3,h}=cell2mat(iresult{3,h}(1,:));
end
            Stro.original_SP=result;
            Stro.fit_initial=iresult;
disp('WARNING: Not using manual input overrides')
disp('original and initial SP once you run fitData')
prompt='SWITCH TO MANUAL INPUT? ';
answer=input(prompt,'s');
A=strncmpi(answer,'y',1); %compares the asnwer inputed by the user 
C=strncmpi(answer,'1',1);
if A==1 %if it is (Yes, Y, or y)then...
Stro.inputSP='y';
elseif C==1
    Stro.inputSP='y';
end      
           
fclose(fid);
                    
        end
        function Read_Data(Stro)
            if isempty( Stro.Filename )
               [Stro.Filename, Stro.DataPath] = uigetfile({'*.csv;*.txt;*.xy;*.fxye;*.dat;*.xrdml;*.chi;*.spr','*.csv, *.txt, *.xy, *.fxye, *.dat, *.xrdml, *.chi, or *.spr'},'Select Diffraction Pattern to Fit','MultiSelect', 'on');
            else
                prompt = {'Do you want to input new data (Y/N):'};
                dlg_title = 'New Data Input';
                num_lines = 1;
                def = {'N'};
                new_input = newid(prompt,dlg_title,num_lines,def);
                
                if or(strcmp(new_input{1},'Y'), strcmp(new_input,'y'))
                    [Stro.Filename, Stro.DataPath] = uigetfile({'*.csv;*.txt;*.xy;*.fxye;*.dat;*.xrdml;*.chi;*.spr','*.csv, *.txt, *.xy, *.fxye, *.dat, *.xrdml, *.chi, or *.spr'},'Select Diffraction Pattern to Fit','MultiSelect', 'on');
                end
            end
 
            Stro.OutputPath = strcat(Stro.DataPath, '/FitOutputs/');
            
            if isa(Stro.Filename,'char')
                Stro.Filename = {Stro.Filename};
            end
            
            [path, baseline, ext] = fileparts( Stro.Filename{1} );
            if strcmp(ext,'.spr')
                Stro.parse2D
            else
                for i=1:length(Stro.Filename)
                    inFile = strcat(Stro.DataPath, Stro.Filename{i});
                    [path, baseline, ext] = fileparts( inFile );

                    if or(strcmp( ext, 'csv'),strcmp( ext, '.csv'))
                        Stro.suffix = 'csv';
                        fid = xlsread(inFile,'A:B');
                        Stro.readFile(i,fid);
                    elseif or(strcmp( ext, 'txt'),strcmp( ext, '.txt'))
                        Stro.suffix = 'txt';
                        fid = fopen(inFile, 'r');
                        Stro.readWithHeader(i,inFile);
                    elseif or(strcmp( ext, 'xy'),strcmp( ext, '.xy'))
                        Stro.suffix = 'xy';
                        fid = fopen(inFile, 'r');
                        Stro.readFile(i,fid);
                    elseif or(strcmp( ext, 'fxye'),strcmp( ext, '.fxye'))
                        Stro.suffix = 'fxye';
                        fid = fopen(inFile, 'r');
                        Stro.readWithHeader(i,inFile);
                    elseif or(strcmp( ext, 'chi'),strcmp( ext, '.chi'))
                        Stro.suffix = 'chi';
                        fid = fopen(inFile, 'r');
                        Stro.readFile(i,fid);
                    elseif or(strcmp( ext, 'dat'),strcmp( ext, '.dat'))
                        Stro.suffix = 'dat';
                        fid = fopen(inFile, 'r');
                        Stro.readFile(i,fid);
                    elseif or(strcmp( ext, 'xrdml'),strcmp( ext, '.xrdml'))
                        Stro.parseXRDML
                    end
                end
            end
            
            if isempty(Stro.Min2T)
                Stro.Min2T = min(Stro.two_theta);
                Stro.Max2T = max(Stro.two_theta);
            elseif strcmp(new_input,'y')
                Stro.Min2T = min(Stro.two_theta);
                Stro.Max2T = max(Stro.two_theta);
            end
            
            if ~strcmp(Stro.File_Input, 'y')
                Stro.Max2T
                Stro.setTwo_Theta_Range()
            end
            
            Stro.fit_parms=[];
            Stro.fit_parms_error=[];
            Stro.fit_results=[];
            Stro.fit_initial=[];
           
            
            
	end
        function ExtractTemp(Stro)
           
            fid=fopen(strcat(Stro.OutputPath,'FileID-Temperature.txt'),'w');
            fprintf(fid,'FileID \t Temp \t \n');
             
            
               for p=1:1:length(Stro.Filename)
                 inFile = strcat(Stro.DataPath, Stro.Filename{p});
                 filename=Stro.Filename{p};
                 [~, ~, ext] = fileparts( inFile );
                 
                    if or(strcmp( ext, 'fxye'),strcmp( ext, '.fxye'))
                  
                        
                openresults=fopen(inFile,'r');
                for j=1:10
                fgetl(openresults);
                end
                    results=textscan(openresults,'%s');%opens the file listed above and obtains data in all 5 columns
                    fclose(openresults); %closes file
                    Temp=char(results{1}(5));
                    fprintf(fid, '%s \t %s \t \n', filename, Temp);
               
               
                 
                     else
                error('Error: Your file is not a .fxye')
                     end 
                 
               end
             fclose(fid);

                Folder=strsplit(Stro.DataPath,'\');
                folder=Folder(1,length(Folder)-1);
                disp(char(strcat('Done with folder---','<',folder,'>')));
	end
        function parse2D(Stro)
            if isempty(Stro.SPR_Chi)
                 [file, path] = uigetfile({'*.chi','*.chi'},'Select Diffraction Chi File','MultiSelect', 'off');
                 Stro.SPR_Chi = strcat(path,file);
            end
            
%            for k = startImages:endImages
            for k = 1:length( Stro.Filename )
                %leading zeros (lZ)
               % if k<10, lZ=''; elseif k<100, lZ=''; else lZ=''; end;
               if k<10, lZ='00'; elseif k<100, lZ='0'; else lZ=''; end;

%                 filename = [basename, lZ, num2str(k), '.', Stro.suffix];
                filename = Stro.Filename{k};
                fprintf(1, '\nProcessing %s...', filename);

                % load data
                fid = fopen(strcat(Stro.DataPath,filename));
                i = 1; j = 1;
                while j ~= -1
                    A{i} = fgetl(fid);  
                    %FGETL Read line from file, discard newline character
                    %A{i} is intensities versus distance
                    j = A{i};
                    i = i + 1;
                end
                fclose(fid);

                data{k+1} = str2num(cat(1, A{2:end-1}));
                datamatrix(k+1,:,:) = str2num(cat(1, A{2:end-1}));

                numAzim = size(data{k+1}, 1);
                numBins = size(data{k+1}, 2);
            end
            fprintf(1,'\n');
            
            numAzim=24;
                        
            if Stro.symdata
                DifData = cat(3, 0.5 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,1,:)) + squeeze( datamatrix(2:length(Stro.Filename)+1,numAzim/2+1,:)) )/2);
                for i=2:numAzim/4
                    DifData = cat(3, DifData, 0.25 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/2+2-i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/2+i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim-i+2,:)) )/4);
                end
                DifData = cat(3, DifData, .5 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/4+1,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim * 3 / 4 + 1,:)) )/2);
            else
                DifData = cat(3, squeeze(datamatrix(2:length(Stro.Filename)+1,1,:)));
                for i=2:numAzim/4+1;
                    DifData = cat(3, DifData, squeeze(datamatrix(2:length(Stro.Filename)+1,i,:)));
                
                DifData = cat(3, DifData, squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/4+1,:)));
                end
            end
            
            Stro.numAzim = numAzim;
            Stro.SPR_Data = DifData;
            
%             if Stro.symdata
%                 Stro.data_alpha90= 0.5 * ( squeeze(datamatrix(:,1,:)) + squeeze( datamatrix(:,13,:)) );
%                 Stro.data_alpha75= 0.25 * ( squeeze(datamatrix(:,2,:)) + squeeze(datamatrix(:,12,:)) + squeeze(datamatrix(:,14,:)) + squeeze(datamatrix(:,24,:)) );
%                 Stro.data_alpha60= 0.25 * ( squeeze(datamatrix(:,3,:)) + squeeze(datamatrix(:,11,:)) + squeeze(datamatrix(:,15,:)) + squeeze(datamatrix(:,23,:)) );
%                 Stro.data_alpha45= 0.25 * ( squeeze(datamatrix(:,4,:)) + squeeze(datamatrix(:,10,:)) + squeeze(datamatrix(:,16,:)) + squeeze(datamatrix(:,22,:)) );
%                 Stro.data_alpha30= 0.25 * ( squeeze(datamatrix(:,5,:)) + squeeze(datamatrix(:,9,:)) + squeeze(datamatrix(:,17,:)) + squeeze(datamatrix(:,21,:)) );
%                 Stro.data_alpha15= 0.25 * ( squeeze(datamatrix(:,6,:)) + squeeze(datamatrix(:,8,:)) + squeeze(datamatrix(:,18,:)) + squeeze(datamatrix(:,20,:)) );
%                 Stro.data_alpha00= 1 * ( squeeze(datamatrix(:,7,:)) + squeeze(datamatrix(:,19,:)) );
%             else
%                 Stro.data_alpha90=squeeze(datamatrix(:,1,:));  %azi_increment=15degrees  %perpendicular direction wrt field
%                 Stro.data_alpha75=squeeze(datamatrix(:,2,:));
%                 Stro.data_alpha60=squeeze(datamatrix(:,3,:));
%                 Stro.data_alpha45=squeeze(datamatrix(:,4,:));
%                 Stro.data_alpha30=squeeze(datamatrix(:,5,:));
%                 Stro.data_alpha15=squeeze(datamatrix(:,6,:));
%                 Stro.data_alpha00=squeeze(datamatrix(:,7,:));
%             end
%             
%             Stro.data_alpha00 = Stro.data_alpha00(2:length(Stro.Filename)+1,:);
%             Stro.data_alpha15 = Stro.data_alpha15(2:length(Stro.Filename)+1,:);
%             Stro.data_alpha30 = Stro.data_alpha30(2:length(Stro.Filename)+1,:);
%             Stro.data_alpha45 = Stro.data_alpha45(2:length(Stro.Filename)+1,:);
%             Stro.data_alpha60 = Stro.data_alpha60(2:length(Stro.Filename)+1,:);
%             Stro.data_alpha75 = Stro.data_alpha75(2:length(Stro.Filename)+1,:);
%             Stro.data_alpha90 = Stro.data_alpha90(2:length(Stro.Filename)+1,:);
            
            fid = fopen(Stro.SPR_Chi, 'r');
            fgetl(fid);fgetl(fid);fgetl(fid);fgetl(fid);
            
            datain = fscanf(fid,'%f',[2 ,inf]);
            Stro.two_theta = datain(1,:);
            
            if isempty( Stro.SPR_Angle )
                Stro.setSPR_Angle()
            else
                Stro.setSPR_Angle( Stro.SPR_Angle )
            end
            
            fclose(fid);
            

%             if Stro.reduceData
%                 Stro.reduced_alpha00(1,:) = Stro.data_alpha00(9,:) ;
%                 Stro.reduced_alpha15(1,:) = Stro.data_alpha15(9,:) ;
%                 Stro.reduced_alpha30(1,:) = Stro.data_alpha30(9,:) ;
%                 Stro.reduced_alpha45(1,:) = Stro.data_alpha45(9,:) ;
%                 Stro.reduced_alpha60(1,:) = Stro.data_alpha60(9,:) ;
%                 Stro.reduced_alpha75(1,:) = Stro.data_alpha75(9,:) ;
%                 Stro.reduced_alpha90(1,:) = Stro.data_alpha90(9,:);
%                 Stro.reduced_alpha00(2,:) = Stro.data_alpha00(24,:) ;
%                 Stro.reduced_alpha15(2,:) = Stro.data_alpha15(24,:) ;
%                 Stro.reduced_alpha30(2,:) = Stro.data_alpha30(24,:) ;
%                 Stro.reduced_alpha45(2,:) = Stro.data_alpha45(24,:) ;
%                 Stro.reduced_alpha60(2,:) = Stro.data_alpha60(24,:) ;
%                 Stro.reduced_alpha75(2,:) = Stro.data_alpha75(24,:) ;
%                 Stro.reduced_alpha90(2,:) = Stro.data_alpha90(24,:) ;
% 
%                 for i=1:4
%                     Stro.reduced_alpha00(1,:) = Stro.reduced_alpha00(1,:) + Stro.data_alpha00(9+i,:);
%                     Stro.reduced_alpha15(1,:) = Stro.reduced_alpha15(1,:) + Stro.data_alpha15(9+i,:);
%                     Stro.reduced_alpha30(1,:) = Stro.reduced_alpha30(1,:) + Stro.data_alpha30(9+i,:);
%                     Stro.reduced_alpha45(1,:) = Stro.reduced_alpha45(1,:) + Stro.data_alpha45(9+i,:);
%                     Stro.reduced_alpha60(1,:) = Stro.reduced_alpha60(1,:) + Stro.data_alpha60(9+i,:);
%                     Stro.reduced_alpha75(1,:) = Stro.reduced_alpha75(1,:) + Stro.data_alpha75(9+i,:);
%                     Stro.reduced_alpha90(1,:) = Stro.reduced_alpha90(1,:) + Stro.data_alpha90(9+i,:);                
%                     Stro.reduced_alpha00(2,:) = Stro.reduced_alpha00(2,:) + Stro.data_alpha00(24+i,:);
%                     Stro.reduced_alpha15(2,:) = Stro.reduced_alpha15(2,:) + Stro.data_alpha15(24+i,:);
%                     Stro.reduced_alpha30(2,:) = Stro.reduced_alpha30(2,:) + Stro.data_alpha30(24+i,:);
%                     Stro.reduced_alpha45(2,:) = Stro.reduced_alpha45(2,:) + Stro.data_alpha45(24+i,:);
%                     Stro.reduced_alpha60(2,:) = Stro.reduced_alpha60(2,:) + Stro.data_alpha60(24+i,:);
%                     Stro.reduced_alpha75(2,:) = Stro.reduced_alpha75(2,:) + Stro.data_alpha75(24+i,:);                    
%                     Stro.reduced_alpha90(2,:) = Stro.reduced_alpha90(2,:) + Stro.data_alpha90(24+i,:);                
%                 end
% 
%                 Stro.reduced_alpha00 = 0.2 * Stro.reduced_alpha00;
%                 Stro.reduced_alpha90 = 0.2 * Stro.reduced_alpha90;
%                 Stro.data_fit = Stro.reduced_alpha90;
%             else
%                 Stro.data_fit = Stro.data_alpha00;
%             end
            
        end
        function parseXRDML(Stro)

            Stro.suffix = 'xrdml';
            
            DataIndex = 1;
            Data = {};
            Data{1,1} = 0;
            X = 0;
            Z = 0;
            fileIndex = 0;

            for fileNumb = 1:length(Stro.Filename)
                file = Stro.Filename{fileNumb};
                [parthstr,name,ext] = fileparts(file);
                if strcmp(ext, char('.xrdml'))
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
                                    temperature = mean(strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,4).Children(1,1).Data,'%f'))-273.15;   
                                else
                                    temperature = 25;
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
                            if Data{DataIndex,1} == 0
                                Data{DataIndex,1} = cat(Data{DataIndex,1},tth');
                                Data{DataIndex,2}(1:length(tth)) = temperature;
                                Data{DataIndex,3} = intensity';
                            else
                                Data{DataIndex,1}(fileIndex,:) = tth';
                                Data{DataIndex,2}(fileIndex,:) = temperature;
                                Data{DataIndex,3}(fileIndex,:) = intensity';
                            end
                        end     
                    end
                end
            end

            for k = 2:DataIndex
                X = Data{k,1};
                Y = Data{k,2};
                Z = Data{k,3};
                numScans = size(X);
                numScans = numScans(1);
                for i = 1:numScans
                    for j = i:numScans
                        if Y(j,1) < Y(i,1)
                            swapZ = Z(j,:);
                            swapY = Y(j,:);                
                            Y(j,:) = Y(i,:);
                            Z(j,:) = Z(i,:);           
                            Y(i,:) = swapY;
                            Z(i,:) = swapZ;
                        end                
                    end
                end
                Data{k,1} = X;
                Data{k,2} = Y;
                Data{k,3} = Z;
            end
               
            Stro.two_theta = Data{2,1}(1,:);
            Stro.data_fit = Data{2:DataIndex,3};
            Stro.temperature = Data{2:DataIndex,2}(:,1);
        end
        function fitData(Stro, position, PSfxn, fitrange)
            
          
            
            Stro.getBackground()

            if or(nargin == 2, nargin == 4)
                Stro.PeakPositions = position;
                Stro.PSfxn = PSfxn;
            end

            datainMin = FitDiffractionDataOriginal.Find2theta(Stro.two_theta,Stro.Min2T);
            datainMax = FitDiffractionDataOriginal.Find2theta(Stro.two_theta,Stro.Max2T);

            data = Stro.data_fit(:,datainMin:datainMax); %Extract relevant 2theta region    
            TwT = Stro.two_theta(datainMin:datainMax); %Extract relevant 2theta region    

            
            %create arbitrary axis for plotting of data
            arb = 1:1:size(Stro.data_fit,1); %change Stro.data_fit to any number of patterns you want to fit
%             arb=1:1:2; disp('fitting a limited amount of data line#~600')
          
            [TwTgrid,Arbgrid]=meshgrid(TwT,arb);

            TwTgridsum=TwT; 
            Arbgridsum=arb;
            datasum=data; 
            
            if or(nargin == 2, nargin ==4)
                fitrange2T = fitrange;
                Stro.fitrange = fitrange;
            elseif ~isempty(Stro.fitrange)
                fitrange2T = Stro.fitrange;
            else
                fitrange2T = .3*ones(1,length(Stro.PeakPositions));
                Stro.fitrange = fitrange2T;
            end
            
            for i=1:size(Arbgridsum,2) %this is the start of the for loop that executes the remainder of the 
                fprintf(1, 'Fitting Dataset %i of %i...\n', i,size(Arbgridsum,2)); 
                
            %this is the primary function
                if length(Stro.PSfxn)==length(Stro.PeakPositions) && length(Stro.PSfxn)==length(fitrange2T)
                      %only executes if the length of the inputs are self consistent
                       
                    datasent = [TwT' datasum(i,:)']';
                    
                    for ii=1:length(Stro.PeakPositions) %Change to number of steps (instead of 2theta)
                        fitrangeL = FitDiffractionDataOriginal.Find2theta(datasent(1,:),Stro.PeakPositions(ii)-fitrange2T(ii)/2);
                        fitrangeH = FitDiffractionDataOriginal.Find2theta(datasent(1,:),Stro.PeakPositions(ii)+fitrange2T(ii)/2);
                        drangeH = fitrangeH-FitDiffractionDataOriginal.Find2theta(datasent(1,:),Stro.PeakPositions(ii));
                        drangeL = FitDiffractionDataOriginal.Find2theta(datasent(1,:),Stro.PeakPositions(ii))-fitrangeL;
                        if drangeL > drangeH
                            fitrange(ii) = drangeH * 2;                                                 
                        elseif drangeH > drangeL
                            fitrange(ii) = drangeL * 2;                          
                        else
                            fitrange(ii) = fitrangeH-fitrangeL;                            
                        end
                    end

                    % assign default starting, UBound, and LBound values if not already defined
                    % values of zero in every position indicates that default values will be
                    % uploaded later from the MakeFxn command
                    if exist('SP')~=1; for k=1:length(Stro.PeakPositions); SP{k}=zeros(1,length(Stro.PeakPositions)); end; end
                    if exist('UB')~=1; for k=1:length(Stro.PeakPositions); UB{k}=zeros(1,length(Stro.PeakPositions)); end; end
                    if exist('LB')~=1; for k=1:length(Stro.PeakPositions); LB{k}=zeros(1,length(Stro.PeakPositions)); end; end

                    %The most important part...
%                     [Fdata,Fmodel,Fcoeff,FmodelGOF,FmodelCI] = ...
%                         fitXRDdata(plotyn, datasent, bkgd2th, PolyOrder, position, fitrange, PSfxn, SP, LB, UB);
if  Stro.inputSP=='y'
                        SP=Stro.fit_initial(1,:);
                        UB=Stro.fit_initial(2,:);
                        LB=Stro.fit_initial(3,:);
                    
end
                    Stro.fitXRD( datasent, Stro.PeakPositions, fitrange, SP, LB, UB);

                    if isa(Stro.Filename,'char')
                        [path, filename, ext] = fileparts( Stro.Filename );
                    elseif length(Stro.Filename) == 1
                        [path, filename, ext] = fileparts( Stro.Filename{1} );
                    else
                        [path, filename, ext] = fileparts( Stro.Filename{i} );
                    end
                    
                    clear path ext

                    if strcmp(Stro.saveyn,'y')
                        for m=1:length(Stro.PeakPositions)
                            fitOutputPath = strcat(Stro.OutputPath,'FitData/');
                            if ~exist(fitOutputPath,'dir')
                                mkdir(fitOutputPath);
                            end
                            Stro.SaveFitData(strcat(fitOutputPath,filename,'.',num2str(arb(i)),'.Fdata'),Stro.Fdata);

                            Stro.SaveFitValues(strcat(fitOutputPath,filename,'.',num2str(arb(i)),'.Fmodel'),Stro.PSfxn,Stro.Fmodel,Stro.Fcoeff,Stro.FmodelGOF,Stro.FmodelCI);
                            if isempty(Stro.SPR_Angle)
                                filetosave=strcat(fitOutputPath,Stro.Filename{1},'Master','_peak',num2str(m),'.Fmodel');
                            else
                                filetosave=strcat(fitOutputPath,Stro.Filename{1},'_Angle_',num2str(Stro.SPR_Angle),'_Master','_peak',num2str(m),'.Fmodel');
                            end
                            if i==1  %only if first file to open (master loop); print file header
                                fid = fopen(filetosave,'w');
                                fprintf(fid, 'This is an output file from a MATLAB routine.\n');
                                fprintf(fid, strcat('The following peaks are all of the type:', Stro.PSfxn{m}, '\n'));
                                for j=1:length(Stro.Fcoeff{m});
                                    fprintf(fid, '%s\t', char(Stro.Fcoeff{m}(j))); %write coefficient names
                                end
                                fprintf(fid, 'sse \t rsquare \t dfe \t adjrsquare \t rmse \t'); %write GOF names
                                for j=1:size(Stro.FmodelCI{m},2)
                                    fprintf(fid, '%s\t', strcat('LowCI:',char(Stro.Fcoeff{m}(j)))); %write LB names
                                    fprintf(fid, '%s\t', strcat('UppCI:',char(Stro.Fcoeff{m}(j)))); %write UB names
                                end
                                fprintf(fid, '\n');
                                fclose(fid);
                            end
                            fid = fopen(filetosave,'a');
                            for j=1:length(Stro.Fcoeff{m});
                                fprintf(fid, '%f\t', Stro.Fmodel{m}.(Stro.Fcoeff{m}(j))); %write coefficient values
                            end
                            GOFoutputs=[Stro.FmodelGOF{m}.sse Stro.FmodelGOF{m}.rsquare Stro.FmodelGOF{m}.dfe Stro.FmodelGOF{m}.adjrsquare Stro.FmodelGOF{m}.rmse];
                            fprintf(fid, '%f\t%f\t%f\t%f\t%f\t',GOFoutputs); %write GOF values
                            for j=1:size(Stro.FmodelCI{m},2)
                                fprintf(fid, '%f\t', Stro.FmodelCI{m}(1,j)); %write lower bound values
                                fprintf(fid, '%f\t', Stro.FmodelCI{m}(2,j)); %write upper bound values
                            end
                            fprintf(fid, '\n');
                            fclose(fid);
                        end
                    end

                    % Plot final fit data, measured data, and error bars
                    if strcmp(Stro.plotyn,'y')
                        fig2 =  figure(2);
                        ax1 =  subplot('Position',[0.1 0.35 0.8 0.6]);
                        plot(Stro.Fdata(1,:),Stro.Fdata(2,:),'g+',Stro.Fdata(1,:),sum(Stro.Fdata(3:size(Stro.Fdata,1),:),1),'k-');
                        ax2 = subplot('Position',[0.1 0.1 0.8 0.2]); %plot error 
                        plot(Stro.Fdata(1,:),Stro.Fdata(2,:)-sum(Stro.Fdata(3:size(Stro.Fdata,1),:),1),'k-');
                        linkaxes( [ax1 ax2], 'x' );

                        for n=1:length(Stro.PeakPositions)
                            fitdata_rsquare(n)=Stro.FmodelGOF{n}.rsquare;
                        end

                        fig3 = figure(3);
                        plot(Stro.PeakPositions,fitdata_rsquare,'+')
                        xlabel('2theta')
                        ylabel('R^2 (for each peak)')
                        
                        fitOutputPath = strcat(Stro.OutputPath,'Fit_Figure/');
                        if ~exist(fitOutputPath,'dir')
                            mkdir(fitOutputPath);
                        end
                        
%                         saveas(figure(1),strcat(fitOutputPath,strcat(filename,'_',num2str(arb(i))),'_fig1'),'fig')
%                         saveas(fig2,strcat(fitOutputPath,strcat(filename,'_',num2str(arb(i))),'_fig2'),'fig')
%                         saveas(fig3,strcat(fitOutputPath,strcat(filename,'_',num2str(arb(i))),'_fig3'),'fig')

                    end

                else  %else statement for primary function
                    error('Number of inputs are not consistent. Program not executed')
                end   %end of if fxn executing primary program
                
               
                temp = [];
                temp2 = [];
                for iii = 1:length(Stro.Fmodel)
                    temp3 = coeffvalues( Stro.Fmodel{iii} );
                    for jjj =1:length( temp3 )
                        temp(iii,jjj) = temp3(jjj);
                        temp2(iii,jjj) = 0.5 * (Stro.FmodelCI{iii}(2,jjj) - Stro.FmodelCI{iii}(1,jjj) );
                    end
                end

                Stro.fit_parms{i} = temp;
                Stro.fit_parms_error{i} = temp2;
                Stro.fit_results{i} = Stro.Fdata;
                Stro.fitRange = fitrange;
                
            end
        end
        function plotData(Stro,dataSet)
            close
            x = Stro.two_theta;
            intensity = Stro.data_fit(dataSet,:);
            
            yaxisH=max(intensity(find(x>= Stro.Min2T,1):find(x>= Stro.Max2T,1)))+200;
            yaxisL=min(intensity(find(x>= Stro.Min2T,1):find(x>= Stro.Max2T,1)))-200;

            Stro.constructFigure(5,'2\theta (\circC)','Intensity (a.u.)',strcat('Dataset-',num2str(dataSet)));

            plot(x,intensity,'-kx','LineWidth',1,'MarkerSize',15); 
            %Jacob temporarily put in the following line to fix background
            %fitting plot
%             axis([0 5.5 yaxisL yaxisH])
            
            xlim([Stro.Min2T, Stro.Max2T])
            
        end
        function plotFit(Stro,dataSet)
            try
                close(5)
            catch
            end
            
            if strcmp(dataSet,'all')
                dataSet0 = 1;
                dataSetf = size(Stro.fit_results,2);
                figure(5)
            else
                dataSet0 = dataSet;
                dataSetf = dataSet;
                Stro.constructFigure(5,'2\theta (\circ)','Intensity (a.u.)',strcat('Fit of dataset ',num2str(dataSet)));
            end
            

            
            for j=dataSet0:dataSetf
                if strcmp(dataSet,'all')
                    ax(j) = subplot(floor(sqrt(size(Stro.fit_results,2))),ceil(size(Stro.fit_results,2)/floor(sqrt(size(Stro.fit_results,2)))),j);
                    hold on
                end
                x = Stro.fit_results{j}(1,:)';
                intensity = Stro.fit_results{j}(2,:)';
                back = Stro.fit_results{j}(3,:)';
                fittedPattern = back;
                for i=1:length(Stro.PSfxn)
                    fittedPattern = fittedPattern + Stro.fit_results{j}(3+i,:)';
                end
                data(1) = plot(x,intensity,'kx','LineWidth',1,'MarkerSize',15);
                data(2) = plot(x,fittedPattern,'k','LineWidth',1.2);
                data(3) = plot(x, intensity - fittedPattern, 'r','LineWidth',1.2);
                data(4)= plot(x, back, '--b', 'LineWidth',1);

            
                for i=1:length(Stro.PSfxn)
                    
                    if strcmp( Stro.PSfxn{i}, 'GaussDoublet' )

                        temp = num2cell( Stro.fit_parms{j}(i,1:6));
                        [N1,x1,f1,N2,x2,f2] = deal( temp{:} );                
                        peak_1 = N1.*((2.*sqrt(log(2)))./(sqrt(pi).*f1).*exp(-4.*log(2).*((x-x1).^2./f1.^2)));
                        peak_2 = N2.*((2.*sqrt(log(2)))./(sqrt(pi).*f2).*exp(-4.*log(2).*((x-x2).^2./f2.^2)));
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)

                    end
                    
                    
%                     if strcmp( Stro.PSfxn{i}, 'Gauss' )
% 
%                         temp = num2cell( Stro.fit_parms{j}(i,1:3));
%                         [N1,x1,f1] = deal( temp{:} );                
%                         peak_1 = N1.*((2.*sqrt(log(2)))./(sqrt(pi).*f1).*exp(-4.*log(2).*((x-x1).^2./f1.^2)));
%                         plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
% 
%                     end
                    
                    if or(strcmp( Stro.PSfxn{i}, 'GaussTriplet' ),strcmp( Stro.PSfxn{i}, 'GaussTriplet_aspRatio' ))

                        temp = num2cell( Stro.fit_parms{j}(i,1:9));
                        [N1,x1,f1,N2,x2,f2,N3,x3,f3] = deal( temp{:} );                
                        peak_1 = N1.*((2.*sqrt(log(2)))./(sqrt(pi).*f1).*exp(-4.*log(2).*((x-x1).^2./f1.^2)));
                        peak_2 = N2.*((2.*sqrt(log(2)))./(sqrt(pi).*f2).*exp(-4.*log(2).*((x-x2).^2./f2.^2)));
                        peak_3 = N3.*((2.*sqrt(log(2)))./(sqrt(pi).*f3).*exp(-4.*log(2).*((x-x3).^2./f3.^2)));
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                        plot(x,peak_3+back, '--b', 'LineWidth', 1.2)
                    end
                   
               if strcmp( Stro.PSfxn{i}, 'GaussQuad' )
                   disp('test')
                    temp = num2cell( Stro.fit_parms{j}(i,1:12));
                    [N1,x1,f1,N2,x2,f2,N3,x3,f3,N4,x4,f4] = deal( temp{:} );          
                    peak_1 = N1.*((2.*sqrt(log(2)))./(sqrt(pi).*f1).*exp(-4.*log(2).*((x-x1).^2./f1.^2)));
                    peak_2 = N2.*((2.*sqrt(log(2)))./(sqrt(pi).*f2).*exp(-4.*log(2).*((x-x2).^2./f2.^2)));
                    peak_3 = N3.*((2.*sqrt(log(2)))./(sqrt(pi).*f3).*exp(-4.*log(2).*((x-x3).^2./f3.^2)));
                    peak_4 = N4.*((2.*sqrt(log(2)))./(sqrt(pi).*f4).*exp(-4.*log(2).*((x-x4).^2./f4.^2)));
                    plot(x,peak_1+back,x,peak_2+back,x,peak_3+back,x,peak_4+back,'LineWidth',1.2)
               elseif strcmp( Stro.PSfxn{i}, 'GaussTripletConstrain_Custom_f' )
                    temp = num2cell( Stro.fit_parms{j}(i,1:8));
                    [N1,x1,f1,N2,x2,f2,N3,x3] = deal( temp{:} );          
                    peak_1 = N1.*((2.*sqrt(log(2)))./(sqrt(pi).*f1).*exp(-4.*log(2).*((x-x1).^2./f1.^2)));
                    peak_2 = N2.*((2.*sqrt(log(2)))./(sqrt(pi).*f2).*exp(-4.*log(2).*((x-x2).^2./f2.^2)));
                    peak_3 = N3.*((2.*sqrt(log(2)))./(sqrt(pi).*f2).*exp(-4.*log(2).*((x-x3).^2./f2.^2)));
                    plot(x,peak_1+back,x,peak_2+back,x,peak_3+back,'LineWidth',1.2)               
               
               end
               
                if strcmp(Stro.PSfxn{i},'PVIIDoubletConstrain_f')
                        temp = num2cell( Stro.fit_parms{j}(i,1:7) );                            
                        [N1,x1,f,m1,N2,x2,m2]  = deal( temp{:} );
                         peak_1= N1 * 2 * ((2.^(1./m1)-1).^0.5) ./ f ./ (pi.^0.5) * gamma(m1) ./ gamma(m1-0.5) * (1+4*(2.^(1./m1)-1)*((x-x1).^2)./f.^2).^(-m1);
                         peak_2= N2 * 2 * ((2.^(1./m2)-1).^0.5) ./ f ./ (pi.^0.5) * gamma(m2) ./ gamma(m2-0.5) * (1+4*(2.^(1./m2)-1)*((x-x2).^2)./f.^2).^(-m2);
                          plot(x,peak_1+back,x,peak_2+back,'LineWidth',1.2);
                end
               
               
                if strcmp( Stro.PSfxn{i}, 'GaussQuadConstrain_f' )
                   
                    temp = num2cell( Stro.fit_parms{j}(i,1:10));
                    [N1,x1,f1,N2,x2,f,N3,x3,N4,x4] = deal( temp{:} );          
                    peak_1 = N1.*((2.*sqrt(log(2)))./(sqrt(pi).*f1).*exp(-4.*log(2).*((x-x1).^2./f1.^2)));
                    peak_2 = N2.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-x2).^2./f.^2)));
                    peak_3 = N3.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-x3).^2./f.^2)));
                    peak_4 = N4.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-x4).^2./f.^2)));
                    plot(x,peak_1+back,x,peak_2+back,x,peak_3+back,x,peak_4+back,'LineWidth',1.2)
                    disp('1st peak not constrain to others')
                
                elseif strcmp( Stro.PSfxn{i}, 'PsuedoVoigtQuadtuplet' )
                    
                        temp=num2cell(Stro.fit_parms{j}(i,1:16));
                        [N,x0,c,w,N1,x1,c1,w1,N2,x2,c2,w2,N3,x3,c3,w3]=deal(temp{:});
                        peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                        peak_2 = w1.*N1/c1.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c1).^2) + (1-w1).*N1/c1.*2/pi.*(1+4.*((x-x1)/c1).^2).^-1;
                        peak_3 = w2.*N2/c2.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x2)/c2).^2) + (1-w2).*N2/c2.*2/pi.*(1+4.*((x-x2)/c2).^2).^-1;
                        peak_4 = w3.*N3/c3.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x3)/c3).^2) + (1-w3).*N3/c3.*2/pi.*(1+4.*((x-x3)/c3).^2).^-1;
                        
                        plot(x,peak_1+back,x,peak_2+back,x,peak_3+back,x,peak_4+back)
                
                
                
                end           
               
                if strcmp(Stro.PSfxn{i},'PsuedoVoigtGaussTripletConstrain_w')
                temp = num2cell( Stro.fit_parms{j}(i,1:10));
                [N1,x1,f1,N2,x2,f2,w,N3,x3,f3] = deal( temp{:} );    
                
                peak_1=N1*((2*sqrt(log(2)))./(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1).^2./f1.^2)));
                peak_2=w*N2./f2*(2*(log(2)).^.5)./pi.^.5*exp(-4*log(2)*((x-x2)./f2).^2) + (1-w)*N2./f2*2./pi*(1+4*((x-x2)./f2).^2).^-1;
                peak_3=w*N3./f3*(2*(log(2)).^.5)./pi.^.5*exp(-4*log(2)*((x-x3)./f3).^2) + (1-w)*N3./f3*2./pi*(1+4*((x-x3)./f3).^2).^-1;
                
                        plot(x,peak_1+back, 'g', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)   
                        plot(x,peak_3+back, '--b', 'LineWidth', 1.2)
                
                end
                

                    if strcmp( Stro.PSfxn{i}, 'asymmPVIIDoubletPsuedoVoigt' )
  
                        temp = num2cell( Stro.fit_parms{j}(i,1:16));                                         
                        [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,m2L,F2L,I2R,m2R,N1,x1,f1,w1]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L*FitDiffractionDataOriginal.C4(m1L)./F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L*FitDiffractionDataOriginal.C4(m2L)./F2L.*(1+4.*(2.^(1/m2L)-1).*(x-x02).^2/F2L.^2).^(-m2L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m2R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).*(1+4.*(2.^(1/m2R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).^2).^(-m2R);                                        
                        peak_3=N1.*((w1.*(2./pi).*(1./f1).*1./(1+(4.*(x-x1).^2./f1.^2))) + ((1-w1).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f1.*exp(-log(2).*4.*(x-x1).^2./f1.^2)));
                                                
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)   
                        plot(x,peak_3+back, '--b', 'LineWidth', 1.2)
                        
                        
                        
                    elseif strcmp( Stro.PSfxn{i}, 'asymmPVIIPsuedoVoigt' )
  
                        temp = num2cell( Stro.fit_parms{j}(i,1:10));                                         
                        [x01,I1L,m1L,F1L,I1R,m1R,N1,x1,f1,w1]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L*FitDiffractionDataOriginal.C4(m1L)./F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        peak_2=N1.*((w1.*(2./pi).*(1./f1).*1./(1+(4.*(x-x1).^2./f1.^2))) + ((1-w1).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f1.*exp(-log(2).*4.*(x-x1).^2./f1.^2)));
                                                
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)   
                    
                    elseif strcmp( Stro.PSfxn{i}, 'asymmPVIIDoubletConstrain_m' )
  
                        temp = num2cell( Stro.fit_parms{j}(i,1:10));                                         
                        [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,F2L, I2R]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L*FitDiffractionDataOriginal.C4(m1L)./F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L*FitDiffractionDataOriginal.C4(m1L)./F2L.*(1+4.*(2.^(1/m1L)-1).*(x-x02).^2/F2L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m1R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);                                        
                                                
                        plot(x,peak_1+back, 'r', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)                       
     
                    end
                    
                    if strcmp( Stro.PSfxn{i}, 'asymmPVIIDoubletPsuedoVoigtConstrain_m' )
  
                        temp = num2cell( Stro.fit_parms{j}(i,1:14));                                         
                        [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,F2L,I2R,N1,x1,f1,w1]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L*FitDiffractionDataOriginal.C4(m1L)./F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L*FitDiffractionDataOriginal.C4(m1L)./F2L.*(1+4.*(2.^(1/m1L)-1).*(x-x02).^2/F2L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m1R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);                                        
                        peak_3=N1.*((w1.*(2./pi).*(1./f1).*1./(1+(4.*(x-x1).^2./f1.^2))) + ((1-w1).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f1.*exp(-log(2).*4.*(x-x1).^2./f1.^2)));
                                                
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)   
                        plot(x,peak_3+back, '--b', 'LineWidth', 1.2)  
                    end
                    
                if strcmp(Stro.PSfxn{i},'PsuedoVoigtTripletConstrain_Custom_w')
                        temp = num2cell( Stro.fit_parms{j}(i,1:11));
                        [N1,x1,f1,w1,N2,x2,f2,w2,N3,x3,f3] = deal( temp{:} );   
                        peak_1=w1.*N1./f1*(2*(log(2)).^.5)./pi.^.5*exp(-4*log(2)*((x-x1)./f1).^2) + (1-w1)*N1./f1*2./pi*(1+4*((x-x1)./f1).^2).^-1;
                        peak_2=w2*N2./f2*(2*(log(2)).^.5)./pi.^.5*exp(-4*log(2)*((x-x2)./f2).^2) + (1-w2)*N2./f2*2./pi*(1+4*((x-x2)./f2).^2).^-1;
                        peak_3=w2*N3./f3*(2*(log(2)).^.5)./pi.^.5*exp(-4*log(2)*((x-x3)./f3).^2) + (1-w2)*N3./f3*2./pi*(1+4*((x-x3)./f3).^2).^-1;
                        
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)   
                        plot(x,peak_3+back, '--b', 'LineWidth', 1.2) 
                
                end
                
                
                    if strcmp( Stro.PSfxn{i}, 'PsuedoVoigtDoubletConstrain_f')
                        temp = num2cell( Stro.fit_parms{j}(i,1:7));
                        [N1,x1,f,w1,N2,x2,w2] = deal( temp{:} );                                                                     
                        peak_1=w1.*N1./f.*(2.*(log(2))^.5)./pi^.5*exp(-4*log(2).*((x-x1)./f).^2) + (1-w1).*N1./f.*2/pi*(1+4.*((x-x1)./f).^2).^-1;
                        peak_2=w2.*N2./f.*(2.*(log(2))^.5)./pi^.5*exp(-4*log(2).*((x-x2)./f).^2) + (1-w2).*N2./f.*2/pi*(1+4.*((x-x2)./f).^2).^-1;
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)                   
                    end
                    
                    if strcmp(Stro.PSfxn{i},'PsuedoVoigtDoubletConstrain_f_w')
                         temp = num2cell( Stro.fit_parms{j}(i,1:6));
                        [N1,x1,f,w1,N2,x2,] = deal( temp{:} );   
                        peak_1=w1.*N1./f.*(2.*(log(2))^.5)./pi^.5*exp(-4*log(2).*((x-x1)./f).^2) + (1-w1).*N1./f.*2/pi*(1+4.*((x-x1)./f).^2).^-1;
                        peak_2=w1.*N2./f.*(2.*(log(2))^.5)./pi^.5*exp(-4*log(2).*((x-x2)./f).^2) + (1-w1).*N2./f.*2/pi*(1+4.*((x-x2)./f).^2).^-1;
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)                   
                    end
                    
                    
                  
                    if strcmp( Stro.PSfxn{i}, 'PsuedoVoigtSixtuplet')
                        temp = num2cell( Stro.fit_parms{j}(i,1:24));
                        [N1,x1,f1,w1,N2,x2,f2,w2,N3,x3,f3,w3,N4,x4,f4,w4,N5,x5,f5,w5,N6,x6,f6,w6]= deal( temp{:} );  
               peak_1(:,j)=w1.*N1./f1.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x1)./f1).^2) + (1-w1).*N1./f1.*2./pi.*(1+4.*((x-x1)./f1).^2).^-1; 
               peak_2(:,j)=w2.*N2./f2.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x2)./f2).^2) + (1-w2).*N2./f2.*2./pi.*(1+4.*((x-x2)./f2).^2).^-1;
               peak_3(:,j)=w3.*N3./f3.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x3)./f3).^2) + (1-w3).*N3./f3.*2./pi.*(1+4.*((x-x3)./f3).^2).^-1;
               peak_4(:,j)=w4.*N4./f4.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x4)./f4).^2) + (1-w4).*N4./f4.*2./pi.*(1+4.*((x-x4)./f4).^2).^-1; 
               peak_5(:,j)=w5.*N5./f5.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x5)./f5).^2) + (1-w5).*N5./f5.*2./pi.*(1+4.*((x-x5)./f5).^2).^-1; 
               peak_6(:,j)=w6.*N6./f6.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x6)./f6).^2) + (1-w6).*N6./f6.*2./pi.*(1+4.*((x-x6)./f6).^2).^-1;
%               % for not extracting intensities
%                peak_1=w1.*N1./f1.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x1)./f1).^2) + (1-w1).*N1./f1.*2./pi.*(1+4.*((x-x1)./f1).^2).^-1; 
%                peak_2=w2.*N2./f2.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x2)./f2).^2) + (1-w2).*N2./f2.*2./pi.*(1+4.*((x-x2)./f2).^2).^-1;
%                peak_3=w3.*N3./f3.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x3)./f3).^2) + (1-w3).*N3./f3.*2./pi.*(1+4.*((x-x3)./f3).^2).^-1;
%                peak_4=w4.*N4./f4.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x4)./f4).^2) + (1-w4).*N4./f4.*2./pi.*(1+4.*((x-x4)./f4).^2).^-1; 
%                peak_5=w5.*N5./f5.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x5)./f5).^2) + (1-w5).*N5./f5.*2./pi.*(1+4.*((x-x5)./f5).^2).^-1; 
%                peak_6=w6.*N6./f6.*(2.*(log(2)).^.5)./pi.^.5.*exp(-4.*log(2).*((x-x6)./f6).^2) + (1-w6).*N6./f6.*2./pi.*(1+4.*((x-x6)./f6).^2).^-1;

               assignin('base','peak1',peak_1);
               assignin('base','peak2',peak_2);
               assignin('base','peak3',peak_3);
               assignin('base','peak4',peak_4);
               assignin('base','peak5',peak_5);
               assignin('base','peak6',peak_6);
               disp(' This is not plotting because you used it to extract intensities of each peak')
               plot(x,peak_1+back,x,peak_2+back,x,peak_3+back,x,peak_4+back,x,peak_5+back,x,peak_6+back)
               
                    end
                    
                    if strcmp(Stro.PSfxn{i}, 'Lorentzian')==1
                    temp=num2cell(Stro.fit_parms{j}(i,1:3));
                    [N,x01,F]=deal(temp{:});
                    peak_1= N.*1./pi* (0.5.*F./((x-x01).^2+(0.5.*F).^2));
                    plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        
                    end
                    if or(strcmp(Stro.PSfxn{i},'PsuedoVoigtTriplet'),strcmp(Stro.PSfxn{i},'PsuedoVoigtTriplet_aspRatio'))
                        temp=num2cell(Stro.fit_parms{j}(i,1:12));
                        [N,x0,c,w,N1,x1,c1,w1,N2,x2,c2,w2]=deal(temp{:});
                        peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                        peak_2 = w1.*N1/c1.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c1).^2) + (1-w1).*N1/c1.*2/pi.*(1+4.*((x-x1)/c1).^2).^-1;
                        peak_3 = w2.*N2/c2.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x2)/c2).^2) + (1-w2).*N2/c2.*2/pi.*(1+4.*((x-x2)/c2).^2).^-1;
                        
                        plot(x,peak_1+back,x,peak_2+back,x,peak_3+back)
                    
                    end
                    
                    if strcmp(Stro.PSfxn{i},'PsuedoVoigtDoubletConstrain_w')
                        temp = num2cell( Stro.fit_parms{j}(i,1:7));
                        [N,x0,c,w,N1,x1,c1] = deal( temp{:} );
                        peak_1 = w.*N./c.*(2*(log(2)).^.5)/pi.^.5.*exp(-4*log(2).*((x-x0)./c).^2) + (1-w).*N./c.*2./pi.*(1+4.*((x-x0)./c).^2).^-1;
                        peak_2 = w.*N1./c1.*(2*(log(2)).^.5)/pi.^.5.*exp(-4*log(2).*((x-x1)./c1).^2) + (1-w).*N1./c1.*2./pi.*(1+4.*((x-x1)./c1).^2).^-1;
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                      
                        
                    end
                    
                    if strcmp(Stro.PSfxn{i},'PVIIDoubletConstrain_m')
                        temp = num2cell( Stro.fit_parms{j}(i,1:7) );                            
                        [N,x0,f,m,N2,x02,f2]  = deal( temp{:} );
                        peak_1 = N .* 2 .* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                        peak_2 = N2 .* 2 .* ((2.^(1/m)-1).^0.5) / f2 / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-x02).^2)/f2.^2).^(-m);
                        plot(x,peak_1+back,'LineWidth',1.2);
                        plot(x,peak_2+back,'LineWidth',1.2);
                        
                     elseif strcmp(Stro.PSfxn{i},'asymmPVIIDoubletConstrain_f')
                        temp = num2cell( Stro.fit_parms{j}(i,1:11) );
                        [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,m2L,I2R,m2R]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L*FitDiffractionDataOriginal.C4(m1L)./F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L*FitDiffractionDataOriginal.C4(m2L)./F1L.*(1+4.*(2.^(1/m2L)-1).*(x-x02).^2/F1L.^2).^(-m2L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m2R)/(F1L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).*(1+4.*(2.^(1/m2R)-1).*(x-x02).^2/(F1L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).^2).^(-m2R);                                        
                        plot(x,peak_1+back, x, peak_2+back,'LineWidth',1.2)
                        
                        
                        
                    end
                    
                    
                    
                    
                   if strcmp(Stro.PSfxn{i},'asymmPVIIDoublet_PsuedoVoigt1_MargeauxFilms')
                       temp = num2cell( Stro.fit_parms{j}(i,1:16) );
                        [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,m2L,F2L,I2R,m2R,x03,f1,w1,N1]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L*FitDiffractionDataOriginal.C4(m1L)./F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L*FitDiffractionDataOriginal.C4(m2L)./F2L.*(1+4.*(2.^(1/m2L)-1).*(x-x02).^2/F2L.^2).^(-m2L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m2R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).*(1+4.*(2.^(1/m2R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).^2).^(-m2R);                                        
                        peak_3 = (w1).*N1/f1.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x03)/f1).^2) + (1-w1).*N1/f1.*2/pi.*(1+4.*((x-x03)/f1).^2).^-1;

                        plot(x,peak_1+back, x, peak_2+back,x,peak_3+back,'LineWidth',1.2)
                   
                   elseif strcmp(Stro.PSfxn{i},'PsuedoVoigt_asymmPVII_Doublet')
                        temp = num2cell( Stro.fit_parms{j}(i,1:10) );
                        [x01,I1L,m1L,F1L,I1R,m1R,w,N,x0,c]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L*FitDiffractionDataOriginal.C4(m1L)./F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        peak_2 = (w).*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                        
                        plot(x,peak_1+back, x, peak_2+back,'LineWidth',1.2)

                    
                   elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'asymmPVIIDoublet'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:12) );
                        [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,m2L,F2L,I2R,m2R]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L*FitDiffractionDataOriginal.C4(m1L)./F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L*FitDiffractionDataOriginal.C4(m2L)./F2L.*(1+4.*(2.^(1/m2L)-1).*(x-x02).^2/F2L.^2).^(-m2L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m2R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).*(1+4.*(2.^(1/m2R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).^2).^(-m2R);                                        
                        plot(x,peak_1+back, x, peak_2+back,'LineWidth',1.2)
                        
                        
                        
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'PsuedoVoigt'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:4) );
                        [N1,x1,f1,w1] = deal( temp{:} );
                        peak_1=N1.*((w1.*(2./pi).*(1./f1).*1./(1+(4.*(x-x1).^2./f1.^2))) + ((1-w1).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f1.*exp(-log(2).*4.*(x-x1).^2./f1.^2)));
                        plot(x, peak_1+back,'LineWidth',1.2)           
                        
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'asymmPVII'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:6) );
                        [x01,I1L,m1L,F1L,I1R,m1R]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                        plot(x,peak_1+back,'LineWidth',1.2);

                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'PVII'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:4) );                            
                        [N,x0,m,f]  = deal( temp{:} );
                        peak_1 = N .* 2 .* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                        plot(x,peak_1+back,'LineWidth',1.2);
                      
                        
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'PVIIDoublet'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:8) );                            
                        [N,x0,f,m1,N2,x02,f2,m2]  = deal( temp{:} );
                        peak_1 = N .* 2 .* ((2.^(1/m1)-1).^0.5) / f / (pi.^0.5) .* gamma(m1) / gamma(m1-0.5) .* (1+4.*(2.^(1/m1)-1).*((x-x0).^2)/f.^2).^(-m1);
                        peak_2 = N2 .* 2 .* ((2.^(1/m2)-1).^0.5) / f2 / (pi.^0.5) .* gamma(m2) / gamma(m2-0.5) .* (1+4.*(2.^(1/m2)-1).*((x-x02).^2)/f2.^2).^(-m2);
                        plot(x,peak_1+back,x,peak_2+back,'LineWidth',1.2);
                       
                        
                        
                   elseif strcmp(Stro.PSfxn{i}, 'PVII2')
                        temp = num2cell( Stro.fit_parms{j}(i,1:8) );          
                        [N, x0, m, f, N2, x02, m2,f2]  = deal( temp{:} );
                        peak_1 = N.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                        peak_2 = N2.*((2.^(1/m2)-1).^0.5)/f2/(pi.^0.5).*gamma(m2)/gamma(m2-0.5).*(1+4.*(2.^(1/m2)-1).*((x-x02).^2)/f2.^2).^(-m2);

                        plot(x,peak_1+back,x,peak_2+back)

                    elseif strcmp(Stro.PSfxn{i}, 'Gauss3jj')
                        temp = num2cell( Stro.fit_parms{j}(i,1:9) );     
                        [N1,x01,c1,N2,x02,c2,N3,x03,c3] = deal( temp{:} );                
                        peak_1 = N1.*exp(-((x-x01)/c1).^2);
                        peak_2 = N2.*exp(-((x-x02)/c2).^2);
                        peak_3 = N3.*exp(-((x-x03)/c3).^2);
                        plot(x,peak_1+back,x,peak_2+back,x,peak_3+back)     
                              
                    elseif strcmp(Stro.PSfxn{i}, 'PsuedoVoigtGuass')
                        temp = num2cell( Stro.fit_parms{j}(i,1:11) );
                        [w,N,x0,c,w1,N1,x1,c1,N2,x2,c2] = deal( temp{:} );
                        peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                        peak_2 = w1.*N1/c1.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c1).^2) + (1-w1).*N1/c1.*2/pi.*(1+4.*((x-x1)/c1).^2).^-1;
                        peak_3 = N2.*exp(-((x-x2)/c2).^2);
                        plot(x,peak_1+back,x,peak_2+back,x,peak_3+back)                                              
                        
                    elseif strcmp(Stro.PSfxn{i}, 'PsuedoVoigtGuassConstrain')
                        temp = num2cell( Stro.fit_parms{j}(i,1:9) );
                        [w,N,x0,c,N1,x1,N2,x2,c2] = deal( temp{:} );
                        peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                        peak_2 = w.*N1/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c).^2) + (1-w).*N1/c.*2/pi.*(1+4.*((x-x1)/c).^2).^-1;
                        peak_3 = N2.*exp(-((x-x2)/c2).^2);
                        plot(x,peak_1+back,x,peak_2+back,x,peak_3+back)     
                    elseif strcmp(Stro.PSfxn{i}, 'PVIIKa1Ka2')
                        temp = num2cell( Stro.fit_parms{j}(i,1:6) );
                        [N,x0,m,m2,f,f2] = deal( temp{:} );
                        peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                        peak_2 = N/1.9.*2.*((2.^(1/m2)-1).^0.5)./f2./(pi.^0.5).*gamma(m2)./gamma(m2-0.5).*(1+4.*(2.^(1/m2)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0)).^2)./f2.^2).^(-m2);
                        plot(x,peak_1+back,x,peak_2+back)  
                    elseif strcmp(Stro.PSfxn{i}, 'PVIIKa1Ka2fsame')
                        temp = num2cell( Stro.fit_parms{j}(i,1:5) );
                        [N,x0,m,m2,f] = deal( temp{:} );
                        peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                        peak_2 = N/1.9.*2.*((2.^(1/m2)-1).^0.5)./f./(pi.^0.5).*gamma(m2)./gamma(m2-0.5).*(1+4.*(2.^(1/m2)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0)).^2)./f.^2).^(-m2);
                        plot(x,peak_1+back,x,peak_2+back)  
                    elseif strcmp(Stro.PSfxn{i}, 'PVIIKa1Ka2bothsame')
                        temp = num2cell( Stro.fit_parms{j}(i,1:4) );
                        [N,x0,m,f] = deal( temp{:} );
                        peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                        peak_2 = N/1.9.*2.*((2.^(1/m)-1).^0.5)./f./(pi.^0.5).*gamma(m)./gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0)).^2)./f.^2).^(-m);
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                    elseif strcmp(Stro.PSfxn{i}, 'GaussKa1Ka2')
                        temp = num2cell( Stro.fit_parms{j}(i,1:3) );
                        [N,x0,c] = deal( temp{:} );
                        peak_1 = N*exp(-((x-x0)./c).^2);
                        peak_2 = N/1.9*exp(-((x-FitDiffractionDataOriginal.Ka2fromKa1(x0))/c).^2);
                        plot(x,peak_1+back,x,peak_2+back)
                    elseif strcmp(Stro.PSfxn{i}, 'PsuedoVoigtKa1Ka2')
                        temp = num2cell( Stro.fit_parms{j}(i,1:4) );
                        [w,N,x0,c] = deal( temp{:} );
                        peak_1 = w*N/c*(2*(log(2))^.5)/pi.^.5.*exp(-4*log(2).*((x-x0)/c).^2);
                        peak_2 = w*N/1.9/c*(2*(log(2))^.5)./pi^.5*exp(-4*log(2).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0))/c).^2);
                        plot(x,peak_1+back,x,peak_2+back)
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'PsuedoVoigtDoublet'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:8));
                        [N,x0,c,w,N1,x1,c1,w1] = deal( temp{:} );
                        peak_1 = w.*N./c.*(2*(log(2)).^.5)/pi.^.5.*exp(-4*log(2).*((x-x0)./c).^2) + (1-w).*N./c.*2./pi.*(1+4*((x-x0)./c).^2).^-1;
                        peak_2 = w1.*N1./c1.*(2*(log(2)).^.5)./pi.^.5.*exp(-4*log(2).*((x-x1)./c1).^2) + (1-w1).*N1./c1.*2./pi.*(1+4.*((x-x1)./c1).^2).^-1;
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                    elseif any(strcmp(Stro.PSfxn{i},'PsuedoVoigt_11BM'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:4));
                        [N,c,w,x0] = deal( temp{:} );
                        peak_1=  w.*N./c.*(2.*(log(2))^.5)./pi^.5.*exp(-4.*log(2).*((x-x0)./c).^2) + (1-w).*N./c.*2./pi.*(1+4.*((x-x0)./c).^2).^-1';
                        plot(x,peak_1+back,'green','LineWidth', 4)
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'PsuedoVoigtDoubletConstrain_w'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:7));
                        [N,x0,c,w,N1,x1,c1] = deal( temp{:} );
                        peak_1 = w.*N./c.*(2*(log(2)).^.5)/pi.^.5.*exp(-4*log(2).*((x-x0)./c).^2) + (1-w).*N./c.*2./pi.*(1+4.*((x-x0)./c).^2).^-1;
                        peak_2 = w.*N1./c1.*(2*(log(2)).^.5)/pi.^.5.*exp(-4*log(2).*((x-x1)./c1).^2) + (1-w).*N1./c1.*2./pi.*(1+4.*((x-x1)./c1).^2).^-1;
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                        disp('hello')
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'PsuedoVoigtDoublet002'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:8));
                        [w,N,x0,c,w1,N1,x1,c1] = deal( temp{:} );
                        peak_1 = w.*N./c.*(2*(log(2)).^.5)/pi.^.5.*exp(-4*log(2).*((x-x0)./c).^2) + (1-w).*N./c.*2./pi.*(1+4*((x-x0)./c).^2).^-1;
                        peak_2 = w1.*N1./c1.*(2*(log(2)).^.5)./pi.^.5.*exp(-4*log(2).*((x-x1)./c1).^2) + (1-w1).*N1./c1.*2./pi.*(1+4.*((x-x1)./c1).^2).^-1;
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'PsuedoVoigtTripletConstrain_f'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:8) );
                        [N,c,w,x0,N1,x1,N2,x2] = deal( temp{:} );
                        peak_1 = (1-w).*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + w.*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                        peak_2 = (1-w).*N1/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c).^2) + w.*N1/c.*2/pi.*(1+4.*((x-x1)/c).^2).^-1;
                        peak_3 = (1-w).*N2/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x2)/c).^2) + w.*N2/c.*2/pi.*(1+4.*((x-x2)/c).^2).^-1;
                        plot(x,peak_1+back,x,peak_2+back,x,peak_3+back) 
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'PsuedoVoigtDoubletConstrained'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:6) );
                        [N,c,w,x0,N2,x2] = deal( temp{:} );
                        peak_1 = (1-w).*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + w.*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                        peak_3 = (1-w).*N2/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x2)/c).^2) + w.*N2/c.*2/pi.*(1+4.*((x-x2)/c).^2).^-1;
                        plot(x,peak_1+back,x,peak_3+back) 

                    elseif strcmp( Stro.PSfxn{i}, 'psuedo_voigt_triple_New' )
                        temp = num2cell( Stro.fit_parms{j}(i,1:10) );
                        [N1,f1,w1,x01,N2,f2,w2,x02,N3,x03] = deal( temp{:} );
                        
                        peak_1 = N1.*((w1.*(2./pi).*(1./f1).*1./(1+(4.*(x-x01).^2./f1.^2))) + ((1-w1).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f1.*exp(-log(2).*4.*(x-x01).^2./f1.^2)));
                        peak_2 = N2.*((w2.*(2./pi).*(1./f2).*1./(1+(4.*(x-x02).^2./f2.^2))) + ((1-w2).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f2.*exp(-log(2).*4.*(x-x02).^2./f2.^2)));
                        peak_3 = N3.*((w1.*(2./pi).*(1./f1).*1./(1+(4.*(x-x03).^2./f1.^2))) + ((1-w1).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f1.*exp(-log(2).*4.*(x-x03).^2./f1.^2)));
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                        plot(x,peak_3+back, 'm', 'LineWidth', 1.2)

                    elseif strcmp( Stro.PSfxn{i}, 'PVIIKa1Ka2bothsame_Doublet' )
                        temp = num2cell( Stro.fit_parms{j}(i,1:8));
                        [N,x0,m,f,N1,x1,m1,f1] = deal( temp{:} );                    
                        peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                        peak_2 = N/1.9.*2.*((2.^(1/m)-1).^0.5)./f./(pi.^0.5).*gamma(m)./gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0)).^2)./f.^2).^(-m);
                        peak_3 = N1.*2.*((2.^(1./m1)-1).^0.5)./f1./(pi.^0.5).*gamma(m1)./gamma(m1-0.5).*(1+4.*(2.^(1./m1)-1).*((x-x1).^2)./f1.^2).^(-m1);
                        peak_4 = N1./1.9.*2.*((2.^(1./m1)-1).^0.5)./f1./(pi.^0.5).*gamma(m1)./gamma(m1-0.5).*(1+4.*(2.^(1./m1)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x1)).^2)./f1.^2).^(-m1);

                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                        plot(x,peak_3+back, 'm', 'LineWidth', 1.2)
                        plot(x,peak_4+back, '--m', 'LineWidth', 1.2)    
                        
                    elseif strcmp( Stro.PSfxn{i}, 'Gauss_11IDC_octuplet' )
                        temp = num2cell( Stro.fit_parms{j}(i,1:24));
                        [N1,x01,c1,N2,x02,c2,N3,x03,c3,N4,x04,c4,N5,x05,c5,N6,x06,c6,N7,x07,c7,N8,x08,c8] = deal( temp{:} );  

                        peak_1 = N1.*exp(-((x-x01)/(c1/(sqrt(4*log(2))))).^2);
                        peak_2 = N2.*exp(-((x-x02)/(c2/(sqrt(4*log(2))))).^2);
                        peak_3 = N3.*exp(-((x-x03)/(c3/(sqrt(4*log(2))))).^2);
                        peak_4 = N4.*exp(-((x-x04)/(c4/(sqrt(4*log(2))))).^2);
                        peak_5 = N5.*exp(-((x-x05)/(c5/(sqrt(4*log(2))))).^2);
                        peak_6 = N6.*exp(-((x-x06)/(c6/(sqrt(4*log(2))))).^2);
                        peak_7 = N7.*exp(-((x-x07)/(c7/(sqrt(4*log(2))))).^2);
                        peak_8 = N8.*exp(-((x-x08)/(c8/(sqrt(4*log(2))))).^2);
                        
                        plot(x,peak_1+back,x,peak_2+back,x,peak_3+back,x,peak_4+back,x,peak_5+back,x,peak_6+back,x,peak_7+back,x,peak_8+back, 'LineWidth', 1.2)       
                        
                    elseif strcmp( Stro.PSfxn{i}, 'GaussConstrained_11IDC_octuplet' )
                        temp = num2cell( Stro.fit_parms{j}(i,1:24));
                        [N1,x01,c,N2,x02,N3,x03,N4,x04,N5,x05,N6,x06,N7,x07,N8,x08,N9,x09,c9,N10,x10,N11,x11] = deal( temp{:} );  

                        peak_1 = N1.*exp(-((x-x01)/(c/(sqrt(4*log(2))))).^2);
                        peak_2 = N2.*exp(-((x-x02)/(c/(sqrt(4*log(2))))).^2);
                        peak_3 = N3.*exp(-((x-x03)/(c/(sqrt(4*log(2))))).^2);
                        peak_4 = N4.*exp(-((x-x04)/(c/(sqrt(4*log(2))))).^2);
                        peak_5 = N5.*exp(-((x-x05)/(c/(sqrt(4*log(2))))).^2);
                        peak_6 = N6.*exp(-((x-x06)/(c/(sqrt(4*log(2))))).^2);
                        peak_7 = N7.*exp(-((x-x07)/(c/(sqrt(4*log(2))))).^2);
                        peak_8 = N8.*exp(-((x-x08)/(c/(sqrt(4*log(2))))).^2);
                        peak_9 = N9.*exp(-((x-x09)/(c9/(sqrt(4*log(2))))).^2);
                        peak_10 = N10.*exp(-((x-x10)/(c/(sqrt(4*log(2))))).^2);
                        peak_11 = N11.*exp(-((x-x11)/(c/(sqrt(4*log(2))))).^2);                      
                        
                        plot(x,peak_1+back,x,peak_2+back,x,peak_3+back,x,peak_4+back,x,peak_5+back,x,peak_6+back,x,peak_7+back,x,peak_8+back,x,peak_9+back,x,peak_10+back,x,peak_11+back, 'LineWidth', 1.2)       
                   
                    elseif strcmp( Stro.PSfxn{i}, 'GaussdoubletConstrained_11IDC' )
                        temp = num2cell( Stro.fit_parms{j}(i,1:5));
                        [N,x0,c,N1,x01] = deal( temp{:} )    ;            
                        peak_1 = N.*exp(-((x-x0)/(c/(sqrt(4*log(2))))).^2);
                        peak_2 = N1.*exp(-((x-x01)/(c/(sqrt(4*log(2))))).^2);
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)  
                        
                    elseif strcmp( Stro.PSfxn{i}, 'Gaussdoublet_11IDC' )
                        temp = num2cell( Stro.fit_parms{j}(i,1:6));
                        [N,x0,c,N1,x01, c1] = deal( temp{:} )    ;            
                        peak_1 = N.*exp(-((x-x0)/(c/(sqrt(4*log(2))))).^2);
                        peak_2 = N1.*exp(-((x-x01)/(c1/(sqrt(4*log(2))))).^2);
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2) 
                                             
                    elseif strcmp( Stro.PSfxn{i}, 'LorentzianDoublet' )
                        temp = num2cell( Stro.fit_parms{j}(i,1:6));
                        [N,x01,F,N2,x02,F2] = deal( temp{:} )        ;        
                        peak_1 = N*1/pi* (0.5*F./((x-x01).^2+(0.5*F)^2));
                        peak_2 = N2.*1./pi.* (0.5.*F2./((x-x02).^2+(0.5*F2).^2));
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                    elseif strcmp( Stro.PSfxn{i}, 'LorentzianDoublet002_11IDC' )
                        temp = num2cell( Stro.fit_parms{j}(i,1:6));
                        [N,x01,F,N2,x02,F2] = deal( temp{:} )        ;        
                        peak_1 = N*1/pi* (0.5*F./((x-x01).^2+(0.5*F)^2));
                        peak_2 = N2.*1./pi.* (0.5.*F2./((x-x02).^2+(0.5*F2).^2));
                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'asymmPVIIKa1Ka2'))
                        temp = num2cell( Stro.fit_parms{j}(i,1:8) );
                        [x01,I1L,m1L,F1L,I1R,m1R,IL2,IR2]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);                
                        peak_2 = FitDiffractionDataOriginal.AsymmCutoff(FitDiffractionDataOriginal.Ka2fromKa1(x01),1,x).*IL2.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-FitDiffractionDataOriginal.Ka2fromKa1(x01)).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(FitDiffractionDataOriginal.Ka2fromKa1(x01),2,x).*IR2.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*IR2/IL2.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-FitDiffractionDataOriginal.Ka2fromKa1(x01)).^2/(F1L.*IR2/IL2.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);                

                        plot(x,peak_1+back, 'b', 'LineWidth', 1.2)
                        plot(x,peak_2+back, '--b', 'LineWidth', 1.2)
                    end
                end
                if strcmp(dataSet,'all')
                    xlim([min(x) max(x)])
                    ylim([0 max(fittedPattern)])
                end
            end
%             hLegend = legend(data,leg);
%             set([hLegend, gca],'FontSize',16);                       

            xlim([Stro.Min2T Stro.Max2T])
            
            if strcmp(dataSet,'all')
                linkaxes(ax,'xy');
            end
            
%         prompt='Would you like to save output? '; %ask user if he/she is importing a new file
%         answer=input(prompt,'s'); 
%         A=strncmpi(answer,'y',1); %compares the asnwer inputed by the user 
%         C=strncmpi(answer,'1',1);
%         
%         fitOutputPath =Stro.DataPath;
%         
% 
%         
%         if A==1 %if it is (Yes, Y, or y)then...
%         
%            
%         saveas(figure(5),strcat(fitOutputPath,strcat(filename{dataSet},'_','_fig1-plotFit'),'fig'))
%         
%         elseif C==1 & strcmp(dataSet,'all')
%             saveas(figure(5),strcat(fitOutputPath,strcat('all','_','_fig1-plotFit'),'fig'))
%         elseif C==1
%             filename=strsplit(Stro.Filename{dataSet},'.');
%             saveas(figure(5),strcat(fitOutputPath,strcat(filename{1},'_','_fig1-plotFit'),'fig'))
%         end
        
            
	end
        function SaveplotFit(Stro)
            
            fitOutputPath =strcat(Stro.DataPath,'FitOutputs\Fit_Figure\');
            
            for s=1:length(Stro.Filename)
                Stro.plotFit(s)
            filename=strsplit(Stro.Filename{s},'.');
                
            saveas(figure(5),strcat(fitOutputPath,strcat(filename{1},'-','plotFit')))

            end
            
                Stro.plotFit('all')
            saveas(figure(5),strcat(fitOutputPath,strcat('Master','-','plotFit')))    
            close Figure 5
        
	end
        function averageData(Stro,numFiles)
            Stro.DataAverage = numFiles;
            if ~isempty(Stro.originalData)
                Stro.data_fit = Stro.originalData;
                Stro.temperature = Stro.temperature_init;
                Stro.fit_parms = {};
                Stro.fit_parms_error = {};
                Stro.fit_results = {};
            end
            temp = [];
            data = [];
            [a b] = size( Stro.data_fit );
            for i=0:a/numFiles-1
                for j=1:numFiles
                    if j==1
                        data(i+1,:) = Stro.data_fit(numFiles*i+j,:)/numFiles;
                        if ~isempty(Stro.temperature); temp(i+1) = Stro.temperature(numFiles*i+j,:)/numFiles; end
                    else
                        data(i+1,:) = data(i+1,:) + Stro.data_fit(numFiles*i+j,:)/numFiles;
                        if ~isempty(Stro.temperature); temp(i+1) = temp(i+1) + Stro.temperature(numFiles*i+j,:)/numFiles; end
                    end
                end
            end
            
            Stro.originalData = Stro.data_fit;
            Stro.data_fit = data;
            Stro.temperature_init = Stro.temperature;
            Stro.temperature = temp;

        end
        function outputError(Stro)
            
            nma=strsplit(Stro.Filename{1},'.');
            pf1=evalin('base','pf1');
            save(char(strcat(Stro.OutputPath,'WorkSpace-',nma(1),'-',num2str(length(Stro.Filename)),'.mat')),'pf1')
            disp('WS saved')   
            
            if isa(Stro.Filename,'char')
                Stro.Filename = {Stro.Filename};
            end
            
            if ~exist( Stro.OutputPath, 'dir' )
                mkdir( Stro.OutputPath );
            end
            
            if length(Stro.Filename) == 1
                if isempty(Stro.SPR_Angle)
                    outFilePrefix = strcat(Stro.OutputPath,Stro.Filename{1},'_RwRp_error_');
                else
                    outFilePrefix = strcat(Stro.OutputPath,Stro.Filename{1},'_RwRp_error_Angle_',num2str(Stro.SPR_Angle),'_');
                end
            else
                if isempty(Stro.SPR_Angle)
                    outFilePrefix = strcat(Stro.OutputPath,Stro.Filename{1},'_Series_RwRp_error_');
                else
                    outFilePrefix = strcat(Stro.OutputPath,Stro.Filename{1},'_Series_RwRp_error_Angle_',num2str(Stro.SPR_Angle),'_');
                end
            end
            
            index = 0;
            iprefix = '00';
            while exist(strcat(outFilePrefix,strcat(iprefix,num2str(index)),'.txt'),'file') == 2
                index = index + 1;
                if index > 100
                    iprefix = '';
                elseif index > 10
                    iprefix = '0';
                end
            end
            fid=fopen(strcat(outFilePrefix,strcat(iprefix,num2str(index)),'.txt'),'w'); %the name of the file it will write containing the statistics of the fit

            fprintf(fid, 'Fit parameters\n\n');
            fprintf(fid, '2theta_fit_range: %f %f\n\n',Stro.Min2T, Stro.Max2T);

            if ~isempty(Stro.DataAverage)
                fprintf(fid, 'Average_Data: %f \n\n',Stro.DataAverage);
            end
            if ~isempty(Stro.SPR_Angle)
                fprintf(fid, 'SPR_Angle: %i \n\n',Stro.SPR_Angle);
            end
            
            fprintf(fid, 'Number_of_background_points: %i\n',length(Stro.bkgd2th));
            fprintf(fid, 'Background_order: %i\n', Stro.PolyOrder);
            fprintf(fid, 'Background_points:');
            for i=1:length(Stro.bkgd2th)
                fprintf(fid, ' %f',Stro.bkgd2th(i));
            end
            fprintf(fid, '\n\nPeak Paramaters\n');
            
            fprintf(fid, 'PeakPos:');
            for i=1:length(Stro.PSfxn)
                fprintf(fid, ' %.3f',Stro.PeakPositions(i));
            end
            fprintf(fid,'\nFxn:');
            for i=1:length(Stro.PSfxn)
                fprintf(fid,' %s',Stro.PSfxn{i});
            end
            if ~isempty(Stro.fitrange)
                fprintf(fid,'\nfitrange:');
                for i=1:length(Stro.PSfxn)
                    fprintf(fid,' %f',Stro.fitrange(i));
                end
            end
            
            fprintf(fid, '\nOriginal SP');
            for g=1:length(Stro.PSfxn);
            fprintf(fid, '\n%s\t', Stro.PSfxn{g});    
            for f=1:length(Stro.Fcoeff{g});
                            fprintf(fid, '%s\t', char(Stro.Fcoeff{g}(f))); %write coefficient names
            end
            fprintf(fid, '\nSP:');
            fprintf(fid,' %f',(Stro.original_SP{1,g}));
            fprintf(fid, '\nUB:');
            fprintf(fid,' %f',(Stro.original_SP{2,g}));
            fprintf(fid, '\nLB:');
            fprintf(fid,' %f',(Stro.original_SP{3,g}));         
            end
            fprintf(fid, '\n\nFit_initial Parameters ');
            for g=1:length(Stro.PSfxn);
            fprintf(fid, '\n%s', Stro.PSfxn{g});    
            for f=1:length(Stro.Fcoeff{g});
            fprintf(fid, '\t%s\t', char(Stro.Fcoeff{g}(f))); %write coefficient names
            end
            fprintf(fid, '\niSP:');
            fprintf(fid,' %f',(Stro.fit_initial{1,g}));
            fprintf(fid, '\niUB:');
            fprintf(fid,' %f',(Stro.fit_initial{2,g}));
            fprintf(fid, '\niLB:');
            fprintf(fid,' %f',(Stro.fit_initial{3,g}));
            end
%             fprintf(fid, '\nFinal Parameters \n');
%             a=size(Stro.fit_parms{:});          
%             fprintf(fid, 'FP:'); 
%             for u=1:a(1)
%             fprintf(fid,' %f',(Stro.fit_parms{:}(u,:)));
%             end
            
            fprintf(fid, '\n\nFit Errors\n');

            if strcmp( Stro.suffix, 'xrdml')
               fprintf(fid, 'Filename \t temperature \t Rp \t Rwp'); % What is being printed on the new txt file on the rirst row (this just labels what column refers to what)   
            else
               fprintf(fid, 'Filename \t\t Rp \t Rwp'); % What is being printed on the new txt file on the rirst row (this just labels what column refers to what)   
            end
            

                        
            for i=1:size( Stro.data_fit, 1) %this takes the length specified above in line 30
                obs=Stro.fit_results{i}(2,:)'; %specifies observed values
                
                calc = Stro.fit_results{i}(3,:)';
                for j=1:length(Stro.PSfxn)
                    calc = calc + Stro.fit_results{i}(3+j,:)';
                end
                fprintf(fid,'\n');
                Rp=(sum(abs(obs-calc))./(sum(obs)))*100;                %calculates Rp
                w=(1./obs); %defines the weighing parameter for Rwp
                Rwp=(sqrt(sum(w.*(obs-calc).^2)./sum(obs)))*100 ; %Calculate Rwp
                
                if strcmp( Stro.suffix, 'xrdml')  
                    [path, filename, ext] = fileparts( Stro.Filename{1} );
                    fprintf(fid, '%s \t %.0f \t %.2f \t %.2f',filename, Stro.temperature(i), Rp, Rwp);

                else
                    [path, filename, ext] = fileparts( Stro.Filename{i} );
                    fprintf(fid, '%s \t %.2f \t %.2f', filename, Rp, Rwp);
                end
                %writes the filename, Rp, and Rwp for into a text file rounding to 2 decimal places
            end
            
            fclose(fid); %closes file
        end
        function setTwo_Theta_Range(Stro)
            Stro.plotData(1)

            Max2T_old = Stro.Max2T;
            modifyRange = 1;
            while modifyRange == 1
                try
                    prompt = {'Minimum 2theta:','Maximum 2theta:','Done:'};
                    dlg_title = 'Select 2theta range to fit';
                    num_lines = 1;
                    def = {num2str(min(Stro.Min2T)),num2str(max(Stro.Max2T)),'No'};
                    two_theta_range = newid(prompt,dlg_title,num_lines,def);
                    Stro.Min2T = str2double(two_theta_range{1});
                    Stro.Max2T = str2double(two_theta_range{2});
                    xlim([Stro.Min2T Stro.Max2T])
                    if or(strcmp(two_theta_range{3},'Yes'),strcmp(two_theta_range{3},'yes'))
                        modifyRange = 0;
                    end
                catch                                         
                    modifyRange = 0;
                end
            end
            if Max2T_old ~= Stro.Max2T
                Stro.bkgd2th = [];
            end
            close all
        end
        function setSPR_Angle(Stro,Angle)

            angles = fliplr([0:360/Stro.numAzim:90]);

            if nargin==2
                if isempty( angles(find(angles==Angle)) )                    
                    Stro.setSPR_Angle()
                else
                    Stro.SPR_Angle = angles(find(angles==Angle));
                    if size(Stro.SPR_Data(:,:,find(angles==Angle)),2)==1
                        Stro.data_fit = Stro.SPR_Data(:,:,find(angles==Angle))';
                    else
                        Stro.data_fit = Stro.SPR_Data(:,:,find(angles==Angle));
                    end
                end
            else
                AngleString = {'Select SPR Angle to Fit  ('};
                AngleString = strcat(AngleString,{num2str(angles(1))},{' (Perpendicular), '});
                for i=2:length(angles)-1
                    AngleString = strcat(AngleString,{num2str(angles(i))},{', '});
                end
                AngleString = strcat(AngleString,{'and '},{num2str(angles(i+1))},{'(Parallel))'});

                prompt = {strcat(AngleString,{':'})};
                dlg_title = 'Select Angle to Fit';
                num_lines = 1;
                def = {'0'};
                Angle = newid(prompt{1,1},dlg_title,num_lines,def);
                Angle = str2double(Angle{1});
                if ~isempty(angles(find(angles==Angle)))
                    Stro.setSPR_Angle(angles(find(angles==Angle)))
                else
                    Stro.setSPR_Angle
                end
            end
        end
        function resetBackground(Stro)
            Stro.bkgd2th = [];
            Stro.getBackground()
	end
        function plotFWHM(Stro, Peak)
            clear FWHM FWHM_error
            FWHM2 = [];
            FWHM2_error = [];
            
            for i=1:1:size(Stro.data_fit,1)
                if strcmp( Stro.PSfxn{Peak}, 'GaussKa1Ka2' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:3));
                    [N,x0,c] = deal( temp{:} );
                    FWHM(i) = c;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:3));
                    [N,x0,c] = deal( temp{:} );
                    FWHM_error(i) = c;
                elseif strcmp( Stro.PSfxn{Peak}, 'PsuedoVoigtKa1Ka2' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:4));
                    [w,N,x0,c] = deal( temp{:} );
                    Shape(i) = w;
                    FWHM(i) = c;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:4));
                    [w,N,x0,c] = deal( temp{:} );
                    Shape_error(i) = w;
                    FWHM_error(i) = c;
                elseif strcmp( Stro.PSfxn{Peak}, 'PVIIKa1Ka2bothsame' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:5));
                    [N, N2,x0,m,f] = deal( temp{:} );
                    Shape(i) = m;
                    FWHM(i) = f;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:5));
                    [N, N2,x0,m,f] = deal( temp{:} );
                    FWHM_error(i) = f;
                elseif strcmp( Stro.PSfxn{Peak}, 'PVIIKa1Ka2fsame' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:5));
                    [N,x0,m,m2,f] = deal( temp{:} );
                    FWHM(i) = f;
                    Shape(i) = m;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:5));
                    [N,x0,m,m2,f] = deal( temp{:} );
                    FWHM_error(i) = f;
                    Shape_error(i) = m;
                elseif strcmp( Stro.PSfxn{Peak}, 'PVIIKa1Ka2sameshape' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:5));
                    [N,x0,m,f,N2] = deal( temp{:} );
                    FWHM(i) = f;
                    Shape(i) = m;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:5));
                    [N,x0,m,f,N2] = deal( temp{:} );
                    FWHM_error(i) = f;
                    Shape_error(i) = m;
                elseif strcmp( Stro.PSfxn{Peak}, 'PVIIKa1Ka2bothsame_Doublet' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:8));
                    [N,x0,m,f,N1,x1,m1,f1] = deal( temp{:} );
                    FWHM(i) = f;
                    FWHM2(i) = f1;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:8));
                    [N,x0,m,f,N1,x1,m1,f1] = deal( temp{:} );
                    FWHM_error(i) = f;
                    FWHM2_error(i) = f1;
                elseif strcmp( Stro.PSfxn{Peak}, 'PVII_11IDC' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:4));
                    [N,x0,m,f] = deal( temp{:} );
                    FWHM(i) = f;
                    Shape(i) = m;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:4));
                    [N,x0,m,f] = deal( temp{:} );
                    FWHM_error(i) = f;
                    Shape_error(i) = m;
                elseif strcmp( Stro.PSfxn{Peak}, 'PsuedoVoigt_11IDC' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:4));
                    [N,f,w,x0] = deal( temp{:} );
                    Shape(i) = w;
                    FWHM(i) = f;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:4));
                    [N,f,w,x0] = deal( temp{:} );
                    Shape_error(i) = w;
                    FWHM_error(i) = f;
                elseif strcmp( Stro.PSfxn{Peak}, 'asymmPVII_11IDC' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:6));
                    [x0,IL,mL,FL,IR,mR] = deal( temp{:} );
                    FWHM(i) = FL;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:6));
                    [x0,IL,mL,FL,IR,mR] = deal( temp{:} );
                    FWHM_error(i) = FL;
                else
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:6));
                    [N,x0,m,m2,f,f2] = deal( temp{:} );
                    FWHM(i) = f;
                    Shape(i) = m;
                    temp = num2cell( Stro.fit_parms_error{i}(Peak,1:6));
                    [N,x0,m,m2,f,f2] = deal( temp{:} );
                    FWHM_error(i) = f;
                    Shape_error(i) = m;
                end
            end

            FWHM
            
            FWHM_error
            
            if or(isempty(Stro.temperature), all(Stro.temperature, Stro.temperature(1)))
                Stro.constructFigure(8,'Scan Number','FWHM','FWHM vs Scan Number');
                errorbar(1:size(Stro.data_fit,1), FWHM, FWHM_error,'-bo','markersize',10)
                xlim([0,size(Stro.data_fit,1)+1])
            else
                Stro.constructFigure(8,'Temperature (\circC)','FWHM','FWHM vs Temperature');
                errorbar(Stro.temperature, FWHM, FWHM_error,'-bo','markersize',10)
            end

            if ~isempty(FWHM2)
                Stro.constructFigure(9,'Temperature (\circC)','FWHM','FWHM vs Temperature');
                errorbar(Stro.temperature, FWHM2, FWHM2_error,'-mx','markersize',10,'linewidth',1.1) 

                Stro.constructFigure(10,'Temperature (\circ C)','FWHM','FWHM vs Temperature');
                hold on
                errorbar(Stro.temperature, FWHM2, FWHM2_error,'-mx','markersize',10,'linewidth',1.1) 
                errorbar(Stro.temperature, FWHM, FWHM_error,'-bo','markersize',10,'linewidth',1.1)

            end

        end
        function calcdEta(Stro,Peak)
            
            x = Stro.fit_results{1}(1,:)';
                        
            if strcmp(Stro.PSfxn{Peak}, 'asymmPVIIDoublet')
                temp = num2cell( Stro.fit_parms{1}(Peak,:) );
                [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,m2L,F2L,I2R,m2R]  = deal( temp{:} );
                
                peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L.*FitDiffractionDataOriginal.C4(m2L)/F2L.*(1+4.*(2.^(1/m2L)-1).*(x-x02).^2/F2L.^2).^(-m2L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m2R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).*(1+4.*(2.^(1/m2R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).^2).^(-m2R);
                             
                cutPosition1 = FitDiffractionDataOriginal.Find2theta(x,x01);
                cutPosition2 = FitDiffractionDataOriginal.Find2theta(x,x02);
                
                I_002_p = sum( peak_1( 1:cutPosition1) );
                I_200_p = sum( peak_2( cutPosition2:length(peak_2) ) );
                
                temp = num2cell( Stro.fit_parms{2}(Peak,:) );
                [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,m2L,F2L,I2R,m2R]  = deal( temp{:} );
                
                peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L.*FitDiffractionDataOriginal.C4(m2L)/F2L.*(1+4.*(2.^(1/m2L)-1).*(x-x02).^2/F2L.^2).^(-m2L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m2R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).*(1+4.*(2.^(1/m2R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).^2).^(-m2R);

                cutPosition1 = FitDiffractionDataOriginal.Find2theta(x,x01);
                cutPosition2 = FitDiffractionDataOriginal.Find2theta(x,x02);
                
                I_002_n = sum( peak_1(1:cutPosition1 ) );
                I_200_n = sum( peak_2(cutPosition2:length(peak_2) ));                
                
            elseif strcmp(Stro.PSfxn{Peak}, 'PVII2')
                temp = num2cell( Stro.fit_parms{1}(Peak,1:8) );          
                [N, x0, m, f, N2, x02, m2,f2]  = deal( temp{:} );
                peak_1 = N.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                peak_2 = N2.*((2.^(1/m2)-1).^0.5)/f2/(pi.^0.5).*gamma(m2)/gamma(m2-0.5).*(1+4.*(2.^(1/m2)-1).*((x-x02).^2)/f2.^2).^(-m2);                
                
                temp = num2cell( Stro.fit_parms{2}(Peak,1:8) );          
                [N, x0, m, f, N2, x02, m2,f2]  = deal( temp{:} );
                peak_3 = N.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                peak_4 = N2.*((2.^(1/m2)-1).^0.5)/f2/(pi.^0.5).*gamma(m2)/gamma(m2-0.5).*(1+4.*(2.^(1/m2)-1).*((x-x02).^2)/f2.^2).^(-m2);                
                
                I_002_p = sum(peak_1);
                I_200_p = sum(peak_2);
                I_002_n = sum(peak_3);
                I_200_n = sum(peak_4);
            elseif strcmp(Stro.PSfxn{Peak}, 'Gauss3jj')
                temp = num2cell( Stro.fit_parms{1}(Peak,1:9) );     
                [N1,x01,c1,N2,x02,c2,N3,x03,c3] = deal( temp{:} );                
                peak_1 = N1.*exp(-((x-x01)/c1).^2);
                peak_3 = N3.*exp(-((x-x03)/c3).^2);
                I_002_p = sum(peak_1);
                I_200_p = sum(peak_3);
                
                temp = num2cell( Stro.fit_parms{2}(Peak,1:9) );     
                [N1,x01,c1,N2,x02,c2,N3,x03,c3] = deal( temp{:} );                
                peak_1 = N1.*exp(-((x-x01)/c1).^2);
                peak_3 = N3.*exp(-((x-x03)/c3).^2);
                I_002_n = sum(peak_1);
                I_200_n = sum(peak_3);                
                
            elseif strcmp( Stro.PSfxn{Peak}, 'PsuedoVoigtGuass')
                
                temp = num2cell( Stro.fit_parms{1}(Peak,1:11) );
                [w,N,x0,c,w1,N1,x1,c1,N2,x2,c2] = deal( temp{:} );
                peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                peak_2 = w1.*N1/c1.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c1).^2) + (1-w1).*N1/c1.*2/pi.*(1+4.*((x-x1)/c1).^2).^-1;
                peak_3 = N2.*exp(-((x-x2)/c2).^2);
                
                I_002_p = sum(peak_1);
                I_200_p = sum(peak_2);
                
                temp = num2cell( Stro.fit_parms{2}(Peak,1:11) );
                [w,N,x0,c,w1,N1,x1,c1,N2,x2,c2] = deal( temp{:} );
                peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                peak_2 = w1.*N1/c1.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c1).^2) + (1-w1).*N1/c1.*2/pi.*(1+4.*((x-x1)/c1).^2).^-1;
                peak_3 = N2.*exp(-((x-x2)/c2).^2);
                
                I_002_n = sum(peak_1);
                I_200_n = sum(peak_2);       
                
            elseif strcmp(Stro.PSfxn{Peak}, 'PsuedoVoigtGuassConstrain')
                temp = num2cell( Stro.fit_parms{dataSet}(i,1:9) );
                [w,N,x0,c,N1,x1,N2,x2,c2] = deal( temp{:} );
                peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                peak_2 = w.*N1/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c).^2) + (1-w).*N1/c.*2/pi.*(1+4.*((x-x1)/c).^2).^-1;
                peak_3 = N2.*exp(-((x-x2)/c2).^2);

                
            end
            
            eta_p = I_002_p / (I_002_p + I_200_p) - 1/3;
            eta_n = I_002_n / (I_002_n + I_200_n) - 1/3;
            
           
            Stro.dEta = eta_p - eta_n;
        end       
        function plotLattice(Stro,Reflection,Peak)
            
            Stro.constructFigure(6,'Fit Number','Lattice Parameter','Lattice vs Fit Number'); 
            lattice = [];
            for i = 1:size(Stro.data_fit,1)
                if strcmp(Reflection,'111')
                    lattice(i) = Stro.lambda / 2 / sin(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180) * sqrt(3);
                    lattice_error(i) = sqrt( (cos(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180) / sin(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180)^2 * Stro.lambda / 2 * sqrt(3) )^2 * (Stro.fit_parms_error{i}(Peak,2) / 2 * pi / 180)^2  ) ;
                elseif strcmp(Reflection,'200')
                    lattice(i) = Stro.lambda / 2 / sin(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180) * 2;
                    lattice_error(i) = sqrt( (cos(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180) / sin(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180)^2 * Stro.lambda / 2 * sqrt(4) )^2 * (Stro.fit_parms_error{i}(Peak,2) / 2 * pi / 180)^2  ) ;
                elseif strcmp(Reflection,'220')
                    lattice(i) =  Stro.lambda / 2 / sin(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180) * sqrt(8);
                    lattice_error(i) = sqrt( (cos(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180) / sin(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180)^2 * Stro.lambda / 2 * sqrt(8) )^2 * (Stro.fit_parms_error{i}(Peak,2) / 2 * pi / 180)^2  ) ;
                elseif strcmp(Reflection,'311')
                    lattice(i) = Stro.lambda / 2 / sin(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180) * sqrt(11);         
                    lattice_error(i) = sqrt( (cos(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180) / sin(Stro.fit_parms{i}(Peak,2) / 2 * pi / 180)^2 * Stro.lambda / 2 * sqrt(11) )^2 * (Stro.fit_parms_error{i}(Peak,2) / 2 * pi / 180)^2  ) ;
                end
            end
           
            hold on
            errorbar(1:size(Stro.data_fit,1),lattice, lattice_error,'-bo','markersize',10,'linewidth',1.2)

%             lattice = [];
%             for i = 1:length(Stro.temperature)
%                 if strcmp(Reflection,'111')
%                     lattice(i) = Stro.lambda / 2 / sin(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180) * 2;
%                     lattice_error(i) = sqrt( (cos(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180) / sin(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180)^2 * Stro.lambda / 2 * sqrt(3) )^2 * (Stro.fit_parms_error{i}(Peak,6) / 2 * pi / 180)^2  ) ;
%                 elseif strcmp(Reflection,'200')
%                     lattice(i) = Stro.lambda / 2 / sin(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180) * 2;
%                     lattice_error(i) = sqrt( (cos(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180) / sin(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180)^2 * Stro.lambda / 2 * sqrt(4) )^2 * (Stro.fit_parms_error{i}(Peak,6) / 2 * pi / 180)^2  ) ;
%                 elseif strcmp(Reflection,'220')
%                     lattice(i) =  Stro.lambda / 2 / sin(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180) * sqrt(8);
%                     lattice_error(i) = sqrt( (cos(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180) / sin(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180)^2 * Stro.lambda / 2 * sqrt(8) )^2 * (Stro.fit_parms_error{i}(Peak,6) / 2 * pi / 180)^2  ) ;
%                 elseif strcmp(Reflection,'311')
%                     lattice(i) = Stro.lambda / 2 / sin(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180) * sqrt(11);         
%                     lattice_error(i) = sqrt( (cos(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180) / sin(Stro.fit_parms{i}(Peak,6) / 2 * pi / 180)^2 * Stro.lambda / 2 * sqrt(11) )^2 * (Stro.fit_parms_error{i}(Peak,6) / 2 * pi / 180)^2  ) ;
%                 end
%             end
%             
%             errorbar(1:size(Stro.data_fit,1),lattice, lattice_error,'-mx','markersize',10,'linewidth',1.2)

            
        end
        function plotIntensity(Stro,Peak)
            
            for i = 1:size(Stro.data_fit,1)
                x = Stro.fit_results{i}(1,:)';
                if strcmp(Stro.PSfxn{Peak}, 'asymmPVIIDoublet')
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:12) );
                    [x01,I1L,m1L,F1L,I1R,m1R,x02,I2L,m2L,F2L,I2R,m2R]  = deal( temp{:} );
                    peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                    peak_2 = FitDiffractionDataOriginal.AsymmCutoff(x02,1,x).*I2L.*FitDiffractionDataOriginal.C4(m2L)/F2L.*(1+4.*(2.^(1/m2L)-1).*(x-x02).^2/F2L.^2).^(-m2L) + FitDiffractionDataOriginal.AsymmCutoff(x02,2,x).*I2R.*FitDiffractionDataOriginal.C4(m2R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).*(1+4.*(2.^(1/m2R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).^2).^(-m2R);                    
                    peak_3 = I1L.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L);
                    peak_4 = I2R.*FitDiffractionDataOriginal.C4(m2R)/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).*(1+4.*(2.^(1/m2R)-1).*(x-x02).^2/(F2L.*I2R/I2L.*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L)).^2).^(-m2R);
                    
                    Intensity(1,i) = sum(peak_1 .* (x(2)-x(1)) );
                    Intensity(2,i) = sum(peak_2 .* (x(2)-x(1)) );
                    Intensity(3,i) = sum(peak_3 .* (x(2)-x(1)) );
                    Intensity(4,i) = sum(peak_4 .* (x(2)-x(1)) );
                    
                elseif strcmp(Stro.PSfxn{Peak}, 'PVII')
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:4) );                            
                    [N,x0,m,f]  = deal( temp{:} );
                    peak = N .* 2 .* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                                        
                elseif strcmp(Stro.PSfxn{Peak}, 'PVII2')
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:8) );          
                    [N, x0, m, f, N2, x02, m2,f2]  = deal( temp{:} );
                    peak_1 = N.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                    peak_2 = N2.*((2.^(1/m2)-1).^0.5)/f2/(pi.^0.5).*gamma(m2)/gamma(m2-0.5).*(1+4.*(2.^(1/m2)-1).*((x-x02).^2)/f2.^2).^(-m2);
                elseif strcmp(Stro.PSfxn{Peak}, 'Gauss3jj')
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:9) );     
                    [N1,x01,c1,N2,x02,c2,N3,x03,c3] = deal( temp{:} );                
                    peak_1 = N1.*exp(-((x-x01)/c1).^2);
                    peak_2 = N2.*exp(-((x-x02)/c2).^2);
                    peak_3 = N3.*exp(-((x-x03)/c3).^2);
                    
                elseif strcmp(Stro.PSfxn{Peak}, 'PsuedoVoigtGuass')
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:11) );
                    [w,N,x0,c,w1,N1,x1,c1,N2,x2,c2] = deal( temp{:} );
                    peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                    peak_2 = w1.*N1/c1.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c1).^2) + (1-w1).*N1/c1.*2/pi.*(1+4.*((x-x1)/c1).^2).^-1;
                    peak_3 = N2.*exp(-((x-x2)/c2).^2);
                    
                elseif strcmp(Stro.PSfxn{Peak}, 'PsuedoVoigtGuassConstrain')
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:9) );
                    [w,N,x0,c,N1,x1,N2,x2,c2] = deal( temp{:} );
                    peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                    peak_2 = w.*N1/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c).^2) + (1-w).*N1/c.*2/pi.*(1+4.*((x-x1)/c).^2).^-1;
                    peak_3 = N2.*exp(-((x-x2)/c2).^2);
                    
                elseif strcmp(Stro.PSfxn{Peak}, 'PVIIKa1Ka2')
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:6) );
                    [N,x0,m,m2,f,f2] = deal( temp{:} );
                    peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                    peak_2 = N/1.9.*2.*((2.^(1/m2)-1).^0.5)./f2./(pi.^0.5).*gamma(m2)./gamma(m2-0.5).*(1+4.*(2.^(1/m2)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0)).^2)./f2.^2).^(-m2);
                    
                elseif strcmp(Stro.PSfxn{Peak}, 'PVIIKa1Ka2fsame')
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:5) );
                    [N,x0,m,m2,f] = deal( temp{:} );
                    peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                    peak_2 = N/1.9.*2.*((2.^(1/m2)-1).^0.5)./f./(pi.^0.5).*gamma(m2)./gamma(m2-0.5).*(1+4.*(2.^(1/m2)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0)).^2)./f.^2).^(-m2);
                    
                elseif strcmp(Stro.PSfxn{Peak}, 'PVIIKa1Ka2bothsame')

                    temp = num2cell( Stro.fit_parms{i}(Peak,1:5) );
                    temp2 = num2cell( Stro.fit_parms_error{i}(Peak,1:4) );
                    [N,N2,x0,m,f] = deal( temp{:} );
                    [dN,dx0,dm,df] = deal( temp2{:} );
                    dI = sqrt( double(dI_dN(N,x0,m,f,x)).^2*dN^2 + double(dI_dx0(N,x0,m,f,x)).^2*dx0^2 + double(dI_dm(N,x0,m,f,x)).^2*dm^2 + double(dI_df(N,x0,m,f,x)).^2*df^2 );
                    peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                    peak_2 = N2/1.9.*2.*((2.^(1/m)-1).^0.5)./f./(pi.^0.5).*gamma(m)./gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0)).^2)./f.^2).^(-m);
                elseif strcmp( Stro.PSfxn{Peak}, 'PVIIKa1Ka2bothsame_Doublet' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:8) );
                    [N,x0,m,f,N1,x1,m1,f1] = deal( temp{:} );                    
                    peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/f/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x0).^2)/f.^2).^(-m);
                    peak_2 = N/1.9.*2.*((2.^(1/m)-1).^0.5)./f./(pi.^0.5).*gamma(m)./gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x0)).^2)./f.^2).^(-m);
                    peak_3 = N1.*2.*((2.^(1./m1)-1).^0.5)./f1./(pi.^0.5).*gamma(m1)./gamma(m1-0.5).*(1+4.*(2.^(1./m1)-1).*((x-x1).^2)./f1.^2).^(-m1);
                    peak_4 = N1./1.9.*2.*((2.^(1./m1)-1).^0.5)./f1./(pi.^0.5).*gamma(m1)./gamma(m1-0.5).*(1+4.*(2.^(1./m1)-1).*((x-FitDiffractionDataOriginal.Ka2fromKa1(x1)).^2)./f1.^2).^(-m1);
                elseif strcmp( Stro.PSfxn{Peak}, 'psuedo_voigt_triple' )
                    temp = num2cell( Stro.fit_parms{i}(Peak,1:8) );
                    [N,c,w,x0,N1,x1,N2,x2] = deal( temp{:} );
                    peak_1 = w.*N/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x0)/c).^2) + (1-w).*N/c.*2/pi.*(1+4.*((x-x0)/c).^2).^-1;
                    peak_2 = w.*N1/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x1)/c).^2) + (1-w).*N1/c.*2/pi.*(1+4.*((x-x1)/c).^2).^-1;
                    peak_3 = w.*N2/c.*(2.*(log(2)).^.5)/pi.^.5.*exp(-4.*log(2).*((x-x2)/c).^2) + (1-w).*N2/c.*2/pi.*(1+4.*((x-x2)/c).^2).^-1;
                end
                 Intensity(1,i) = sum(peak_1 .* (x(2)-x(1)) );
                 Intensity(2,i) = sum(peak_2 .* (x(2)-x(1)) );
                 Intensity(3,i) = sum(peak_3 .* (x(2)-x(1)) );
            end
            
            Stro.constructFigure(7,'Scan Number','Intensity (a.u.)','Intensity vs Fit Number'); 
            plot(1:size(Stro.data_fit,1),Intensity(1,:),'-kx','markersize',10)
            plot(1:size(Stro.data_fit,1),Intensity(2,:),'-bo','markersize',10)
            plot(1:size(Stro.data_fit,1),Intensity(3,:),'-r.','markersize',10)

        end
        function plotError(Stro)
            for i=1:length( Stro.fit_results )
                yo  = Stro.fit_results{i}(2,:)';
                
                for j=1:length(Stro.PSfxn)
                    
                    yc  = Stro.fit_results{i}(3+j,:)' + Stro.fit_results{i}(3,:)';
                    w   = sqrt(1./yc);
                    
                    Rw(i,j) = sqrt( sum((w.*(yo - yc)).^2) / sum((w.*yc).^2)) * 100;
                    R(i,j) = (sum(abs(yo-yc))./(sum(yo)))*100;
                    Rexp(i,j) = sqrt( (length(yc)-5) / sum((w.*yc).^2)) * 100;
                end
            end
            
            for j=1:length(Stro.PSfxn)
               figure(8+j)
               
               plot([1:i], Rexp(:,j),'k',[1:i], R(:,j),'-bx',[1:i], Rw(:,j),'-ro','markersize',12,'linewidth',1.5)   
               leg = legend('R_{exp}','R_p','R_w');
               xlim([0 i+1])
               set(leg,'FontSize',16);
               set(leg,'Location','NorthEastOutside');
               title('Fitting Error', 'fontsize', 16)
               xlabel('Scan Number', 'fontsize', 16)
               ylabel('Error (%)', 'fontsize', 16)
            end
	end
        function WilliamsonHall(Stro) 
            
            for dataSet=1:length( Stro.fit_results )
                x = Stro.fit_results{dataSet}(1,:)';
                for i=1:length(Stro.PSfxn)
                    if any(strcmp(strsplit(Stro.PSfxn{i},'_'),'asymmPVIIKa1Ka2'))
                        temp = num2cell( Stro.fit_parms{dataSet}(i,1:6) );
                        [x01,I1L,m1L,F1L,I1R,m1R]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);                
                    elseif any(strcmp(strsplit(Stro.PSfxn{i},'_'),'asymmPVII'))
                        temp = num2cell( Stro.fit_parms{dataSet}(i,1:6) );
                        [x01,I1L,m1L,F1L,I1R,m1R]  = deal( temp{:} );
                        peak_1 = FitDiffractionDataOriginal.AsymmCutoff(x01,1,x).*I1L.*FitDiffractionDataOriginal.C4(m1L)/F1L.*(1+4.*(2.^(1/m1L)-1).*(x-x01).^2/F1L.^2).^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x).*I1R.*FitDiffractionDataOriginal.C4(m1R)/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).*(1+4.*(2.^(1/m1R)-1).*(x-x01).^2/(F1L.*I1R/I1L.*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L)).^2).^(-m1R);
                    elseif strcmp(Stro.PSfxn{i}, 'PVIIKa1Ka2bothsame')
                        temp = num2cell( Stro.fit_parms{dataSet}(i,1:4) );
                        [N, x01,m,F1L] = deal( temp{:} );
                        peak_1 = N.*2.*((2.^(1/m)-1).^0.5)/F1L/(pi.^0.5).*gamma(m)/gamma(m-0.5).*(1+4.*(2.^(1/m)-1).*((x-x01).^2)/F1L.^2).^(-m);                    
                    elseif strcmp(Stro.PSfxn{i}, 'LorentzianKa1Ka2')
                        temp = num2cell( Stro.fit_parms{dataSet}(i,1:3) );
                        [N, x01, F1L] = deal( temp{:} );
                        peak_1 = N*1./pi.* (0.5*F1L./((x-x01).^2 + (0.5*F1L).^2));
                    end


                    Position(i) = x01;
                    B(i) = sum(peak_1) * (x(2)-x(1)) / max(peak_1);
                    %B(i) = F1L;
                end

%                 Position
%                 B

                Stro.IntegralBreadth(:,dataSet) = B';
                y = B .* cos(Position / 2 * pi() / 180 );
                x = 4 * sin(Position / 2 * pi() / 180 );
                y = y';
                x = x';

                g = fittype('Eta * x + Lambda','coefficients',{'Eta','Lambda'},'independent','x');
                [fittedmodel,fittedmodelGOF] = fit(x,y,g);       

                fittedmodelCI = confint(fittedmodel);
                
                Stro.MicroStrain(dataSet) = fittedmodel.Eta; 
                Stro.MicroStrainError(dataSet) = abs( fittedmodel.Eta - fittedmodelCI(1,1) );
                Stro.ParticleSize(dataSet) = fittedmodel.Lambda;
                Stro.ParticleSizeError(dataSet) = abs( fittedmodel.Lambda - fittedmodelCI(1,2) );
            end

            ax1 = subplot(1,2,1);
            errorbar(1:size(Stro.data_fit,1),Stro.MicroStrain, Stro.MicroStrainError,'-mx','markersize',10,'linewidth',1.2);
            
            ylabel('Microstrain','FontSize',14)
            xlabel('Scan number','FontSize',14)

            ax2 = subplot(1,2,2);
            errorbar(1:size(Stro.data_fit,1),Stro.ParticleSize, Stro.ParticleSizeError,'-ko','markersize',10,'linewidth',1.2);
            ylabel('Particle size','FontSize',14)
            xlabel('Scan number','FontSize',14)

        end
    end
    
    
    methods(Hidden)
        function fitXRD(Stro, data, position, fitrange, SP, LB, UB)
           
            if strcmp(Stro.plotyn,'y')
                fig1 = figure(1); clf
                ha(1) = subplot('Position',[0.1 0.35 0.8 0.6]);
                plot(data(1,:),data(2,:),'+')
                hold on;
            end

            % BACKGROUND FITTING
            R = 1; %in points each direction for the background averaging, must be integer
            for i=1:length(Stro.bkgd2th); 
                bkgd2thX(i)=Stro.Find2theta(data(1,:),Stro.bkgd2th(i)); 
            end;
            for i=1:length(Stro.bkgd2th); bkgdInt(i)=mean(data(2,(bkgd2thX(i)-R:bkgd2thX(i)+R))); end;

            % To input in selected points regardless of how close
% for i=1:length(Stro.bkgd2th); bkgdInt(i)=data(2,bkgd2thX(i)); end

            
            
            P = polyfit(Stro.bkgd2th,bkgdInt,Stro.PolyOrder);
            if strcmp(Stro.plotyn,'y')
                plot(data(1,:),polyval(P,data(1,:)),'k-') %to check okay
                plot(Stro.bkgd2th,bkgdInt,'ko');
            end
            % Make new matrix with NB ("no background")
            dataNB = data;
            dataNB(2,:) = data(2,:) - polyval(P,data(1,:));
           
            %make matrix with all data for final output 
            % column 1 = 2theta
            % column 2 = measured intensity
            % column 3 = background function
            % column 4 = 1st peak w/o background...
            % column 5 = 2nd peak w/o background..., etc.
            fitteddata=data;
            fitteddata(3,:)=polyval(P,data(1,:));

            
            % ITERATE PEAK FITTING FOR EACH PEAK
            for i=1:length(position)
                positionX(i) = FitDiffractionDataOriginal.Find2theta(dataNB(1,:),position(i));
                minr=positionX(i)-fitrange(i)/2;
                maxr=positionX(i)+fitrange(i)/2;
                fitdata{i} = dataNB(:,minr:maxr);
  
                %figure(3); plot(fitdata{i}(1,:),fitdata{i}(2,:));
                
                [g,SPdefault,LBdefault,UBdefault]=Stro.MakeFxn(char(Stro.PSfxn{i}),fitdata{i},position(i));
                coefficients{i}=coeffnames(g);
                  len=length(coefficients{1});  
          if exist('InputPSfxn','var')==1
                  InputPSfxn=evalin('base','InputPSfxn'); 
          end
if strcmp(Stro.inputSP,'n')==1;
%     clearvars global InputPSfxn
    evalin('base',['clear InputPSfxn']) 
end
if and(Stro.inputSP=='y',exist('InputPSfxn','var')==1);          
    for ck=1:length(Stro.PSfxn);           
                 if strcmp(InputPSfxn{ck},Stro.PSfxn(ck))==0
    error('PSfxn coefficients have not been updated since last change, either update them manually or switch to inputSP=n. To update them quickly take the original_SP and copy them to fit_initial AFTER running the program again with inputSP=n' )
                 end
    end
end
                % these lines were modified for the NKN poling (June 25 2008)
                if and(Stro.inputSP=='y',isempty(Stro.fit_initial)==1)
                        error(' fit_initial is empty, you can either input in the parameters or turn off inputSP ') % this was implemented to catch the delete of fit_initial when entering new data
                
                elseif Stro.inputSP~='y'
                SP{i}=SPdefault; 
                UB{i}=UBdefault;
                LB{i}=LBdefault;
                
                elseif length(Stro.PSfxn)==1
                    SP=Stro.fit_initial(1,:);
                    UB=Stro.fit_initial(2,:);
                    LB=Stro.fit_initial(3,:);
                else
                    SP{i}=Stro.fit_initial{1,i};
                    UB{i}=Stro.fit_initial{2,i};
                    LB{i}=Stro.fit_initial{3,i};
                end
%             assignin('base','SP',SP)
%             assignin('base','UB',UB)
%             assignin('base','LB',LB)
               
                s = fitoptions('Method','NonlinearLeastSquares','StartPoint',SP{i},'Lower',LB{i},'Upper',UB{i});
                [fittedmodel{i},fittedmodelGOF{i}]=fit(fitdata{i}(1,:)',fitdata{i}(2,:)',g,s);
                fittedmodelCI{i} = confint(fittedmodel{i}, Stro.level);
                
                % store fitted data, aligned appropriately in the column
                fitteddata(i+3,minr:maxr)=fittedmodel{i}(fitdata{i}(1,:));

                if strcmp(Stro.plotyn,'y')
                    plot(fitdata{i}(1,:),fittedmodel{i}(fitdata{i}(1,:))'+polyval(P,fitdata{i}(1,:)),'-g');
                    pause(0.05);
                end
            end

            if strcmp(Stro.plotyn,'y')
                hold off;
                ha(2) = subplot('Position',[0.1 0.1 0.8 0.2]); %plot error
                hold on;
                for i=1:length(position)
                plot(fitdata{i}(1,:),fitdata{i}(2,:)-fittedmodel{i}(fitdata{i}(1,:))','-g');
                end
                hold off;
                linkaxes( ha, 'x' );
            end
            
            Stro.Fdata = fitteddata;
            Stro.Fmodel = fittedmodel;
            Stro.Fcoeff = coefficients;
            Stro.FmodelGOF = fittedmodelGOF;
            Stro.FmodelCI = fittedmodelCI; 

            if Stro.inputSP~='y'
            Stro.original_SP(:)=[];
            Stro.fit_initial(:)=[];
for sp=1:length(SP(:)');
            Stro.original_SP{1,sp}=SP{1,sp};
            Stro.original_SP{2,sp}=UB{1,sp};
            Stro.original_SP{3,sp}=LB{1,sp};
            Stro.fit_initial{1,sp}=SP{1,sp};
            Stro.fit_initial{2,sp}=UB{1,sp};
            Stro.fit_initial{3,sp}=LB{1,sp};    
end

           
            end
                       
        end
        function readFile(Stro,index,fid)
                       
            for i=1:Stro.skiplines
                fgetl(fid);
            end
            if or(strcmp( Stro.suffix, 'csv'), strcmp( Stro.suffix, '.csv'))
                datain = xlsread(fid,'A:B');
                datain = transpose(datain);
            elseif or(strcmp( Stro.suffix, 'xy'), strcmp( Stro.suffix, '.xy'))
                datain = fscanf(fid,'%f',[2 ,inf]); % change this back for other dataset
            elseif or(strcmp( Stro.suffix, 'fxye'), strcmp( Stro.suffix, '.fxye'))
                datain = fscanf(fid,'%f',[3 ,inf]);
                datain(1,:) = datain(1,:) ./ 100;
            elseif or(strcmp( Stro.suffix, 'chi'),strcmp( Stro.suffix, '.chi'))
                fgetl(fid);fgetl(fid);fgetl(fid);fgetl(fid);
                datain = fscanf(fid,'%f',[2 ,inf]);
            else
                datain = fscanf(fid,'%f',[2 ,inf]);
            end
            
            fclose(fid);

            try
                Stro.data_fit(index,1);
                Stro.data_fit = [];
            catch
            end
            
            Stro.two_theta = datain(1,:);
            Stro.data_fit(index,:) = datain(2,:);
        end
        function readWithHeader(Stro,fileIndex,inFile)
            
            fid = fopen(inFile,'r');
            index = 0;
            done = 0;
            while done == 0;
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
        function getBackground(Stro)
            
            if isempty(Stro.bkgd2th)
                Stro.plotData(1)
                prompt = {'Number of background points:'};
                dlg_title = 'Select number of background points';
                num_lines = 1;
                def = {'10'};
                numpoints = newid(prompt,dlg_title,num_lines,def,'on');
                numpoints = str2double(numpoints{1});
%                 zoom on; % use mouse button to zoom in or out
%                 disp('Zoom in on a region, hit any key to proceed ');
%                 % Press Enter to get out of the zoom mode.
%                 % CurrentCharacter contains the most recent key which was pressed after opening
%                 % the figure, wait for the most recent key to become the return/enter key
%                 waitfor(gcf,'CurrentCharacter')
%                 zoom off
                points = ginput(numpoints);
%                 zoom out
            else
                points(:,1) = Stro.bkgd2th;
            end
            
            for i=1:length(points(:,1))
                if Stro.two_theta(FitDiffractionDataOriginal.Find2theta(Stro.two_theta,points(i,1))) > Stro.Max2T
                    points(i,1) = Stro.two_theta(FitDiffractionDataOriginal.Find2theta(Stro.two_theta,Stro.Max2T)-4); 
                elseif Stro.two_theta(FitDiffractionDataOriginal.Find2theta(Stro.two_theta,points(i,1))) < Stro.Min2T
                    points(i,1) = Stro.two_theta(FitDiffractionDataOriginal.Find2theta(Stro.two_theta,Stro.Min2T)+4); 
                else
                    points(i,1) = Stro.two_theta(FitDiffractionDataOriginal.Find2theta(Stro.two_theta,points(i,1)));
                end
            end

            Stro.bkgd2th = points(:,1)';
            Stro.bkgd2th = sort( Stro.bkgd2th );
        end
        function [g,SP,LB,UB]=MakeFxn(Stro,Fxn,data,position)
            %
            % function [g,SP,LB,UB]=MakeFxn(Fxn,data,position)
            % Make custom function with starting parameters (SP), default lower bounds
            %   (LB), and default upper bounds (UB). Requires inputs include desired
            %   function type (Fxn), the data within the peak fit region (data; for
            %   definition of intensity starting parameters) and the starting guess on
            %   position (position). For peak shape functions that include a Ka1 and
            %   Ka2 component, the position value is the position of the Ka1 component.
            %
            % Valid peak shape functions currently written in this program include:
            %   Gauss
            %   Lorentzian
            %   PVII
            %   PsuedoVoigt
            %   Doublets and Triplets of Above FXN
            %   To call contrains list the function followed by the word
            %   "Constrain" (all together) then underscore (_) then the
            %   variable Example: GaussConstrain_f
            
            %   asymmPVII
            %   asymmPVIIDoublet
            %   asymmPVIIDoubletConstrain_f
            %   PVIIKa1Ka2
            %   PVIIKa1Ka2fsame
            %   PVIIKa1Ka2bothsame
            %   GaussKa1Ka2
            eint=trapz(data(1,:),data(2,:));
            [u, p]=max(data(2,:));epos=data(1,p);
            ebreadth=trapz(data(1,:),data(2,:))/max(data(2,:));         

            if nargin~=4
                error('Incorrect number of arguments')   
            
%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn%Single Fxn            
            elseif strcmp(Fxn,'Gauss')==1
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))','coefficients',{'N1','x1','f1'},'independent','x');
                %'N1','x1','f1'
                SP= [eint epos ebreadth];
                UB= [eint*50 epos+ebreadth ebreadth*10];
                LB= [0 epos-ebreadth 0.0001];
                                   
             elseif strcmp(Fxn, 'Lorentzian')==1
                g = fittype('N1*1/pi* (0.5*f1/((x-x1)^2+(0.5*f1)^2))','coefficients',{'N1','x1','f1'},'independent','x');
                %'N1','x1','f1'
                SP = [ eint epos ebreadth+18];
                UB = [ 10*eint epos+5 ebreadth*10];
                LB = [ 0 epos-5 0];             
                
            elseif strcmp(Fxn,'PVII')==1
               g = fittype('N1 * 2 * ((2^(1/m1)-1)^0.5) / f1 / (pi^0.5) * gamma(m1) / gamma(m1-0.5) * (1+4*(2^(1/m1)-1)*((x-x1)^2)/f1^2)^(-m1)','coefficients',{'N1','x1','f1','m1'},'independent','x');
                % 'N1','x1','f1','m1' 
                SP= [eint epos  ebreadth 2];
                UB= [eint*10 epos+5 ebreadth+10 15 ];
                LB= [0 epos-5 0.0005 0.51 ];                
              
            elseif strcmp(Fxn,'PsuedoVoigt')==1
                g = fittype('N1*((w1*(2/pi)*(1/f1)*1/(1+(4*(x-x1)^2/f1^2))) + ((1-w1)*(2*sqrt(log(2))/(sqrt(pi)))*1/f1*exp(-log(2)*4*(x-x1)^2/f1^2)))','coefficients',{'N1','x1','f1','w1'},'independent','x');
                %'N1','x1','f1','w1'
                SP= [max(data(2,:))/10 position 0.02 0.5 ];
                UB= [1.2* max(data(2,:)) position+0.02 0.07 1  ];
                LB= [0 position-0.02 0.001 0  ]; 
                
            elseif strcmp(Fxn,'asymmPVII')==1
                g = fittype('FitDiffractionDataOriginal.AsymmCutoff(x0,1,x)*IL*FitDiffractionDataOriginal.C4(mL)/FL*(1+4*(2^(1/mL)-1)*(x-x0)^2/FL^2)^(-mL) + FitDiffractionDataOriginal.AsymmCutoff(x0,2,x)*IR*FitDiffractionDataOriginal.C4(mR)/(FL*IR/IL*FitDiffractionDataOriginal.C4(mR)/FitDiffractionDataOriginal.C4(mL))*(1+4*(2^(1/mR)-1)*(x-x0)^2/(FL*IR/IL*FitDiffractionDataOriginal.C4(mR)/FitDiffractionDataOriginal.C4(mL))^2)^(-mR)',...
                    'coefficients',{'x0','IL','mL','FL','IR','mR'},'independent','x');
                % 'x0','IL','mL','FL','IR','mR'
                SP= [position max(data(2,:))/80 2 0.02 max(data(2,:))/80 2];
                UB= [position+0.04 max(data(2,:))/10 30 0.2 max(data(2,:))/10 30];
                LB= [position-0.04 0 0.1 0.001 0 0.1];

%Doublet FXN%Doublet FXN%Doublet FXN%Doublet FXN%Doublet FXN%Doublet FXN%Doublet FXN%Doublet FXN
            elseif strcmp(Fxn,'GaussDoublet')==1
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+N2*((2*sqrt(log(2)))/(sqrt(pi)*f2)*exp(-4*log(2)*((x-x2)^2/f2^2)))','coefficients',{'N1','x1','f1','N2','x2','f2'},'independent','x');
                % 'N1','x1','f1','N2','x2','f2'
                SP= [max(data(2,:)) position-0.025 0.02 max(data(2,:)) position+0.025 0.02];
                UB= [max(data(2,:))*2 position+.01 0.5 max(data(2,:))*2 position+0.05 0.1];
                LB= [0 position-0.09 0.001 0 position 0.001];
           
            elseif strcmp(Fxn,'LorentzianDoublet')==1              
                g = fittype('N1*1/pi* (0.5*f1/((x-x1)^2+(0.5*f1)^2)) + N2*1/pi* (0.5*f2/((x-x2)^2+(0.5*f2)^2))','coefficients',{'N1','x1','f1','N2','x2','f2'},'independent','x');
                %'N1','x1','f1','N2','x2' 'f2'
                SP = [ max(data(2,:))/10 position-.025 0.064 max(data(2,:))/10 position+.025 0.064];
                UB = [ 2*max(data(2,:)) position 0.067 2*max(data(2,:)) position+.06 0.09];
                LB = [ 0 position-.06 0.001 0 position 0.001];
 
           elseif strcmp(Fxn,'PVIIDoublet')==1     
                g = fittype('N1 * 2 * ((2^(1/m1)-1)^0.5) / f1 / (pi^0.5) * gamma(m1) / gamma(m1-0.5) * (1+4*(2^(1/m1)-1)*((x-x1)^2)/f1^2)^(-m1) + N2 * 2 * ((2^(1/m2)-1)^0.5) / f2 / (pi^0.5) * gamma(m2) / gamma(m2-0.5) * (1+4*(2^(1/m2)-1)*((x-x2)^2)/f2^2)^(-m2)','coefficients',{'N1','x1','f1','m1','N2','x2','f2','m2'},'independent','x');
                % 'N1','x1','f1','m1','N2','x2','f2','m2'
                SP= [max(data(2,:))/10 position-.025 .045 1.5 max(data(2,:))/10 position+.025 0.03 1.5 ];
                UB= [5*max(data(2,:)) position-.01 .06 15 5*max(data(2,:)) position+.05 0.05 15 ];
                LB= [0 position-0.08 0.001 .51 0 position 0.001 .51 ];            
            
            elseif strcmp(Fxn,'PsuedoVoigtDoublet')==1
                g = fittype('w1*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1','coefficients',{'N1','x1','f1','w1','N2','x2','f2','w2'},'independent','x');
                %{'N1','x1','f1','w1','N2','x2','f2','w2'}
                SP= [max(data(2,:)) position-0.025 .02 0.5 max(data(2,:)) position+.03 .02 .5];
                UB= [(2*max(data(2,:))) (position) (.1) (1) (2*max(data(2,:))) (position+0.03)+.04 (.1) (1)];
                LB= [0 (position-0.025)-.04 0.001 0 0 position 0.001 0];                      
                
            elseif strcmp(Fxn,'asymmPVIIDoublet')==1
                g = fittype('FitDiffractionDataOriginal.AsymmCutoff(x01,1,x)*I1L*FitDiffractionDataOriginal.C4(m1L)/F1L*(1+4*(2^(1/m1L)-1)*(x-x01)^2/F1L^2)^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x)*I1R*FitDiffractionDataOriginal.C4(m1R)/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))*(1+4*(2^(1/m1R)-1)*(x-x01)^2/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))^2)^(-m1R) + FitDiffractionDataOriginal.AsymmCutoff(x02,1,x)*I2L*FitDiffractionDataOriginal.C4(m2L)/F2L*(1+4*(2^(1/m2L)-1)*(x-x02)^2/F2L^2)^(-m2L)+FitDiffractionDataOriginal.AsymmCutoff(x02,2,x)*I2R*FitDiffractionDataOriginal.C4(m2R)/(F2L*I2R/I2L*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L))*(1+4*(2^(1/m2R)-1)*(x-x02)^2/(F2L*I2R/I2L*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L))^2)^(-m2R)',...
                    'coefficients',{'x01','I1L','m1L','F1L','I1R','m1R','x02','I2L','m2L','F2L','I2R','m2R'},'independent','x');                                   
                                 %  'x01','I1L','m1L','F1L','I1R','m1R','x02','I2L','m2L','F2L','I2R','m2R
                SP= [position-0.04 max(data(2,:))/140 1 0.02 4000 1 position+0.025 max(data(2,:))/30 1 0.03 max(data(2,:))/140 1];
                UB= [position-.01 max(data(2,:))/10 15 0.1 500 10 position+0.08 max(data(2,:))/10 10 0.2 max(data(2,:))/10 10];
                LB= [position-0.08 1 0 0.001 0 1 position+.01 0 1 0.001 0 1];                
              
         %Constrained-DoubletFxn%Constrained-DoubletFxn%Constrained-DoubletFxn%Constrained-DoubletFxn

            elseif strcmp(Fxn,'GaussDoubletConstrain_N')==1                
                g = fittype('N*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+N*((2*sqrt(log(2)))/(sqrt(pi)*f2)*exp(-4*log(2)*((x-x2)^2/f2^2)))','coefficients',{'N','x1','f1','x2','f2'},'independent','x');
                % N x1 f1 x2 f2
                SP= [max(data(2,:)) position-0.025 0.02 position+0.025 0.02];
                UB= [max(data(2,:))*2 position 0.1 position+0.05 0.1];
                LB= [0 position-0.05 0.001 position 0.001];  
                
            elseif strcmp(Fxn,'GaussDoubletConstrain_f')==1              
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f)*exp(-4*log(2)*((x-x1)^2/f^2)))+N2*((2*sqrt(log(2)))/(sqrt(pi)*f)*exp(-4*log(2)*((x-x2)^2/f^2)))','coefficients',{'N1','x1','f','N2','x2'},'independent','x');
                % N1 x1 f N2 x2
                SP= [max(data(2,:)) position-0.025 0.02 max(data(2,:)) position+0.025];
                UB= [max(data(2,:))*2 position 0.1 max(data(2,:))*2 position+0.05];
                LB= [0 position-0.05 0.001 0 position];                      
   
            elseif strcmp(Fxn,'PVIIDoubletConstrain_N')==1          
                g = fittype('N * 2 * ((2^(1/m1)-1)^0.5) / f1 / (pi^0.5) * gamma(m1) / gamma(m1-0.5) * (1+4*(2^(1/m1)-1)*((x-x1)^2)/f1^2)^(-m1) + N * 2 * ((2^(1/m2)-1)^0.5) / f2 / (pi^0.5) * gamma(m2) / gamma(m2-0.5) * (1+4*(2^(1/m2)-1)*((x-x2)^2)/f2^2)^(-m2)','coefficients',{'N','x1','f1','m1','x2','f2','m2'},'independent','x');
                % {'N1','x1','f1','m1','x2','f2','m2'}
                SP= [max(data(2,:))/10 position-0.03 .016 .9 position+0.02 0.0134818 0.9];
                UB= [5*max(data(2,:)) position-.005 0.05 15 position+0.04 0.05 15];
                LB= [0 position-0.04 0.51 0.1 position-.01 0 0.51];                
   
            elseif strcmp(Fxn,'PVIIDoubletConstrain_f')==1              
                g = fittype('N1 * 2 * ((2^(1/m1)-1)^0.5) / f / (pi^0.5) * gamma(m1) / gamma(m1-0.5) * (1+4*(2^(1/m1)-1)*((x-x1)^2)/f^2)^(-m1) + N2 * 2 * ((2^(1/m2)-1)^0.5) / f / (pi^0.5) * gamma(m2) / gamma(m2-0.5) * (1+4*(2^(1/m2)-1)*((x-x2)^2)/f^2)^(-m2)','coefficients',{'N1','x1','f','m1','N2','x2','m2'},'independent','x');
                % 'N1','x1','f','m1','N2','x2','m2
                SP= [max(data(2,:))/10 position-0.02 .065 2 max(data(2,:))/10 position+0.05 2];
                UB= [5*max(data(2,:)) position-0.01 0.09 15 5*max(data(2,:)) position+0.08 15];
                LB= [0 position-0.08 0.01 .51 0 position .51];
       
            elseif strcmp(Fxn,'PVIIDoubletConstrain_m')==1              
                g = fittype('N1 * 2 * ((2^(1/m)-1)^0.5) / f1 / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x1)^2)/f1^2)^(-m) + N2 * 2 * ((2^(1/m)-1)^0.5) / f2 / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x2)^2)/f2^2)^(-m)','coefficients',{'N1','x1','f1','m','N2','x2','f2'},'independent','x');
                % 'N1','x1','f1','m','N2','x2','f2'
                SP= [max(data(2,:))/10 position-.025 .045 1.5 max(data(2,:))/10 position+.025 0.03 ];
                UB= [5*max(data(2,:)) position-.01 .06 15 5*max(data(2,:)) position+.08 0.05 ];
                LB= [0 position-0.08 0.001 .51 0 position 0.001 ];                 
       
            elseif strcmp(Fxn,'PVIIDoubletConstrain_f_m')==1               
                g = fittype('N1 * 2 * ((2^(1/m)-1)^0.5) / f / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x1)^2)/f^2)^(-m) + N2 * 2 * ((2^(1/m)-1)^0.5) / f / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x2)^2)/f^2)^(-m)','coefficients',{'N1','x1','f','m','N2','x2'},'independent','x');
                % 'N1','x1','f','m','N2','x2'
                SP= [max(data(2,:))/10 position-0.02 .065 2 max(data(2,:))/10 position+0.02];
                UB= [5*max(data(2,:)) position+0.01 0.09 15 5*max(data(2,:)) position+0.05];
                LB= [0 position-0.06 0.01 0.51 0 position-0.005];                
  
            elseif strcmp(Fxn,'PsuedoVoigtDoubletConstrain_N')==1
                g = fittype('w1*N/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1','coefficients',{'N','x1','f1','w1','x2','f2','w2'},'independent','x');
                %{'N','x1','f1','w1','x2','f2','w2'}
                SP= [max(data(2,:)) position-0.02 .025373 .54 position+.02 .02 .54];
                UB= [2*max(data(2,:)) (position-0.02)+.03 .1 1 (position+0.02)+.03 .05 1 ];
                LB= [0 (position-0.02)-.03 0.001 0 (position+0.02)-.03 0.001 0];                                      
       
            elseif strcmp(Fxn,'PsuedoVoigtDoubletConstrain_f')==1
                g = fittype('w1*N1/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f)^2) + (1-w1)*N1/f*2/pi*(1+4*((x-x1)/f)^2)^-1 + w2*N2/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f)^2) + (1-w2)*N2/f*2/pi*(1+4*((x-x2)/f)^2)^-1','coefficients',{'N1','x1','f','w1','N2','x2','w2'},'independent','x');
                %{'N1','x1','f','w1','N2','x2','w2'}
                SP= [max(data(2,:)) position-0.025 .025373 0.5 max(data(2,:)) position+.05 .9];
                UB= [2*max(data(2,:)) (position-0.025)+.02 .1 1 2*max(data(2,:)) (position+0.05)+.04 1];
                LB= [0 (position-0.025)-.04 0.001 0 0 (position+0.05)-.05 0];                      
      
            elseif strcmp(Fxn,'PsuedoVoigtDoubletConstrain_w')==1
                g = fittype('w*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1','coefficients',{'N1','x1','f1','w','N2','x2','f2'},'independent','x');
                %{N1','x1','f1','w','N2','x2','f2}
                SP= [max(data(2,:)) position-0.02 .045373 .5 max(data(2,:)) position+.02 .03 ];
                UB= [2*max(data(2,:)) (position-0.02)+.03 .1 1 2*max(data(2,:)) (position+0.02)+.03 .05 ];
                LB= [0 (position-0.02)-.03 0.001 0 0 (position+0.02)-.03 0.001 ];                                      
 
            elseif strcmp(Fxn,'PsuedoVoigtDoubletConstrain_f_w')==1
                g = fittype('w*N1/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f)^2) + (1-w)*N1/f*2/pi*(1+4*((x-x1)/f)^2)^-1 + w*N2/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f)^2) + (1-w)*N2/f*2/pi*(1+4*((x-x2)/f)^2)^-1','coefficients',{'N1','x1','f','w','N2','x2'},'independent','x');
                %{N1','x1','f','w','N2','x2'}
                SP= [max(data(2,:)) position-0.02 .025373 .54 max(data(2,:)) position+.02 ];
                UB= [2*max(data(2,:)) (position-0.02)+.03 .1 1 2*max(data(2,:)) (position+0.02)+.03];
                LB= [0 (position-0.02)-.03 0.001 0 0 (position+0.02)-.03];
                
            elseif strcmp(Fxn,'asymmPVIIDoubletConstrain_f')==1
                g = fittype('FitDiffractionDataOriginal.AsymmCutoff(x01,1,x)*I1L*FitDiffractionDataOriginal.C4(m1L)/F*(1+4*(2^(1/m1L)-1)*(x-x01)^2/F^2)^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x)*I1R*FitDiffractionDataOriginal.C4(m1R)/(F*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))*(1+4*(2^(1/m1R)-1)*(x-x01)^2/(F*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))^2)^(-m1R) + FitDiffractionDataOriginal.AsymmCutoff(x02,1,x)*I2L*FitDiffractionDataOriginal.C4(m2L)/F*(1+4*(2^(1/m2L)-1)*(x-x02)^2/F^2)^(-m2L)+FitDiffractionDataOriginal.AsymmCutoff(x02,2,x)*I2R*FitDiffractionDataOriginal.C4(m2R)/(F*I2R/I2L*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L))*(1+4*(2^(1/m2R)-1)*(x-x02)^2/(F*I2R/I2L*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L))^2)^(-m2R)',...
                                     'coefficients',{'x01','I1L','m1L','F','I1R','m1R','x02','I2L','m2L','I2R','m2R'},'independent','x');
                % 'x01','I1L','m1L','F','I1R','m1R','x02','I2L','m2L','I2R','m2R'
                SP= [position-0.025 max(data(2,:))/140 1 0.01 max(data(2,:))/30 1 position+0.025 max(data(2,:))/30 1 max(data(2,:))/140 1];
                UB= [position max(data(2,:))/10 10 0.2 max(data(2,:))/10 10 position+0.08 max(data(2,:))/10 10 max(data(2,:))/10 10];
                LB= [position-0.08 0 1 0.001 0 1 position 0 1 0 1];           
                
            elseif strcmp(Fxn,'asymmPVIIDoubletConstrain_m')==1
                g = fittype('FitDiffractionDataOriginal.AsymmCutoff(x01,1,x)*I1L*FitDiffractionDataOriginal.C4(m1L)/F1L*(1+4*(2^(1/m1L)-1)*(x-x01)^2/F1L^2)^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x)*I1R*FitDiffractionDataOriginal.C4(m1R)/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))*(1+4*(2^(1/m1R)-1)*(x-x01)^2/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))^2)^(-m1R) + FitDiffractionDataOriginal.AsymmCutoff(x02,1,x)*I2L*FitDiffractionDataOriginal.C4(m1L)/F2L*(1+4*(2^(1/m1L)-1)*(x-x02)^2/F2L^2)^(-m1L)+FitDiffractionDataOriginal.AsymmCutoff(x02,2,x)*I2R*FitDiffractionDataOriginal.C4(m1R)/(F2L*I2R/I2L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))*(1+4*(2^(1/m1R)-1)*(x-x02)^2/(F2L*I2R/I2L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))^2)^(-m1R)',...
                    'coefficients',{'x01','I1L','m1L','F1L','I1R','m1R','x02','I2L','F2L','I2R'},'independent','x');                                   
                                 %  'x01','I1L','m1L','F1L','I1R','m1R','x02','I2L','m2L','F2L','I2R','m2R
                SP= [position-0.09 max(data(2,:))/140 2 0.04 80 2 position max(data(2,:))/140 0.03 max(data(2,:))/10 2];
                UB= [position-.06 max(data(2,:))/10 25 0.1 max(data(2,:))/10 25 position+0.01 max(data(2,:))/10 0.2 max(data(2,:))/10 25];
                LB= [position-0.12 0 1 0.001 0 1 position-.01 0 0.001 0 1]; 
                
                %Custom Doublet FXN
                elseif strcmp(Fxn,'asymmPVIIPsuedoVoigt')==1
                g = fittype('FitDiffractionDataOriginal.AsymmCutoff(x01,1,x)*I1L*FitDiffractionDataOriginal.C4(m1L)/F1L*(1+4*(2^(1/m1L)-1)*(x-x01)^2/F1L^2)^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x)*I1R*FitDiffractionDataOriginal.C4(m1R)/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))*(1+4*(2^(1/m1R)-1)*(x-x01)^2/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))^2)^(-m1R) + N1*((w1*(2/pi)*(1/f1)*1/(1+(4*(x-x1)^2/f1^2))) + ((1-w1)*(2*sqrt(log(2))/(sqrt(pi)))*1/f1*exp(-log(2)*4*(x-x1)^2/f1^2)))',...
                    'coefficients',{'x01','I1L','m1L','F1L','I1R','m1R','N1','x1','f1','w1'},'independent','x');                                   
                                 %  'x01','I1L','m1L','F1L','I1R','m1R',
                SP= [position+0.03 max(data(2,:))/140 2 0.02 80 2 max(data(2,:))/140 position-.04 0.025 0.5];
                UB= [position+0.04 max(data(2,:))/10 30 0.2 max(data(2,:))/10 30 1.2* max(data(2,:)) position 0.08 1];
                LB= [position+.005 0 1 0.001 0 1 0 position-0.08 0.001 0];                  
                
%Triplet FXN%Triplet FXN%Triplet FXN%Triplet FXN%Triplet FXN%Triplet FXN%Triplet FXN%Triplet FXN%Triplet FXN%Triplet FXN

            elseif strcmp(Fxn,'GaussTriplet')==1
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+N2*((2*sqrt(log(2)))/(sqrt(pi)*f2)*exp(-4*log(2)*((x-x2)^2/f2^2)))+N3*((2*sqrt(log(2)))/(sqrt(pi)*f3)*exp(-4*log(2)*((x-x3)^2/f3^2)))','coefficients',{'N1','x1','f1','N2','x2','f2','N3','x3','f3'},'independent','x');
                % 'N1','x1','f1','N2','x2','f2','N3','x3','f3'
                SP= [max(data(2,:)) position-0.05 0.02 max(data(2,:)) position 0.02 max(data(2,:)) position+0.05 0.02];
                UB= [max(data(2,:))*2 position-.01 0.5 max(data(2,:))*2 position+.01 0.1  max(data(2,:))*2 position+0.08 0.1];
                LB= [0 position-0.1 0.001 0 position-.01 0.001 0 position+0.01 0.001];
             
            elseif strcmp(Fxn,'GaussTriplet_aspRatio')==1
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+N2*((2*sqrt(log(2)))/(sqrt(pi)*f2)*exp(-4*log(2)*((x-x2)^2/f2^2)))+N3*((2*sqrt(log(2)))/(sqrt(pi)*f3)*exp(-4*log(2)*((x-x3)^2/f3^2)))','coefficients',{'N1','x1','f1','N2','x2','f2','N3','x3','f3'},'independent','x');
                % 'N1','x1','f1','N2','x2','f2','N3','x3','f3'
                aspRatio=1.02935;
                HaspRatio=((aspRatio-1)/2)+1;% 1/2 of aspect ratio
                FaspRatio=((aspRatio-1)/4)+1; % 1/4 of aspect ratio
                SaspRatio=((aspRatio-1)/8)+1; % 1/6 of aspect ratio
                SP= [max(data(2,:)) position/HaspRatio 0.02 max(data(2,:)) position 0.02 max(data(2,:)) position*HaspRatio 0.02];
                UB= [max(data(2,:))*2 position/FaspRatio 0.5 max(data(2,:))*2 position*SaspRatio 0.1  max(data(2,:))*2 position*aspRatio 0.1];
                LB= [0 position/aspRatio 0.001 0 position/SaspRatio 0.001 0 position/FaspRatio 0.001];               
               
            elseif strcmp(Fxn,'LorentzianTriplet')==1
                g = fittype('N1*1/pi* (0.5*f1/((x-x1)^2+(0.5*f1)^2)) + N2*1/pi* (0.5*f2/((x-x2)^2+(0.5*f2)^2))+N3*1/pi* (0.5*f3/((x-x3)^2+(0.5*f3)^2))','coefficients',{'N1','x1','f1','N2','x2','f2','N3','x3','f3'},'independent','x');
                % 'N1','x1','f1','N2','x2','f2','N3','x3','f3'
                SP = [ max(data(2,:))/10 position-.02 0.064 max(data(2,:))/10 position+.03 0.064 max(data(2,:))/10 position-.02 0.064];
                UB = [ 2*max(data(2,:)) position+.01 0.067 2*max(data(2,:)) position+.06 0.09 2*max(data(2,:)) position+.06 0.09];
                LB = [ 0 position-.06 0.05 0 position-.01 0.03 0 position-.01 0.03];

           elseif strcmp(Fxn,'PVIITriplet')==1 
                g = fittype('N1 * 2 * ((2^(1/m1)-1)^0.5) / f1 / (pi^0.5) * gamma(m1) / gamma(m1-0.5) * (1+4*(2^(1/m1)-1)*((x-x1)^2)/f1^2)^(-m1) + N2 * 2 * ((2^(1/m2)-1)^0.5) / f2 / (pi^0.5) * gamma(m2) / gamma(m2-0.5) * (1+4*(2^(1/m2)-1)*((x-x2)^2)/f2^2)^(-m2)+N3 * 2 * ((2^(1/m3)-1)^0.5) / f3 / (pi^0.5) * gamma(m3) / gamma(m3-0.5) * (1+4*(2^(1/m3)-1)*((x-x3)^2)/f3^2)^(-m3)','coefficients',{'N1','x1','f1','m1','N2','x2','f2','m2','N3','x3','f3','m3'},'independent','x');
                % N1','x1','f1','m1','N2','x2','f2','m2','N3','x3','f3','m3
                SP= [max(data(2,:))/10 position-0.03 .016 .9 max(data(2,:))/10 position+0.02 0.013 0.9 max(data(2,:))/10 position+0.02 0.013 .9];
                UB= [5*max(data(2,:)) position-.005 0.05 5 5*max(data(2,:)) position+0.04 0.05 5 5*max(data(2,:)) position+0.04 0.05 5];
                LB= [0 position-0.04 0.001 0.51 0 position-.01 0.001 0.51 0 position-.01 0 0.001];      
          
            elseif strcmp(Fxn,'PsuedoVoigtTriplet_aspRatio')==1
                g = fittype('w1*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w3*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w3)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1','coefficients',{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3'},'independent','x');
                %{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3'}
                aspRatio=1.02935;
                HaspRatio=((aspRatio-1)/2)+1;% 1/2 of aspect ratio
                FaspRatio=((aspRatio-1)/4)+1; % 1/4 of aspect ratio
                SaspRatio=((aspRatio-1)/8)+1; % 1/6 of aspect ratio
                SP= [max(data(2,:))/2 position/HaspRatio .04035 .5 max(data(2,:))/2 position .046224 .5 max(data(2,:))/2 position*HaspRatio .01 .5];
                UB= [2*max(data(2,:)) position/FaspRatio .1 1 2*max(data(2,:)) position*SaspRatio .1 1 2*max(data(2,:)) position*aspRatio .06 1];
                LB= [0 position/aspRatio 0.001 0 0 position/SaspRatio 0.001 0 0 position/FaspRatio 0.001 0];
                
              elseif strcmp(Fxn,'PsuedoVoigtTriplet')==1
                g = fittype('w1*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w3*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w3)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1','coefficients',{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3'},'independent','x');
                %{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3'}
                SP= [max(data(2,:))/2 position-.05 .04035 .5 max(data(2,:))/2 position .046224 .5 max(data(2,:))/2 position+.08 .01 .5];
                UB= [2*max(data(2,:)) (position-.05)+.045 .1 1 2*max(data(2,:)) position+0.005 .1 1 2*max(data(2,:)) (position+0.08)+.01 .06 1];
                LB= [0 (position-0.05)-.05 0.001 0 0 position-.005 0.001 0 0 (position+.08)-.035 0.001 0];              
                
                
  %THIS WAS USED FOR TADEJ DATA      
%            elseif strcmp(Fxn,'PsuedoVoigtTriplet')==1
%                 g = fittype('w1*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w3*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w3)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1','coefficients',{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3'},'independent','x');
%                 %{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3'}
%                 SP= [max(data(2,:))/2 position-0.05 .04035 .5 max(data(2,:))/2 position .046224 .5 max(data(2,:))/2 position+0.01 .01 .5];
%                 UB= [2*max(data(2,:)) (position-.05)+.045 .1 1 2*max(data(2,:)) position+0.005 .1 1 2*max(data(2,:)) (position+0.04) .06 1];
%                 LB= [0 (position-0.05)-.01 0.001 0 0 position-.005 0.001 0 0 (position+.04)-.035 0.001 0];                             
 
     %Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN%Constrained-Triplet FXN           
     
            elseif strcmp(Fxn,'GaussTripletConstrain_N')==1
                g = fittype('N*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+N*((2*sqrt(log(2)))/(sqrt(pi)*f2)*exp(-4*log(2)*((x-x2)^2/f2^2)))+N*((2*sqrt(log(2)))/(sqrt(pi)*f3)*exp(-4*log(2)*((x-x3)^2/f3^2)))','coefficients',{'N','x1','f1','x2','f2','x3','f3'},'independent','x');
                % 'N','x1','f1','x2','f2','x3','f3'
                SP= [max(data(2,:)) position-0.025 0.02 position+0.025 0.02 position-0.025 0.02];
                UB= [max(data(2,:))*2 position+.01 0.5 position+.01 0.1 position+0.05 0.1];
                LB= [0 position-0.05 0.001 position 0.001 position+0.05 0.1];     
    
            elseif strcmp(Fxn,'GaussTripletConstrain_f')==1
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f)*exp(-4*log(2)*((x-x1)^2/f^2)))+N2*((2*sqrt(log(2)))/(sqrt(pi)*f)*exp(-4*log(2)*((x-x2)^2/f^2)))+N3*((2*sqrt(log(2)))/(sqrt(pi)*f)*exp(-4*log(2)*((x-x3)^2/f^2)))','coefficients',{'N1','x1','f','N2','x2','N3','x3'},'independent','x');
                % 'N1','x1','f','N2','x2','N3','x3'
                SP= [max(data(2,:)) position-0.025 0.02 max(data(2,:)) position+0.025 max(data(2,:)) position-0.025];
                UB= [max(data(2,:))*2 position+.01 0.5 max(data(2,:))*2 position+.01  max(data(2,:))*2 position+0.05];
                LB= [0 position-0.05 0.001 0 position 0 position+0.05];
                
            elseif strcmp(Fxn,'GaussTripletConstrain_Custom_f')==1
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+N2*((2*sqrt(log(2)))/(sqrt(pi)*f2)*exp(-4*log(2)*((x-x2)^2/f2^2)))+N3*((2*sqrt(log(2)))/(sqrt(pi)*f2)*exp(-4*log(2)*((x-x3)^2/f2^2)))','coefficients',{'N1','x1','f1','N2','x2','f2','N3','x3'},'independent','x');
                % 'N1','x1','f1','N2','x2','f2','N3','x3'
                SP= [max(data(2,:)) position-0.05 0.02 max(data(2,:)) position 0.02 max(data(2,:)) position+0.05];
                UB= [max(data(2,:))*2 position-.01 0.5 max(data(2,:))*2 position+.01 0.1  max(data(2,:))*2 position+0.08];
                LB= [0 position-0.1 0.001 0 position-.01 0.001 0 position+0.01];                
          
            elseif strcmp(Fxn,'LorentzianTripletConstrain_N')==1
                g = fittype('N*1/pi* (0.5*f1/((x-x1)^2+(0.5*f1)^2)) + N*1/pi* (0.5*f2/((x-x2)^2+(0.5*f2)^2))+N*1/pi* (0.5*f3/((x-x3)^2+(0.5*f3)^2))','coefficients',{'N','x1','f1','x2','f2','x3','f3'},'independent','x');
                % 'N','x1','f1','x2','f2','x3','f3'
                SP = [ max(data(2,:))/10 position-.02 0.064 position+.03 0.064 position-.02 0.064];
                UB = [ 2*max(data(2,:)) position+.01 0.067 position+.06 0.09 position+.06 0.09];
                LB = [ 0 position-.06 0.05 position-.01 0.03 position-.01 0.03];            
            
            elseif strcmp(Fxn,'LorentzianTripletConstrain_f')==1
                g = fittype('N1*1/pi* (0.5*f/((x-x1)^2+(0.5*f)^2)) + N2*1/pi* (0.5*f/((x-x2)^2+(0.5*f)^2))+N3*1/pi* (0.5*f/((x-x3)^2+(0.5*f)^2))','coefficients',{'N1','x1','f','N2','x2','N3','x3',},'independent','x');
                % 'N1','x1','f','N2','x2','N3','x3'
                SP = [ max(data(2,:))/10 position-.02 0.064 max(data(2,:))/10 position+.03 max(data(2,:))/10 position-.02];
                UB = [ 2*max(data(2,:)) position+.01 0.067 2*max(data(2,:)) position+.06 2*max(data(2,:)) position+.06];
                LB = [ 0 position-.06 0.05 0 position-.01 0 position-.01];            
            
            elseif strcmp(Fxn,'PVIITripletConstrain_N')==1 
                g = fittype('N * 2 * ((2^(1/m1)-1)^0.5) / f1 / (pi^0.5) * gamma(m1) / gamma(m1-0.5) * (1+4*(2^(1/m1)-1)*((x-x1)^2)/f1^2)^(-m1) + N * 2 * ((2^(1/m2)-1)^0.5) / f2 / (pi^0.5) * gamma(m2) / gamma(m2-0.5) * (1+4*(2^(1/m2)-1)*((x-x2)^2)/f2^2)^(-m2)+N * 2 * ((2^(1/m3)-1)^0.5) / f3 / (pi^0.5) * gamma(m3) / gamma(m3-0.5) * (1+4*(2^(1/m3)-1)*((x-x3)^2)/f3^2)^(-m3)','coefficients',{'N','x1','f1','m1','x2','f2','m2','x3','f3','m3'},'independent','x');
                % N','x1','f1','m1','x2','f2','m2','x3','f3','m3
                SP= [max(data(2,:))/10 position-0.03 .016 .9 position+0.02 0.013 0.9 position+0.02 0.013 .9];
                UB= [5*max(data(2,:)) position-.005 0.05 5 position+0.04 0.05 5 position+0.04 0.05 5];
                LB= [0 position-0.04 0.001 0.1 position-.01 0 position-.01 0 0.001];    
                
                elseif strcmp(Fxn,'PVIITripletConstrain_f')==1 
                g = fittype('N1 * 2 * ((2^(1/m1)-1)^0.5) / f / (pi^0.5) * gamma(m1) / gamma(m1-0.5) * (1+4*(2^(1/m1)-1)*((x-x1)^2)/f^2)^(-m1) + N2 * 2 * ((2^(1/m2)-1)^0.5) / f / (pi^0.5) * gamma(m2) / gamma(m2-0.5) * (1+4*(2^(1/m2)-1)*((x-x2)^2)/f^2)^(-m2)+N3 * 2 * ((2^(1/m3)-1)^0.5) / f / (pi^0.5) * gamma(m3) / gamma(m3-0.5) * (1+4*(2^(1/m3)-1)*((x-x3)^2)/f^2)^(-m3)','coefficients',{'N1','x1','f','m1','N2','x2','m2','N3','x3','m3'},'independent','x');
                % N1','x1','f','m1','N2','x2','m2','N3','x3','m3
                SP= [max(data(2,:))/10 position-0.03 .016 .9 max(data(2,:))/10 position+0.02 0.9 max(data(2,:))/10 position+0.02 .9];
                UB= [5*max(data(2,:)) position-.005 0.05 5 5*max(data(2,:)) position+0.04 5 5*max(data(2,:)) position+0.04 5];
                LB= [0 position-0.04 0.001 0.1 0 position-.01 0.001 position-.01 0.001];

                elseif strcmp(Fxn,'PVIITripletConstrain_m')==1 
                g = fittype('N1 * 2 * ((2^(1/m)-1)^0.5) / f1 / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x1)^2)/f1^2)^(-m) + N2 * 2 * ((2^(1/m)-1)^0.5) / f2 / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m2)-1)*((x-x2)^2)/f2^2)^(-m)+N3 * 2 * ((2^(1/m)-1)^0.5) / f3 / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x3)^2)/f3^2)^(-m)','coefficients',{'N1','x1','f1','m','N2','x2','f2','N3','x3','f3'},'independent','x');
                % N1','x1','f1','m','N2','x2','f2','N3','x3','f3'
                SP= [max(data(2,:))/10 position-0.03 .016 .9 max(data(2,:))/10 position+0.02 0.013 max(data(2,:))/10 position+0.02 0.013];
                UB= [5*max(data(2,:)) position-.005 0.05 5 5*max(data(2,:)) position+0.04 0.05 5*max(data(2,:)) position+0.04 0.05];
                LB= [0 position-0.04 0.001 0.1 0 position-.01 0 position-.01 0];    
                
                elseif strcmp(Fxn,'PVIITripletConstrain_f_m')==1 
                g = fittype('N1 * 2 * ((2^(1/m)-1)^0.5) / f / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x)^2)/f^2)^(-m) + N2 * 2 * ((2^(1/m)-1)^0.5) / f2 / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x2)^2)/f^2)^(-m)+N3 * 2 * ((2^(1/m)-1)^0.5) / f / (pi^0.5) * gamma(m) / gamma(m-0.5) * (1+4*(2^(1/m)-1)*((x-x3)^2)/f^2)^(-m)','coefficients',{'N1','x1','f','m','N2','x2','N3','x3'},'independent','x');
                % N1','x1','f','m','N2','x2','N3','x3'
                SP= [max(data(2,:))/10 position-0.03 .016 .9 max(data(2,:))/10 position+0.02 max(data(2,:))/10 position+0.02];
                UB= [5*max(data(2,:)) position-.005 0.05 5 5*max(data(2,:)) position+0.04 5*max(data(2,:)) position+0.04];
                LB= [0 position-0.04 0.001 0.1 0 position-.01 0 position-.01];
                
                elseif strcmp(Fxn,'PsuedoVoigtTripletConstrain_N')==1
                g = fittype('w1*N/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w3*N/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w3)*N/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1','coefficients',{'N','x1','f1','w1','x2','f2','w2','x3','f3','w3'},'independent','x');
                %{'N','x1','f1','w1','x2','f2','w2','x3','f3','w3'}
                SP= [max(data(2,:))/2 position-0.07 .04035 .5 position .046224 .5 position+0.06 .023686 .5];
                UB= [2*max(data(2,:)) (position-0.07)+.1 .1 1 position+0.03 .1 1 (position+0.06)+.03 .1 1];
                LB= [0 (position-0.07)-.1 0.001 0 position-.03 0.001 0 (position+0.06)-.03 0.001 0];  
                
                elseif strcmp(Fxn,'PsuedoVoigtTripletConstrain_f')==1
                g = fittype('w1*N1/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f)^2) + (1-w1)*N1/f*2/pi*(1+4*((x-x1)/f)^2)^-1 + w2*N2/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f)^2) + (1-w2)*N2/f*2/pi*(1+4*((x-x2)/f)^2)^-1 + w3*N3/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f)^2) + (1-w3)*N3/f*2/pi*(1+4*((x-x3)/f)^2)^-1','coefficients',{'N1','x1','f','w1','N2','x2','w2','N3','x3','w3'},'independent','x');
                %{'N1','x1','f','w1','N2','x2','w2','N3','x3','w3'}
                SP= [max(data(2,:))/2 position-0.07 .04035 .5 max(data(2,:))/2 position .5 max(data(2,:))/2 position+0.06 .5];
                UB= [2*max(data(2,:)) (position-0.07)+.1 .1 1 2*max(data(2,:)) position+0.03 1 2*max(data(2,:)) (position+0.06)+.03 1];
                LB= [0 (position-0.07)-.1 0.001 0 0 position-.03 0 0 (position+0.06)-.03 0];  
                
                elseif strcmp(Fxn,'PsuedoVoigtTripletConstrain_w')==1
                g = fittype('w*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1','coefficients',{'N1','x1','f1','w','N2','x2','f2','N3','x3','f3'},'independent','x');
                %{'N1','x1','f1','w','N2','x2','f2','N3','x3','f3'}
                SP= [max(data(2,:))/2 position-0.07 .04035 .5 max(data(2,:))/2 position .046224 max(data(2,:))/2 position+0.06 .023686];
                UB= [2*max(data(2,:)) (position-0.07)+.1 .1 1 2*max(data(2,:)) position+0.03 .1 2*max(data(2,:)) (position+0.06)+.03 .1];
                LB= [0 (position-0.07)-.1 0.001 0 0 position-.03 0.001 0 (position+0.06)-.03 0.001];  
                
                
                elseif strcmp(Fxn,'PsuedoVoigtTripletConstrain_f_w')==1
                g = fittype('w*N1/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f)^2) + (1-w)*N1/f*2/pi*(1+4*((x-x1)/f)^2)^-1 + w*N2/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f)^2) + (1-w)*N2/f*2/pi*(1+4*((x-x2)/f)^2)^-1 + w*N3/f*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f)^2) + (1-w)*N3/f*2/pi*(1+4*((x-x3)/f)^2)^-1','coefficients',{'N1','x1','f','w','N2','x2','N3','x3'},'independent','x');
                %{'N1','x1','f','w','N2','x2','N3','x3'}
                SP= [max(data(2,:))/2 position-0.07 .04035 .5 max(data(2,:))/2 position max(data(2,:))/2 position+0.06];
                UB= [2*max(data(2,:)) (position-0.07)+.1 .1 1 2*max(data(2,:)) position+0.03 2*max(data(2,:)) (position+0.06)+.03];
                LB= [0 (position-0.07)-.1 0.001 0 0 position-.03 0 (position+0.06)-.03];          
            

                
                %Sixtuplet for texture
      
                elseif strcmp(Fxn,'PsuedoVoigtSixtuplet')==1
                g = fittype('w1*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w3*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w3)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1+w4*N4/f4*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x4)/f4)^2) + (1-w4)*N4/f4*2/pi*(1+4*((x-x4)/f4)^2)^-1 + w5*N5/f5*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x5)/f5)^2) + (1-w5)*N5/f5*2/pi*(1+4*((x-x5)/f5)^2)^-1 + w6*N6/f6*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x6)/f6)^2) + (1-w6)*N6/f6*2/pi*(1+4*((x-x6)/f6)^2)^-1','coefficients',{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3','N4','x4','f4','w4','N5','x5','f5','w5','N6','x6','f6','w6' },'independent','x');
                %{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3' 'N4','x4','f4','w4','N5','x5','f5','w5','N6','x6','f6','w6}
                SP= [max(data(2,:))/2 position-57.5 8 .5 max(data(2,:))/2 position-44.3 8 .5 max(data(2,:))/2 position-15.5 10 .5 max(data(2,:))/2 position+14.5 10 .5 max(data(2,:))/2 position+45 7 .5 max(data(2,:))/2 position+57.9 7 .5];
                UB= [20*max(data(2,:)) (position-57.5)+3 30 1 20*max(data(2,:)) position-44.3+3 30 1 20*max(data(2,:)) (position-15.5)+10 30 1 20*max(data(2,:)) (position+14.5)+10 30 1 20*max(data(2,:)) position+45+4 30 1 20*max(data(2,:)) (position+57.6)+8 30 1];
                LB= [0 (position-57.5)-3 0.001 0 0 (position-44.3)-3 0.001 0 0 (position-15.5)-10 0.001 0 0 (position+14.5)-10 0.001 0 0 (position+45)-5 0.001 0 0 (position+57.6)-4 0.001 0];

       %Custom Fxn Triplets
       
                elseif strcmp(Fxn,'asymmPVIIDoubletPsuedoVoigt')==1
                g = fittype('FitDiffractionDataOriginal.AsymmCutoff(x01,1,x)*I1L*FitDiffractionDataOriginal.C4(m1L)/F1L*(1+4*(2^(1/m1L)-1)*(x-x01)^2/F1L^2)^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x)*I1R*FitDiffractionDataOriginal.C4(m1R)/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))*(1+4*(2^(1/m1R)-1)*(x-x01)^2/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))^2)^(-m1R) + FitDiffractionDataOriginal.AsymmCutoff(x02,1,x)*I2L*FitDiffractionDataOriginal.C4(m2L)/F2L*(1+4*(2^(1/m2L)-1)*(x-x02)^2/F2L^2)^(-m2L)+FitDiffractionDataOriginal.AsymmCutoff(x02,2,x)*I2R*FitDiffractionDataOriginal.C4(m2R)/(F2L*I2R/I2L*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L))*(1+4*(2^(1/m2R)-1)*(x-x02)^2/(F2L*I2R/I2L*FitDiffractionDataOriginal.C4(m2R)/FitDiffractionDataOriginal.C4(m2L))^2)^(-m2R)+N1*((w1*(2/pi)*(1/f1)*1/(1+(4*(x-x1)^2/f1^2))) + ((1-w1)*(2*sqrt(log(2))/(sqrt(pi)))*1/f1*exp(-log(2)*4*(x-x1)^2/f1^2)))',...
                    'coefficients',{'x01','I1L','m1L','F1L','I1R','m1R','x02','I2L','m2L','F2L','I2R','m2R','N1','x1','f1','w1'},'independent','x');                                   
                                 %  'x01','I1L','m1L','F1L','I1R','m1R','x02','I2L','m2L','F2L','I2R','m2R
                SP= [position-0.09 max(data(2,:))/140 2 0.04 80 2 position max(data(2,:))/140 2 0.03 max(data(2,:))/10 2 max(data(2,:))/140 position+.05 0.04 0.5];
                UB= [position-.06 max(data(2,:))/10 25 0.1 max(data(2,:))/10 25 position+0.01 max(data(2,:))/10 25 0.2 max(data(2,:))/10 25 1.2* max(data(2,:)) position+0.08 0.1 1];
                LB= [position-0.12 0 1 0.001 0 1 position-.01 0 1 0.001 0 1 0 position+0.01 0.001 0];  
                
                elseif strcmp(Fxn,'PsuedoVoigtTripletConstrain_Custom_f')==1
                g = fittype('w1*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N2/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f1)^2) + (1-w2)*N2/f1*2/pi*(1+4*((x-x2)/f1)^2)^-1 + w3*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w3)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1','coefficients',{'N1','x1','f1','w1','N2','x2','w2','N3','x3','f3','w3'},'independent','x');
                %{'N1','x1','f','w1','N2','x2','w2','N3','x3','f3','w3'}
                % Constrain first two FWHM and not last
                SP= [max(data(2,:))/2 position-0.07 .04035 .5 max(data(2,:))/2 position .5 max(data(2,:))/2 position+0.06 .04 .5];
                UB= [2*max(data(2,:)) (position-0.07)+.1 .1 1 2*max(data(2,:)) position+0.03 1 2*max(data(2,:)) (position+0.06)+.03 .1 1];
                LB= [0 (position-0.07)-.1 0.001 0 0 position-.03 0 0 (position+0.06)-.03 .001 0];  
                
                
                elseif strcmp(Fxn,'PsuedoVoigtTripletConstrain_Custom_w')==1
                g = fittype('w1*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w2*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w2)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1','coefficients',{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3'},'independent','x');
                %{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3'}
                % this PSfxn constrain the last two PSV by w and allows the
                % first to be free
                SP= [max(data(2,:))/2 position-0.07 .04035 .5 max(data(2,:))/2 position .046224 .5 max(data(2,:))/2 position+0.06 .023686];
                UB= [2*max(data(2,:)) (position-0.07)+.1 .1 1 2*max(data(2,:)) position+0.03 .1 1 2*max(data(2,:)) (position+0.06)+.03 .1];
                LB= [0 (position-0.07)-.1 0.001 0 0 position-.03  0.001 0 0 (position+0.06)-.03 0.001];  
                
                elseif strcmp(Fxn,'PsuedoVoigtGaussTripletConstrain_w')==1

                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+w*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1','coefficients',{'N1','x1','f1','N2','x2','f2','w','N3','x3','f3'},'independent','x');

                %N1','x1','f1','N2','x2','f2','w','N3','x3','f3'
                SP= [5000 position-.08 .02 max(data(2,:))/2 position-.02 .046224 .5 max(data(2,:))/2 position+0.03 .023686];
                UB= [50000 position-.05 .08 2*max(data(2,:)) position .1 1 2*max(data(2,:)) (position+0.03)+.03 .1];
                LB= [0 position-0.1 0.0001 0 position-.04  0.001 0 0 (position+0.03)-.03 0.001];
                
                elseif strcmp(Fxn,'asymmPVIIDoubletPsuedoVoigtConstrain_m')==1
                g = fittype('FitDiffractionDataOriginal.AsymmCutoff(x01,1,x)*I1L*FitDiffractionDataOriginal.C4(m1L)/F1L*(1+4*(2^(1/m1L)-1)*(x-x01)^2/F1L^2)^(-m1L) + FitDiffractionDataOriginal.AsymmCutoff(x01,2,x)*I1R*FitDiffractionDataOriginal.C4(m1R)/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))*(1+4*(2^(1/m1R)-1)*(x-x01)^2/(F1L*I1R/I1L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))^2)^(-m1R) + FitDiffractionDataOriginal.AsymmCutoff(x02,1,x)*I2L*FitDiffractionDataOriginal.C4(m1L)/F2L*(1+4*(2^(1/m1L)-1)*(x-x02)^2/F2L^2)^(-m1L)+FitDiffractionDataOriginal.AsymmCutoff(x02,2,x)*I2R*FitDiffractionDataOriginal.C4(m1R)/(F2L*I2R/I2L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))*(1+4*(2^(1/m1R)-1)*(x-x02)^2/(F2L*I2R/I2L*FitDiffractionDataOriginal.C4(m1R)/FitDiffractionDataOriginal.C4(m1L))^2)^(-m1R)+N1*((w1*(2/pi)*(1/f1)*1/(1+(4*(x-x1)^2/f1^2))) + ((1-w1)*(2*sqrt(log(2))/(sqrt(pi)))*1/f1*exp(-log(2)*4*(x-x1)^2/f1^2)))',...
                    'coefficients',{'x01','I1L','m1L','F1L','I1R','m1R','x02','I2L','F2L','I2R','N1','x1','f1','w1'},'independent','x');                                   
                                 %  'x01','I1L','m1L','F1L','I1R','m1R','x02','I2L',,'F2L','I2R',''N1','x1','f1','w1'
                SP= [position-0.09 max(data(2,:))/140 2 0.04 80 2 position max(data(2,:))/140 0.03 max(data(2,:))/10 max(data(2,:))/140 position+.05 0.04 0.5];
                UB= [position-.06 max(data(2,:))/10 25 0.1 max(data(2,:))/10 25 position+0.01 max(data(2,:))/10 0.2 max(data(2,:))/10 1.2* max(data(2,:)) position+0.08 0.1 1];
                LB= [position-0.12 0 1 0.001 0 1 position-.01 0 0.001 0 0 position+0.01 0.001 0]; 
                
                
                
                 
         % Quadtuplets
      
                elseif strcmp(Fxn,'GaussQuad')==1
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+N2*((2*sqrt(log(2)))/(sqrt(pi)*f2)*exp(-4*log(2)*((x-x2)^2/f2^2)))+N3*((2*sqrt(log(2)))/(sqrt(pi)*f3)*exp(-4*log(2)*((x-x3)^2/f3^2)))+N4*((2*sqrt(log(2)))/(sqrt(pi)*f4)*exp(-4*log(2)*((x-x4)^2/f4^2)))','coefficients',{'N1','x1','f1','N2','x2','f2','N3','x3','f3','N4','x4','f4'},'independent','x');
                % 'N1','x1','f1','N2','x2','f2','N3','x3','f3'N4,x4,f4
                SP= [max(data(2,:)) position-0.075 0.02 max(data(2,:)) position-.034 0.02 max(data(2,:)) position 0.02 max(data(2,:)) position+0.02 0.02];
                UB= [max(data(2,:))*2 position-.07 0.5 max(data(2,:))*2 position-.02 0.1  max(data(2,:))*2 position+0.01 0.1 max(data(2,:)) position+0.05 0.05];
                LB= [0 position-0.1 0.001 0 position-.035 0.001 0 position-0.04 0.001 0 position+0.01 0.001];
                
                elseif strcmp(Fxn,'GaussQuadConstrain_f')==1
                g = fittype('N1*((2*sqrt(log(2)))/(sqrt(pi)*f1)*exp(-4*log(2)*((x-x1)^2/f1^2)))+N2*((2*sqrt(log(2)))/(sqrt(pi)*f)*exp(-4*log(2)*((x-x2)^2/f^2)))+N3*((2*sqrt(log(2)))/(sqrt(pi)*f)*exp(-4*log(2)*((x-x3)^2/f^2)))+N4*((2*sqrt(log(2)))/(sqrt(pi)*f)*exp(-4*log(2)*((x-x4)^2/f^2)))','coefficients',{'N1','x1','f1','N2','x2','f','N3','x3','N4','x4'},'independent','x');
                % 'N1','x1','f1','N2','x2','f2','N3','x3','f3'N4,x4,f4
                SP= [max(data(2,:)) position-0.075 0.02 max(data(2,:)) position-.034 .02 max(data(2,:)) position max(data(2,:)) position+0.02];
                UB= [max(data(2,:))*2 position-.07 0.5 max(data(2,:))*2 position-.02 .05  max(data(2,:))*2 position+0.01 max(data(2,:)) position+0.05];
                LB= [0 position-0.1 0.001 0 position-.035 .001 0 position-0.04 0 position+0.01];            
                disp('1st peak not constrained to others')
                
                elseif strcmp(Fxn,'PsuedoVoigtQuadtuplet')==1
                g = fittype('w1*N1/f1*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x1)/f1)^2) + (1-w1)*N1/f1*2/pi*(1+4*((x-x1)/f1)^2)^-1 + w2*N2/f2*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x2)/f2)^2) + (1-w2)*N2/f2*2/pi*(1+4*((x-x2)/f2)^2)^-1 + w3*N3/f3*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x3)/f3)^2) + (1-w3)*N3/f3*2/pi*(1+4*((x-x3)/f3)^2)^-1+w4*N4/f4*(2*(log(2))^.5)/pi^.5*exp(-4*log(2)*((x-x4)/f4)^2) + (1-w4)*N4/f4*2/pi*(1+4*((x-x4)/f4)^2)^-1','coefficients',{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3','N4','x4','f4','w4'},'independent','x');
                %{'N1','x1','f1','w1','N2','x2','f2','w2','N3','x3','f3','w3' 'N4','x4','f4','w4'
                SP= [max(data(2,:))/2 position-.05 .04 .5 max(data(2,:))/2 position-.02 .03 .5 max(data(2,:))/2 position .03 .5 max(data(2,:))/2 position+.05 .04 .5];
                UB= [20*max(data(2,:)) (position-.05)+.01 .1 1 20*max(data(2,:)) position-.02+.03 .1 1 20*max(data(2,:)) (position)+.010 .1 1 20*max(data(2,:)) (position+.05)+.010 .1 1];
                LB= [0 (position-.05)-.01 0.001 0 0 (position-.02)-.03 0.001 0 0 (position)-.010 0.001 0 0 (position+.05)-.010 0.001 0];
                
                
            else
                fprintf(1,'Valid peak shape functions currently written in this program include:\n');
                fprintf(1,'PVIIKa1Ka2, PVII_11IDC, or PVII_11BM\n');
                fprintf(1,'asymmPVII, asymmPVII_11IDC, or asymmPVII_11BM\n');
                fprintf(1,'asymmPVIIDoublet, asymmPVIIDoublet_11IDC, or asymmPVIIDoublet_11BM\n');
                fprintf(1,'PsuedoVoigtTriplet_11IDC\n');
                fprintf(1,'PVIIKa1Ka2fsame\n');
                fprintf(1,'PVIIKa1Ka2bothsame\n');
                fprintf(1,'GaussKa1Ka2\n');
                fprintf(1,'Functions available include: Gauss, Lorentzian, PVII, PsuedoVoigt, their doublets and triplets, and contrained versions of the functions');
                fprintf(1,'Example: Gauss or GaussDoublet');
                fprintf(1,'To call contrains list the function followed by the word "Constrain" (all together) then underscore (_) then the variable');
                fprintf(1,'Example: GaussConstrain_f');
                error('Function not available, to quickly get to this section of the code press Crtll+G when editing the m-file and type line number 2100')
            end
        end        
    end
    methods(Static,Hidden)
        function Exceptions(number)
            if number == 0
                disp('Please enter the initial and final file numbers')
            elseif number == 1
                disp('The fileformat you have entered is not supported.')
                disp('This program can read csv, txt, xy, fxye, dat, xrdml, chi, and spr files')
            elseif number == 2
                disp('File to read is not defined')
            end
        end        
        function [c4] = C4(m)
            c4=2*((2^(1/m)-1)^0.5)/(pi^0.5)*gamma(m)/gamma(m-0.5);
        end
        function arrayposition=Find2theta(data,value2theta)
            % function arrayposition=Find2theta(data,value2theta)
            % Finds the nearest position in a vector
            % MUST be a single array of 2theta values only (most common error)
            
            if nargin~=2
                error('Incorrect number of arguments')
                arrayposition=0;
            else
                test = find(data >= value2theta);
                if isempty(test);
                    arrayposition = length(data)-1;
                else
                    arrayposition = test(1);                    
                end
            end
        end
        function position2=Ka2fromKa1(position1)
            if nargin==0
                error('Incorrect number of arguments')
            elseif ~isreal(position1)
                 warning('Imaginary parts of INPUT ignored')
                 position1 = real(position1);
            end

            lambda1 = 1.540598; %Ka1
            lambda2 = 1.544426; %Ka2
            position2 = 180 / pi * (2*asin(lambda2/lambda1*sin(pi / 180 * (position1/2))));
        end
        function fig = constructFigure(num,xlab,ylab,gtitle)
            fig = figure(num);% Pixels for image
            set(fig,'Position',[500 500 600 500])
            axes1 = axes('Parent',fig,'FontSize',16,'LineWidth',1,'FontName','Times New Roman');
            box(axes1,'on'); %displays the boundary of the current axes
            hold(axes1,'all');
            xlabel(xlab,'FontSize',20,'FontName','Times New Roman');
            ylabel(ylab,'FontSize',20,'FontName','Times New Roman');
            hTitle = title (gtitle);
        end
        function [x]=SaveFitData(filename,dataMatrix)
            %
            % function [x]=SaveFitData(filename,dataMatrix)
            % JJones, 23 Nov 2007
            %

            if nargin~=2 %number of required input arguments
                error('Incorrect number of arguments')
                x=0; %means unsuccessful
            else    
                fid = fopen(filename,'w');
                fprintf(fid, 'This is an output file from a MATLAB routine.\n');
                fprintf(fid, 'All single peak data (column 3+) does not include background intensity.\n');
                fprintf(fid, '2theta \t IntMeas \t BkgdFit \t Peak1 \t Peak2 \t Etc...\n');
                dataformat = '%f\n'; 
                for i=1:(size(dataMatrix,1)-1);
                    dataformat = strcat('%f\t',dataformat);
                end
                fprintf(fid, dataformat, dataMatrix);
                fclose(fid);
                x=1; %means successful
            end
        end
        function [x]=SaveFitValues(filename,PSfxn,Fmodel,Fcoeff,FmodelGOF,FmodelCI)
            %
            % function 
            %      [x]=SaveFitValues(filename,PSfxn,Fmodel,Fcoeff,FmodelGOF,FmodelCI)
            %
            % JJones, 23 Nov 2007
            %

            if nargin~=6 %number of required input arguments
                error('Incorrect number of arguments')
                x=0; %means unsuccessful
            else
                fid = fopen(filename,'w');
                fprintf(fid, 'This is an output file from a MATLAB routine.\n');
                for i=1:length(PSfxn)
                    if i==1; test=0; else test=strcmp(PSfxn{i},PSfxn{i-1}); end
                    %write coefficient names
                    if or(i==1,test==0);
                        fprintf(fid, strcat('The following peaks are all of the type:', PSfxn{i}, '\n'));
                        %first output fitted values
                        for j=1:length(Fcoeff{i});
                            fprintf(fid, '%s\t', char(Fcoeff{i}(j))); %write coefficient names
                        end
                        %second output GOF values
                        fprintf(fid, 'sse \t rsquare \t dfe \t adjrsquare \t rmse \t'); %write GOF names
                        %third output Confidence Intervals (CI)
                        for j=1:size(FmodelCI{i},2)
                            fprintf(fid, '%s\t', strcat('LowCI:',char(Fcoeff{i}(j)))); %write LB names
                            fprintf(fid, '%s\t', strcat('UppCI:',char(Fcoeff{i}(j)))); %write UB names
                        end
                        fprintf(fid, '\n');
                    end
                    %write coefficient values
                    for j=1:length(Fcoeff{i});
                        fprintf(fid, '%f\t', Fmodel{i}.(Fcoeff{i}(j))); %write coefficient values
                    end
                    GOFoutputs=[FmodelGOF{i}.sse FmodelGOF{i}.rsquare FmodelGOF{i}.dfe FmodelGOF{i}.adjrsquare FmodelGOF{i}.rmse];
                    fprintf(fid, '%f\t%f\t%f\t%f\t%f\t',GOFoutputs); %write GOF values
                    for j=1:size(FmodelCI{i},2)
                        fprintf(fid, '%f\t', FmodelCI{i}(1,j)); %write lower bound values
                        fprintf(fid, '%f\t', FmodelCI{i}(2,j)); %write upper bound values
                    end
                    fprintf(fid, '\n');
                end
                fclose(fid);
                x=1; %means successful
            end
        end
        function [Y] = AsymmCutoff(x, side, xdata)

            numPts=length(xdata);

            if side == 1
                for i=1:numPts;
                    if xdata(i) < x;
                        step(i)=1;
                    else
                        step(i)=0;
                    end
                end
            elseif side == 2
                for i=1:numPts;
                    if xdata(i) < x;
                        step(i)=0;
                    else
                        step(i)=1;
                    end
                end
            end

            Y=step';
        end        
    end
end

