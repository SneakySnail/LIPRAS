
% Reads and loads a file containing fit parameters into the current profile.
function isLoaded = Read_Inputs(Stro)
	Stro.Status='Reading options file... ';
	[filename, pathName]  = uigetfile({'*.txt;','*.txt'},'Select Input File','MultiSelect', 'off');
	if isequal(filename,0)
		isLoaded=false;
		Stro.Status=[Stro.Status,'Options file not found. '];
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
		
		fgetl(fid);
		fgetl(fid);
		
		while ~feof(fid)
			line=fgetl(fid);
			a=strsplit(line,' ');
			
			switch(a{1})
				case '2theta_fit_range:'
					Stro.Min2T = str2double(a{2});
					Stro.Max2T = str2double(a{3});
					
				case 'Background_order:'
					Stro.PolyOrder= str2double(a{2});
					
				case 'Average_Data:'
					Stro.DataAverage = str2double(a{2});
					Stro.averageData(Stro.DataAverage)
					
				case 'SPR_Angle:'
					Stro.SPR_Angle = str2double(a{2});
					
				case 'Background_points:'
					for i=2:length(a);
						Stro.bkgd2th(i-1)= str2double(a{i});
					end
				case 'PeakPos:'
					for i=2:length(a);
						Stro.PeakPositions(i-1)= str2double(a{i});
					end
					
				case 'fitrange:'
					for i=2:length(a);
						Stro.fitrange(i-1)= str2double(a{i});
					end
					
				case 'Fxn:'
					j = 1; i =2;
					while i<=length(a)
						if strcmpi(a{i}, 'Pearson') || strcmpi(a{i}, 'Psuedo')
							Stro.PSfxn{j} = [a{i}, ' ', a{i+1}];
							i = i+2;
						elseif strcmpi(a{i}, 'Asymmetric') && strcmpi(a{i+1}, 'Pearson')
							Stro.PSfxn{j} = [a{i}, ' ', a{i+1}, ' ', a{i+2}];
							i = i+3;
						else
							Stro.PSfxn{j}=a{i};
							i=i+1;
						end
						j = j+1;
					end
					if length(Stro.PSfxn)>length(Stro.PeakPositions)
						error('Number of peak functions is greater than number of peak positions.')
					end
					
				case 'Constraints:'
					for i=2:5
						c(i-1)=str2double(a{i});
					end
					Stro.Constrains=c;
					
				case 'DataPath:'
					Stro.DataPath = a(2);
					Stro.DataPath = Stro.DataPath{1};
					
				case 'Files:'
					for i=2:length(a);
						Stro.Filename{i-1}=a{i};
					end
					
				case 'Fit_Range'
					for i=2:length(a);
						Stro.Fit_Range(i-1)= str2double(a{i});
					end
					
				case 'Fit_initial'
					break
					
				otherwise
					
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
