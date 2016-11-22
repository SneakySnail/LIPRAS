function [Stro, has_data] = Read_Data(Stro, fname, path)
	if nargin < 3
		error
	end
	
	if ~isequal(fname,0)
		has_data=true;
		Stro.Filename = '';
		Stro.DisplayName = '';
		
		Stro.two_theta = [];
		Stro.data_fit = [];
		
		Stro.Fmodel=[];
		Stro.PSfxn=[];
		
		Stro.fit_parms=[];
		Stro.fit_parms_error=[];
		Stro.fit_results=[];
		Stro.fit_initial=[];
		
		Stro.PeakPositions=[];
		Stro.bkgd2th=[];
		Stro.Constrains = zeros(1,5);
		
		
		Stro.Filename=fname;
		Stro.DataPath=path;
		Stro.OutputPath = strcat(Stro.DataPath, '/FitOutputs/');
		
		if isa(Stro.Filename,'char')
			Stro.Filename = {Stro.Filename};
		end
		
		[~, ~, ext] = fileparts( Stro.Filename{1} );
		if strcmp(ext,'.spr')
			Stro.parse2D
		else
			for i=1:length(Stro.Filename)
				inFile = strcat(Stro.DataPath, Stro.Filename{i});
				[~, ~, ext] = fileparts( inFile );
				
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
        
	else
		has_data=false;
	end  % this is to prevent data loss when hitting cancel in uigetfile
end
