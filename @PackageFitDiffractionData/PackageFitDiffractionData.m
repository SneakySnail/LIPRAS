
classdef PackageFitDiffractionData < matlab.mixin.Copyable
	%classdef PackageFitDiffractionData < matlab.mixin.Copyable
	%   PackageFitDiffractionData Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		Filename = '';												 % Cell array of name of files
		two_theta = [];												% array of full two_theta values from file
		data_fit = [];												  % array of original data. Each row is intensity data from a file
		fitrange = 0.3;
		fit_parms = {};												% list of cells containing coeffvalues from the fit
		fit_parms_error = {};									 % list of cells containing coeffvalues error
		fit_results = {};
		fit_initial=[];												  % list of cells containing SP, UB, and LB
		PeakPositions
		PolyOrder = 3;
		Min2T
		Max2T
		PSfxn
		Fdata
		Fmodel
		Fcoeff
		Constrains = [0 0 0 0];
	end
	
	properties (SetObservable)
		Status = '';
		DisplayName = '';
	end
	
	properties(Hidden)
		FmodelGOF
		FmodelCI
		suffix   = '';
		symdata =0;
		original_SP=[];
		azim = [0:15:345];
		binID = [1:1:24];
		lambda = 1.5405980;
		CuKa=false;
		level = 0.95;
		OutputPath = 'FitOutputs/';
		SPR_Chi
		SPR_Angle
		SPR_Data
		numAzim
		bkgd2th
		DataPath = '';
		skiplines = 0;
		% 		reduceData = 0;
		%         originalData = [];
		%         dEta = 0;
		%         fitRange
		%         Fit_Range
		%         File_Input = 'n'
		%         DataAverage
		%         temperature_init
		% 		inputSP= 'n';
		%         plotyn = 'n';
		% 		saveyn = 'y';
	end
	
	methods
		function Stro = PackageFitDiffractionData()
			
		end
				
		function hasData = Read_Data(Stro)
			[Filename, DataPath] = uigetfile({'*.csv;*.txt;*.xy;*.fxye;*.dat;*.xrdml;*.chi;*.spr','*.csv, *.txt, *.xy, *.fxye, *.dat, *.xrdml, *.chi, or *.spr'},'Select Diffraction Pattern to Fit','MultiSelect', 'on');
			
			if ~isequal(Filename,0)
				hasData=true;
				Stro.Fmodel=[];
				Stro.PSfxn=[];
				Stro.PeakPositions=[];
				Stro.bkgd2th=[];
				cla % was set here to clear the data for adjusting twotheta range
				Stro.Filename=Filename;
				Stro.DataPath=DataPath;
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
				
				Stro.Min2T = min(Stro.two_theta);
				Stro.Max2T = max(Stro.two_theta);
				
				%             if ~strcmp(Stro.File_Input, 'y')
				%                 Stro.Max2T
				%                 disp('this')
				% %                 Stro.setTwo_Theta_Range()
				%             end
				
				Stro.fit_parms=[];
				Stro.fit_parms_error=[];
				Stro.fit_results=[];
				Stro.fit_initial=[];
				
				Stro.plotData
				
			else
				hasData=false;
			end  % this is to prevent data loss when hitting cancel in uigetfile
		end
		
		% Reads and loads a file containing fit parameters into the current profile.
		function isLoaded = Read_Inputs(Stro)
			Stro.Status='Reading input file... ';
			[filename, pathName]  = uigetfile({'*.txt;','*.txt'},'Select Input File','MultiSelect', 'off');
			if isequal(filename,0)
				isLoaded=false;
				Stro.Status=[Stro.Status,'Input file not found. '];
				return
			else
				isLoaded=true;
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
						if length(Stro.PSfxn)~=length(Stro.PeakPositions)
							psfxn='';
							for i=1:length(Stro.PSfxn)
								
							end
						end
					elseif strcmp(a(1),'Constraints:')
						for i=2:5
							c(i-1)=str2double(a{i});
						end
						Stro.Constrains=c;
						
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
					elseif strcmp(a(1),'Fit_initial');
						break
					end
				end
				
				%This is the section that enables the read in or originial and
				%fit_initial parameters from an input file
				
				% Read coefficient names
				line=fgetl(fid);
				coeff=textscan(line,'%s');
				coeff=coeff{1}';
				% Read SP values
				line=fgetl(fid);
				sp=textscan(line,'%s');
				sp=sp{1}';
				sp=str2double(sp(2:end));
				% Read UB values
				line=fgetl(fid);
				ub=textscan(line,'%s');
				ub=ub{1}';
				ub=str2double(ub(2:end));
				% Read LB values
				line=fgetl(fid);
				lb=textscan(line,'%s');
				lb=lb{1}';
				lb=str2double(lb(2:end));
				
				Stro.Fcoeff=coeff;
				Stro.fit_initial={sp;ub;lb};
				
				fclose(fid);
			end
			Stro.Status=[Stro.Status,'Done.'];
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
			
			if Stro.symdata==1
				DifData = cat(3, 0.5 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,1,:)) + squeeze( datamatrix(2:length(Stro.Filename)+1,numAzim/2+1,:)) )/2);
				for i=2:numAzim/4
					DifData = cat(3, DifData, 0.25 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/2+2-i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/2+i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim-i+2,:)) )/4);
				end
				DifData = cat(3, DifData, .5 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/4+1,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim * 3 / 4 + 1,:)) )/2);
				
			else
				DifData = cat(3, squeeze(datamatrix(2:length(Stro.Filename)+1,1,:)));
				for i=2:numAzim/4+1
					DifData = cat(3, DifData, squeeze(datamatrix(2:length(Stro.Filename)+1,i,:)));
				end
			end
			
			Stro.numAzim = numAzim;
			Stro.SPR_Data = DifData;
			
			
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
		
		function coeff=getCoeff(Stro,fxn,constraints)
			coeff='';
			
			if nargin < 3
				constraints = Stro.Constrains;
			end
			if nargin < 2
				fxn = Stro.PSfxn;
			end
			
			if constraints(1); coeff=[coeff,{'N'}]; end
			if constraints(2); coeff=[coeff,{'f'}]; end
			if constraints(3); coeff=[coeff,{'w'}]; end
			if constraints(4); coeff=[coeff,{'m'}]; end
			
			for i=1:length(fxn)
				coeffNames = '';
				N = ['N' num2str(i)];
				xv = ['x' num2str(i)];
				f = ['f' num2str(i)];
				m = ['m' num2str(i)];
				w = ['w' num2str(i)];
				NL=['N',num2str(i),'L'];
				mL=['m',num2str(i),'L'];
				NR=['N',num2str(i),'R'];
				mR=['m',num2str(i),'R'];
				
				switch fxn{i}
					case 'Gaussian'
						if ~constraints(1); coeffNames = [coeffNames, {N}]; end
						coeffNames = [coeffNames, {xv}];
						if ~constraints(2); coeffNames = [coeffNames, {f}]; end
						
					case 'Lorentzian'
						if ~constraints(1); coeffNames = [coeffNames, {N}]; end
						coeffNames = [coeffNames, {xv}];
						if ~constraints(2); coeffNames = [coeffNames, {f}]; end
						
					case 'Psuedo Voigt'
						if ~constraints(1); coeffNames = [coeffNames, {N}]; end
						coeffNames = [coeffNames, {xv}];
						if ~constraints(2); coeffNames = [coeffNames, {f}]; end
						if ~constraints(3); coeffNames = [coeffNames, {w}]; end
						
					case 'Pearson VII'
						if ~constraints(1); coeffNames = [coeffNames, {N}]; end
						coeffNames = [coeffNames, {xv}];
						if ~constraints(2); coeffNames = [coeffNames, {f}]; end
						if ~constraints(4); coeffNames = [coeffNames, {m}]; end
						
					case 'Asymmetric Pearson VII'
						if ~constraints(1); coeffNames=[coeffNames,{NL},{NR}]; end
						coeffNames=[coeffNames,{xv}];
						if ~constraints(2); coeffNames=[coeffNames,{f}]; end
						if ~constraints(4); coeffNames=[coeffNames,{mL},{mR}];end
				end
				coeff=[coeff,coeffNames];
				
			end
			
		end
		
		function fitData(Stro, position, PSfxn, SP1, UB1, LB1)
			Stro.getBackground();
			Stro.fit_results={};
			Stro.fit_parms={};
			Stro.fit_parms_error={};
			
			Stro.PeakPositions = position;
			Stro.PSfxn = PSfxn;
			
			if nargin > 3
				Stro.fit_initial = {SP1;UB1;LB1};
			end
			
			datainMin = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Min2T);
			datainMax = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Max2T);
			
			data = Stro.data_fit(:,datainMin:datainMax); %Extract relevant 2theta region
			TwT = Stro.two_theta(datainMin:datainMax); %Extract relevant 2theta region
			
			%create arbitrary axis for plotting of data
			arb = 1:1:size(Stro.data_fit,1); %here
			
			[~,~]=meshgrid(TwT,arb);
			
			Arbgridsum=arb;
			datasum=data;
			
			for i=1:length(Stro.Filename) %this is the start of the for loop that executes the remainder of the
				Stro.Status=['Fitting Dataset ',num2str(i),' of ',num2str(length(Stro.Filename)),'... '];
				
				if evalin('base','handles.radio_stopleastsquares.Value')==1
					Stro.Status=[Stro.Status,'Stopped.'];
					break
				end
				
				%this is the primary function
				if size(Stro.PSfxn,1)==size(Stro.PeakPositions,1)
					datasent = Stro.getRawData(i, Stro.fitrange);
					
					
					Stro.fitXRD(datasent, Stro.PeakPositions,i);
					
					if isa(Stro.Filename,'char')
						[path, filename, ext] = fileparts( Stro.Filename );
					elseif length(Stro.Filename) == 1
						[path, filename, ext] = fileparts( Stro.Filename{1} );
					else
						[path, filename, ext] = fileparts( Stro.Filename{i} );
					end
					
					clear path ext
					
					for m=1:size(Stro.PeakPositions,1)
						fitOutputPath = strcat(Stro.OutputPath,'FitData/');
						if ~exist(fitOutputPath,'dir')
							mkdir(fitOutputPath);
						end
						
						if isempty(Stro.SPR_Angle)
							filetosave=strcat(fitOutputPath,Stro.Filename{1},'Master','_peak',num2str(m),'.Fmodel');
						else
							filetosave=strcat(fitOutputPath,Stro.Filename{1},'_Angle_',num2str(Stro.SPR_Angle),'_Master','_peak',num2str(m),'.Fmodel');
						end
						
						if i==1  %only if first file to open (master loop); print file header
							fid = fopen(filetosave,'w');
							fprintf(fid, 'This is an output file from a MATLAB routine.\n');
							fprintf(fid, strcat('The following peaks are all of the type: ', Stro.PSfxn{:}, '\n'));
							for j=1:length(Stro.Fcoeff{m});
								fprintf(fid, '%s\t', char(Stro.Fcoeff{m}(j))); %write coefficient names
							end
							p=fieldnames(Stro.FmodelGOF{i})';
							fprintf(fid, '%s\t',p{:}); %write GOF names
							for j=1:size(Stro.FmodelCI{i,m},2)
								fprintf(fid, '%s\t', strcat('LowCI:',char(Stro.Fcoeff{m}(j)))); %write LB names
								fprintf(fid, '%s\t', strcat('UppCI:',char(Stro.Fcoeff{m}(j)))); %write UB names
							end
							fprintf(fid, '\n');
							fclose(fid);
						end
						fid = fopen(filetosave,'a');
						for j=1:length(Stro.Fcoeff{m});
							fprintf(fid, '%#.5g\t', Stro.Fmodel{i,m}.(Stro.Fcoeff{m}(j))); %write coefficient values
						end
						%                             GOFoutputs=[Stro.FmodelGOF{i,m}.sse Stro.FmodelGOF{i,m}.rsquare Stro.FmodelGOF{i,m}.dfe Stro.FmodelGOF{i,m}.adjrsquare Stro.FmodelGOF{i,m}.rmse];
						fprintf(fid, '%#.5g\t',struct2array(Stro.FmodelGOF{i,m})); %write GOF values
						for j=1:size(Stro.FmodelCI{i,m},2)
							fprintf(fid,'%#.5g\t', Stro.FmodelCI{i,m}(1,j)); %write lower bound values
							fprintf(fid,'%#.5g\t', Stro.FmodelCI{i,m}(2,j)); %write upper bound values
						end
						fprintf(fid, '\n');
						fclose(fid);
					end
					
				else  %else statement for primary function
					error('Number of inputs are not consistent. Program not executed')
				end   %end of if fxn executing primary program
				
				for iii = 1:size(Stro.Fmodel, 2)
					Stro.fit_parms{i,iii} = coeffvalues(Stro.Fmodel{i,iii});
					Stro.fit_parms_error{i,iii} = 0.5*(Stro.FmodelCI{i,iii}(2,:) - Stro.FmodelCI{i,iii}(1,:));
				end
				
				if i~=length(Stro.Filename)
					Stro.fit_initial{1,i+1}=Stro.fit_parms{i};
				end
				
				Stro.fit_results{i} = Stro.Fdata;
				
			end
			
			Stro.Status = 'Fitting dataset... Done.';
		end
		
		
		
		
		% TODO Move to FDGUIv2_1
		function plotData(Stro,dataSet,colorID)
			if nargin<3
				colorID='none';
			end
			if nargin == 1
				dataSet = 1;
			end
			
			x = Stro.two_theta;
			
			c=find(Stro.Min2T<=Stro.two_theta & Stro.Max2T>=Stro.two_theta);
			intensity = Stro.data_fit(dataSet,:);
			
			ymax=max(intensity(c));
			ymin=min(intensity(c));
			
			if strcmpi(colorID,'superimpose')
				hold on
				ind=find(strcmp(Stro.DisplayName,Stro.Filename(dataSet)));
				
				if isempty(ind)
					% If not already plotted
					if isempty(Stro.DisplayName)
						Stro.DisplayName(1)=Stro.Filename(dataSet);
					else
						Stro.DisplayName(end+1)=Stro.Filename(dataSet);
					end
					plot(x,intensity,'-o','LineWidth',1,'MarkerSize',6);
				else
					% Delete from DisplayName and from current axis
					Stro.DisplayName(ind)=[];
					lines=get(gca,'Children');
					lind=find(strcmp(get(lines,'DisplayName'),Stro.Filename(dataSet)));
					delete(lines(lind)); %#ok<FNDSB>
				end
				% Set color order index
				lines=get(gca,'Children');
				cArray=zeros(1,7);
				co=get(gca,'ColorOrder');
				lc=get(lines,'Color');
				if length(lines)==1
					ind=find(lc(1,1)==co(:,1));
					cArray(ind)=1;
				else
					for i=1:length(lines)
						ind=find(lc{i}(1)==co(:,1));
						cArray(ind)=1;
					end
				end
				cArray=find(~cArray,1);
				try
					set(gca,'ColorOrderIndex',cArray);
				catch  % If all colors are used
					cArray
				end
				
				% Get the maximum value of each line
				
				minX=PackageFitDiffractionData.Find2theta(lines(1).XData,Stro.Min2T);
				maxX=PackageFitDiffractionData.Find2theta(lines(1).XData,Stro.Max2T);
				y=[];
				
				for i=1:length(lines)
					y=[y,lines(i).YData(minX:maxX)];
				end
				ymin=min(y);
				ymax=max(y);
				
			else
				hold off
				if isempty(Stro.bkgd2th)
					plot(x,intensity,'-o','LineWidth',1,'MarkerSize',6);
				else
					plot(x,intensity,'-ko','LineWidth',1,'MarkerSize',6);
				end
				Stro.DisplayName=Stro.Filename(dataSet);
			end
			
			ylim([0.9*ymin,1.1*ymax])
			xlim([Stro.Min2T, Stro.Max2T])
		end
		
		% TODO Move to FDGUIv2_1
		function plotFit(Stro,dataSet)
			if nargin == 1
				dataSet = 1;
				dataSet0 = dataSet;
				dataSetf = dataSet;
			elseif strcmp(dataSet,'all')
				dataSet0 = 1;
				dataSetf = size(Stro.fit_results,2);
				figure(5)
			else
				dataSet0 = dataSet;
				dataSetf = dataSet;
			end
			
			
			for j=dataSet0:dataSetf
				if strcmp(dataSet,'all')
					ax(j) = subplot(floor(sqrt(size(Stro.fit_results,2))),ceil(size(Stro.fit_results,2)/floor(sqrt(size(Stro.fit_results,2)))),j);
					hold on
				end
				cla
				x = Stro.fit_results{j}(1,:)';
				intensity = Stro.fit_results{j}(2,:)';
				back = Stro.fit_results{j}(3,:)';
				fittedPattern = back;
				
				for i=1:length(Stro.PSfxn(:,1))
					fittedPattern = fittedPattern + Stro.fit_results{j}(3+i,:)';
				end
				hold on
				
				for i=1:size(Stro.PSfxn, 1)
					peakfit = [];
					fxn = Stro.PSfxn(1,:);
					val = Stro.fit_parms{j,i}(1,:);
					coeff = Stro.Fcoeff{1}';
					k=1;
					
					if Stro.Constrains(1); N=val(k); NL=val(k); NR=val(k); k=k+1; end
					if Stro.Constrains(2); f=val(k); k=k+1; end
					if Stro.Constrains(3); w=val(k); k=k+1; end
					if Stro.Constrains(4); m=val(k); mL=m; mR=m; k=k+1; end
					
					for ii=1:length(fxn)
						if coeff{k}(1) == 'N';
							if strcmp(fxn{ii},'Asymmetric Pearson VII')
								NL=val(k);
								k=k+1;
								NR=val(k);
								if k<length(coeff); k=k+1; end
							else
								N=val(k);
								if k<length(coeff); k=k+1; end
							end
							
						end
						if coeff{k}(1) == 'x'
							xv=val(k);
							if k<length(coeff); k=k+1; end
						end
						if coeff{k}(1) == 'f'; f=val(k);
							if k<length(coeff); k=k+1; end
						end
						if coeff{k}(1) == 'w'; w=val(k);
							if k<length(coeff); k=k+1; end
						end
						if coeff{k}(1) == 'm';
							if strcmp(fxn{ii},'Asymmetric Pearson VII')
								mL=val(k);
								k=k+1;
								mR=val(k);
								if k<length(coeff); k=k+1; end
							else
								m=val(k);
								if k<length(coeff); k=k+1; end
							end
						end
						
						xvk=PackageFitDiffractionData.Ka2fromKa1(xv);
						switch fxn{ii}
							case 'Gaussian'
								peakfit(ii,:) = N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-xv).^2./f.^2)));
								if Stro.CuKa
									CuKaPeak(ii,:)=(1/1.9)*N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-xvk).^2./f.^2)));
								end
							case 'Lorentzian'
								peakfit(ii,:) = N.*1./pi* (0.5.*f./((x-xv).^2+(0.5.*f).^2));
								if Stro.CuKa
									CuKaPeak(ii,:) = (1/1.9)*N.*1./pi* (0.5.*f./((x-xvk).^2+(0.5.*f).^2));
								end
							case 'Pearson VII'
								peakfit(ii,:) = N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-xv).^2)/f.^2).^(-m);
								if Stro.CuKa
									CuKaPeak(ii,:)=(1/1.9)*N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-xvk).^2)/f.^2).^(-m);
								end
							case 'Psuedo Voigt'
								peakfit(ii,:) = N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x-xv).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x-xv).^2./f.^2)));
								if Stro.CuKa
									CuKaPeak(ii,:)=(1/1.9)*N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x-xvk).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x-xvk).^2./f.^2)));
								end
							case 'Asymmetric Pearson VII'
								peakfit(ii,:) = PackageFitDiffractionData.AsymmCutoff(xv,1,x).*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x-xv).^2/f.^2).^(-mL) + ...
									PackageFitDiffractionData.AsymmCutoff(xv,2,x).*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x-xv).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
								if Stro.CuKa
									CuKaPeak(ii,:)=PackageFitDiffractionData.AsymmCutoff(xvk,1,x).*(1/1.9)*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x-xvk).^2/f.^2).^(-mL) + ...
										PackageFitDiffractionData.AsymmCutoff(xvk,2,x).*(1/1.9)*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x-xvk).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
								end
						end
					end
					cla
					data(1) = plot(x,intensity,'kx','LineWidth',1,'MarkerSize',15,'DisplayName','Raw Data'); % Raw Data
					data(2)= plot(x,back,'DisplayName','Background'); % Background
					data(3) = plot(x,fittedPattern,'k','LineWidth',1.6,'DisplayName','Overall Fit'); % Overall Fit
					Stro.DisplayName = {data.DisplayName};
					
					for jj=1:size(Stro.PSfxn,2)
						if Stro.CuKa
							data(3+2*jj-1) = plot(x',peakfit(jj,:)+back','LineWidth',1,'DisplayName',['Cu-K\alpha1 (',num2str(jj),')']);
							data(3+2*jj)=plot(x',CuKaPeak(jj,:)+back','LineWidth',1,'DisplayName',['Cu-K\alpha2 (',num2str(jj),')']);
						else
							data(3+jj) = plot(x',peakfit(jj,:)+back','LineWidth',1,'DisplayName',['Peak ',num2str(jj)]);
						end
					end
					
					if strcmp(dataSet,'all')
						err = plot(x, intensity - fittedPattern - max(intensity) / 10, 'r','LineWidth',1.2);
					else
						evalin('base','axes(handles.axes2)')
						cla
						err = plot(x, intensity - (fittedPattern), 'r','LineWidth',1.2); % Error
 						xlim([Stro.Min2T Stro.Max2T])
% 						evalin('base', 'linkaxes([handles.axes1 handles.axes2],''x'')')
						
						evalin('base','axes(handles.axes1)')
% 						ylim([0 1.1*max(fittedPattern)])
% 						ylim([0.9*min([data.YData]), 1.1*max([data.YData])]);
					end
					
					
					
					
				end
				if strcmp(dataSet,'all')
					xlim([min(x) max(x)])
% 					ylim([0 1.1*max(fittedPattern)])
				end
				
			end
			
			
			
			if strcmp(dataSet,'all')
				linkaxes(ax,'xy');
			end
			
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
		
		% TODO Move to FDGUIv2_1
		function outputError(Stro,filename)
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
			
			%             if ~isempty(Stro.DataAverage)
			%                 fprintf(fid, 'Average_Data: %f \n\n',Stro.DataAverage);
			%             end
			if ~isempty(Stro.SPR_Angle)
				fprintf(fid, 'SPR_Angle: %i \n\n',Stro.SPR_Angle);
			end
			
			fprintf(fid, 'Number_of_background_points: %i\n',length(Stro.bkgd2th));
			fprintf(fid, 'Background_order: %i\n', Stro.PolyOrder);
			fprintf(fid, 'Background_points:');
			for i=1:length(Stro.bkgd2th)
				fprintf(fid, ' %f',Stro.bkgd2th(i));
			end
			fprintf(fid, '\n\nPeak Parameters\n');
			
			fprintf(fid, 'PeakPos:');
			for i=1:size(Stro.PSfxn,1) % i=profilenum
				if i~=1
					fprintf(fid,';');
				end
				for j=1:size(Stro.PSfxn,2) % j=peaknum
					fprintf(fid,' %.3f',Stro.PeakPositions(i,j));
				end
			end
			fprintf(fid,'\nFxn:');
			for i=1:size(Stro.PSfxn,1)
				if i~=1
					fprintf(fid,';');
				end
				for j=1:size(Stro.PSfxn,2)
					fprintf(fid,' %s',Stro.PSfxn{j});
				end
			end
			
			if ~isempty(Stro.fitrange)
				fprintf(fid,'\nfitrange:');
				for i=1:size(Stro.PSfxn,1)
					fprintf(fid,' %.4f',Stro.fitrange(i));
				end
			end
			fprintf(fid,'\nConstraints:');
			fprintf(fid, ' %d',Stro.Constrains);
			
			fprintf(fid, '\n\nFit_initial Parameters\n');
			for g=1:size(Stro.PSfxn,1);
				% 				fprintf(fid, '\n%s', Stro.PSfxn{g});
				for f=1:length(Stro.Fcoeff);
					fprintf(fid, '%s ', Stro.Fcoeff{f}{:}); %write coefficient names
				end
				fprintf(fid, '\n%s','SP:');
				fprintf(fid,' %#.5g',(Stro.fit_initial{1,1}));
				fprintf(fid, '\n%s','UB:');
				fprintf(fid,' %#.5g',(Stro.fit_initial{2,1}));
				fprintf(fid, '\n%s','LB:');
				fprintf(fid,' %#.5g',(Stro.fit_initial{3,1}));
				
			end
			
			fprintf(fid, '\n\nFit Errors\n');
			
			if strcmp( Stro.suffix, 'xrdml')
				fprintf(fid, 'Filename \t temperature \t Rp \t Rwp'); % What is being printed on the new txt file on the rirst row (this just labels what column refers to what)
			else
				fprintf(fid, 'Filename \t\t Rp \t Rwp'); % What is being printed on the new txt file on the rirst row (this just labels what column refers to what)
			end
			
			
			
			for i=1:size( Stro.data_fit, 1) %this takes the length specified above in line 30
				obs=Stro.fit_results{i}(2,:)'; %specifies observed values
				
				calc = Stro.fit_results{i}(3,:)';
				for j=1:size(Stro.PSfxn,1)
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
		
		function [points,indX]=resetBackground(Stro, numpoints, polyorder)
			Stro.bkgd2th = [];
			Stro.PolyOrder = polyorder;
			[points,indX]=Stro.getBackground(numpoints);
		end
		
		function data = getRawData(Stro,file,fitrange)
			datainMin = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Min2T);
			datainMax = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Max2T);
			
			data = Stro.data_fit(:,datainMin:datainMax); %Extract relevant 2theta region
			TwT = Stro.two_theta(datainMin:datainMax); %Extract relevant 2theta region
			
			%create arbitrary axis for plotting of data
			arb = 1:1:size(Stro.data_fit,1); %here
			
			TwTgridsum=TwT;
			Arbgridsum=arb;
			fitrange2T = fitrange;
			
			datasent = [TwT' data(file,:)']';
			for ii=1:size(Stro.PeakPositions,1) %Change to number of steps (instead of 2theta)
				p = mean(Stro.PeakPositions(ii,:));
				fitrangeL = PackageFitDiffractionData.Find2theta(datasent(1,:),p-fitrange2T(ii)/2);
				fitrangeH = PackageFitDiffractionData.Find2theta(datasent(1,:),p+fitrange2T(ii)/2);
				drangeH = fitrangeH-PackageFitDiffractionData.Find2theta(datasent(1,:),p);
				drangeL = PackageFitDiffractionData.Find2theta(datasent(1,:),p)-fitrangeL;
				if drangeL > drangeH
					fitrange(ii) = drangeH * 2;
				elseif drangeH > drangeL
					fitrange(ii) = drangeL * 2;
				else
					fitrange(ii) = fitrangeH-fitrangeL;
				end
			end
			% 			Stro.fitrange = fitrange;
			data = datasent;
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